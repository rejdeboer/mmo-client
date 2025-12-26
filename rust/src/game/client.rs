use std::time::Duration;

use godot::prelude::*;
use mmo_client::{ConnectionEvent, GameClient, PlayerAction, decode_token};

use crate::domain::{Entity, MessageType};

use super::event::encode_game_event;
use super::movement::read_movement_bytes;

#[derive(GodotClass)]
#[class(base=Object, init)]
pub struct NetworkManager {
    client: GameClient,
    action_queue: Vec<PlayerAction>,

    base: Base<Object>,
}

#[godot_api]
impl NetworkManager {
    #[signal]
    fn connection_success();

    #[signal]
    fn enter_game_success(character: Gd<Entity>);

    #[func]
    pub fn connect_to_server(&mut self, encoded_token: String) {
        godot_print!("securely connecting to server");
        let token = decode_token(encoded_token).expect("token decoded");
        self.client.connect(token);
    }

    #[func]
    pub fn poll_connection(&mut self, dt: f64) {
        let event_option = self.client.poll_connection(Duration::from_secs_f64(dt));
        if let Some(event) = event_option {
            godot_print!("received {:?} event", event);
            match event {
                ConnectionEvent::Connected => self.signals().connection_success().emit(),
                ConnectionEvent::EnterGameSuccess { player_entity } => self
                    .signals()
                    .enter_game_success()
                    .emit(&Gd::<Entity>::from_object(player_entity.into())),
                _ => (),
            }
        }
    }

    #[func]
    pub fn sync(&mut self, movement_bytes: PackedByteArray, dt: f64) -> Array<VarDictionary> {
        let actions = std::mem::take(&mut self.action_queue);
        self.client
            .send_actions(read_movement_bytes(movement_bytes), actions);

        let server_events = self.client.update_game(Duration::from_secs_f64(dt));
        Array::from_iter(server_events.into_iter().map(encode_game_event))
    }

    #[func]
    pub fn queue_chat(&mut self, message_type: u8, text: String) {
        let Some(channel) = MessageType::to_game_channel(message_type) else {
            return;
        };
        self.action_queue.push(PlayerAction::Chat(channel, text));
    }

    #[func]
    pub fn queue_jump(&mut self) {
        self.action_queue.push(PlayerAction::Jump);
    }

    #[func]
    pub fn queue_cast_spell(&mut self, target_entity_id: u64, spell_id: u32) {
        self.action_queue.push(PlayerAction::CastSpell {
            target_entity_id,
            spell_id,
        });
    }

    #[func]
    /// Should only be used for local testing
    pub fn connect_unsecure(&mut self, host: String, port: u16, character_id: i32) {
        godot_print!(
            "connecting to character {} on {}:{}",
            character_id,
            host,
            port
        );
        self.client.connect_unsecure(host, port, character_id);
    }
}
