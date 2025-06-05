use std::time::Duration;

use godot::prelude::*;
use mmo_client::GameClient;

#[derive(GodotClass)]
#[class(base=Node3D, init)]
struct NetworkManager {
    client: GameClient,
}

#[godot_api]
impl INode3D for NetworkManager {
    fn process(&mut self, dt: f64) {
        self.client.update(Duration::from_secs_f64(dt));
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
}
