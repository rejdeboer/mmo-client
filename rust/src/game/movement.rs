use godot::prelude::*;
use mmo_client::MoveAction;
use std::io::{Cursor, Read};

pub fn read_movement_bytes(bytes: PackedByteArray) -> Option<MoveAction> {
    if bytes.is_empty() {
        return None;
    }

    let bytes = bytes.to_vec();
    let mut cursor = Cursor::new(&bytes[..]);

    match parse_action(&mut cursor) {
        Ok(action) => Some(action),
        Err(error) => {
            godot_error!("failed to parse action: {}", error);
            None
        }
    }
}

fn parse_action(cursor: &mut Cursor<&[u8]>) -> Result<MoveAction, std::io::Error> {
    let mut buf = [0u8; 4];
    cursor.read_exact(&mut buf)?;
    let yaw = f32::from_le_bytes(buf);
    cursor.read_exact(&mut buf)?;
    let forward = f32::from_le_bytes(buf);
    cursor.read_exact(&mut buf)?;
    let sideways = f32::from_le_bytes(buf);

    Ok(MoveAction {
        yaw,
        forward,
        sideways,
    })
}
