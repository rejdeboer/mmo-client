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
