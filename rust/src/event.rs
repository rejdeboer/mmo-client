use godot::prelude::*;
use mmo_client::GameEvent;

use crate::client::convert_transform;

#[repr(u8)]
enum ServerEventType {
    EntityMove = 1,
    EntitySpawn = 2,
    EntityDespawn = 3,
}

pub fn encode_game_event(event: GameEvent) -> Dictionary {
    match event {
        GameEvent::MoveEntity {
            entity_id,
            transform,
        } => {
            dict! {"type": ServerEventType::EntityMove as u8, "entity_id": entity_id, "transform": convert_transform(transform)}
        }
        GameEvent::SpawnEntity { entity_id } => {
            dict! {"type": ServerEventType::EntitySpawn as u8, "entity_id": entity_id }
        }
        GameEvent::DespawnEntity { entity_id } => {
            dict! {"type": ServerEventType::EntityDespawn as u8, "entity_id": entity_id }
        }
    }
}
