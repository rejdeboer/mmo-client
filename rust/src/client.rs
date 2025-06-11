use std::time::Duration;

use godot::prelude::*;
use mmo_client::{ClientEvent, GameClient};

#[derive(GodotClass, Debug, Clone)]
#[class(base=RefCounted, init)]
pub struct Character {
    #[var]
    pub name: GString,
    #[var]
    pub hp: i32,
    #[var]
    pub level: i32,
    // #[var]
    // pub transform: Transform3D,
}

impl From<mmo_client::Character> for Character {
    fn from(character: mmo_client::Character) -> Self {
        Self {
            name: GString::from(character.name),
            hp: character.hp,
            level: character.level,
        }
    }
}

// impl From<mmo_client::Transform> for Transform3D {
//     fn from(transform: mmo_client::Transform) -> Self {
//         Transform3D::new(basis, origin) { basis: , origin: () }
//     }
// }

#[derive(GodotClass)]
#[class(base=Node, init)]
pub struct NetworkManagerSingleton {
    client: GameClient,

    base: Base<Node>,
}

#[godot_api]
impl INode for NetworkManagerSingleton {
    fn process(&mut self, dt: f64) {
        let events = self.client.update(Duration::from_secs_f64(dt));
        for event in events {
            godot_print!("received {:?} event", event);
            match event {
                ClientEvent::Connected => self.signals().connection_success().emit(),
                ClientEvent::EnterGameSuccess { character } => self
                    .signals()
                    .enter_game_success()
                    .emit(&Gd::from_object(character.into())),
                _ => (),
            }
        }
    }
}

#[godot_api]
impl NetworkManagerSingleton {
    #[signal]
    fn connection_success();

    #[signal]
    fn enter_game_success(character: Gd<Character>);

    #[func]
    pub fn connect_to_server(&mut self, host: String, port: u16) {
        godot_print!("connecting to {}:{}", host, port);
        self.client.connect(host, port);
    }

    #[func]
    pub fn send_enter_game_request(&mut self, character_id: i32, token: String) {
        self.client.send_enter_game_request(character_id, token);
    }

    // fn trigger_enter_game_success(&mut self, character: mmo_client::Character) {}
}
