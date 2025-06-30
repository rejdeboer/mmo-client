use godot::prelude::*;
use mmo_client::Vec3;
use std::io::{Cursor, ErrorKind, Read};

#[derive(Debug)]
#[repr(u8)]
enum ActionType {
    Move = 1,
}

impl ActionType {
    fn from_u8(value: u8) -> Result<Self, std::io::Error> {
        use ActionType::*;

        let action_type = match value {
            1 => Move,
            _ => return Err(std::io::Error::new(ErrorKind::Other, "invalid action type")),
        };
        Ok(action_type)
    }
}

pub enum PlayerAction {
    Move(Vec3, f32),
}

pub fn read_action_batch(batch: PackedByteArray) -> Vec<PlayerAction> {
    let bytes = batch.to_vec();
    let mut cursor = Cursor::new(&bytes[..]);
    let mut actions: Vec<PlayerAction> = Vec::new();

    while (cursor.position() as usize) < bytes.len() {
        match parse_action(&mut cursor) {
            Ok(action) => actions.push(action),
            Err(error) => {
                godot_error!("failed to parse action: {}", error);
                break;
            }
        }
    }

    actions
}

fn parse_action(cursor: &mut Cursor<&[u8]>) -> Result<PlayerAction, std::io::Error> {
    let mut type_buf = [0u8, 1];
    cursor.read_exact(&mut type_buf)?;
    match ActionType::from_u8(type_buf[0])? {
        ActionType::Move => {
            let mut buf = [0u8; 4];

            cursor.read_exact(&mut buf)?;
            let pos_x = f32::from_le_bytes(buf);

            cursor.read_exact(&mut buf)?;
            let pos_y = f32::from_le_bytes(buf);

            cursor.read_exact(&mut buf)?;
            let pos_z = f32::from_le_bytes(buf);

            cursor.read_exact(&mut buf)?;
            let yaw = f32::from_le_bytes(buf);

            Ok(PlayerAction::Move(Vec3::new(pos_x, pos_y, pos_z), yaw))
        }
    }
}
