use std::time::Duration;

use godot::prelude::*;
use mmo_client::{ClientEvent, GameClient};

#[derive(GodotClass)]
#[class(base=Node3D, init)]
struct NetworkManager {
    client: GameClient,

    base: Base<Node3D>,
}

#[godot_api]
impl INode3D for NetworkManager {
    fn process(&mut self, dt: f64) {
        let events = self.client.update(Duration::from_secs_f64(dt));
        for event in events {
            match event {
                ClientEvent::EnterGameSuccess { character } => {
                    self.trigger_enter_game_success(character)
                }
                _ => (),
            }
        }
    }
}

#[godot_api]
impl NetworkManager {
    // TODO: Add character to body
    #[signal]
    fn enter_game_success();

    #[func]
    pub fn connect(&mut self, host: String, port: u16) {
        self.client.connect(host, port);
    }

    #[func]
    pub fn send_enter_game_request(&mut self, character_id: i32, token: String) {
        self.client.send_enter_game_request(character_id, token);
    }

    fn trigger_enter_game_success(&mut self, character: mmo_client::Character) {}
}
