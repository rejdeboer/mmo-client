use godot::prelude::*;
use mmo_client::GameEvent;

use crate::client::convert_transform;

#[repr(u8)]
enum ServerEventType {
    EntityMove = 1,
    EntitySpawn = 2,
    EntityDespawn = 3,
    Chat = 4,
}

pub fn encode_game_event(event: GameEvent) -> Dictionary {
    match event {
        GameEvent::Chat {
            channel,
            author_name,
            text,
        } => {
            dict! {
                "type": ServerEventType::Chat as u8,
                "channel": channel.0,
                "author_name": author_name,
                "text": text,
            }
        }
        GameEvent::MoveEntity {
            entity_id,
            transform,
        } => {
            dict! {"type": ServerEventType::EntityMove as u8, "entity_id": entity_id, "transform": convert_transform(transform)}
        }
        GameEvent::SpawnEntity {
            entity_id,
            transform,
        } => {
            dict! {"type": ServerEventType::EntitySpawn as u8, "entity_id": entity_id, "transform": convert_transform(transform)}
        }
        GameEvent::DespawnEntity { entity_id } => {
            dict! {"type": ServerEventType::EntityDespawn as u8, "entity_id": entity_id }
        }
    }
}
