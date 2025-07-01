use std::time::Duration;

use godot::prelude::*;
use mmo_client::{ConnectionEvent, GameClient, decode_token};

use crate::action::read_action_batch;
use crate::event::encode_game_event;

#[derive(GodotClass, Debug, Clone)]
#[class(base=RefCounted, init)]
pub struct Character {
    #[var]
    pub entity_id: i64,
    #[var]
    pub name: GString,
    #[var]
    pub hp: i32,
    #[var]
    pub level: i32,
    #[var]
    pub transform: Transform3D,
}

impl From<mmo_client::Character> for Character {
    fn from(character: mmo_client::Character) -> Self {
        Self {
            entity_id: character.entity_id as i64,
            name: GString::from(character.name),
            hp: character.hp,
            level: character.level,
            transform: convert_transform(character.transform),
        }
    }
}

pub fn convert_transform(transform: mmo_client::Transform) -> Transform3D {
    let pos = Vector3::new(
        transform.position.x,
        transform.position.y,
        transform.position.z,
    );
    Transform3D::new(Basis::default(), pos).rotated(Vector3::new(0., 1., 0.), transform.yaw)
}

#[derive(GodotClass)]
#[class(base=Object, init)]
pub struct NetworkManager {
    client: GameClient,

    base: Base<Object>,
}

#[godot_api]
impl NetworkManager {
    #[signal]
    fn connection_success();

    #[signal]
    fn enter_game_success(character: Gd<Character>);

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
                ConnectionEvent::EnterGameSuccess { character } => self
                    .signals()
                    .enter_game_success()
                    .emit(&Gd::from_object(character.into())),
                _ => (),
            }
        }
    }

    #[func]
    pub fn sync(&mut self, action_bytes: PackedByteArray, dt: f64) -> Array<Dictionary> {
        let actions = read_action_batch(action_bytes);
        if !actions.is_empty() {
            self.client.send_actions(actions);
        }

        let server_events = self.client.update_game(Duration::from_secs_f64(dt));
        godot_print!("EVENTS: {:?}", server_events);
        Array::from_iter(server_events.into_iter().map(encode_game_event))
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
