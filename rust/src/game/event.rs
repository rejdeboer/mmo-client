use super::client::convert_transform;
use crate::domain::MessageType;
use godot::prelude::*;
use mmo_client::GameEvent;

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
            sender_name,
            text,
        } => {
            vdict! {
                "type": ServerEventType::Chat as u8,
                "message_type": MessageType::from_game_channel(channel),
                "sender_name": sender_name,
                "text": text,
            }
        }
        GameEvent::MoveEntity {
            entity_id,
            transform,
        } => {
            vdict! {"type": ServerEventType::EntityMove as u8, "entity_id": entity_id, "transform": convert_transform(transform)}
        }
        GameEvent::SpawnEntity {
            entity_id,
            transform,
        } => {
            vdict! {"type": ServerEventType::EntitySpawn as u8, "entity_id": entity_id, "transform": convert_transform(transform)}
        }
        GameEvent::DespawnEntity { entity_id } => {
            vdict! {"type": ServerEventType::EntityDespawn as u8, "entity_id": entity_id}
        }
    }
}
