use crate::domain::convert_transform;
use godot::prelude::*;
use mmo_client::EntityAttributes;

#[derive(GodotClass, Debug, Clone)]
#[class(base=RefCounted, init)]
pub struct Entity {
    #[var]
    pub id: i64,
    #[var]
    pub name: GString,
    #[var]
    pub hp: i32,
    #[var]
    pub level: i32,
    #[var]
    pub transform: Transform3D,
    #[export]
    pub attributes: Variant,
}

#[derive(GodotClass, Debug)]
#[class(base=RefCounted, init)]
pub struct PlayerAttributes {
    #[export]
    pub character_id: i32,
    #[export]
    pub guild_name: GString,
}

#[derive(GodotClass, Debug)]
#[class(base=RefCounted, init)]
pub struct NpcAttributes {}

impl From<mmo_client::Entity> for Entity {
    fn from(entity: mmo_client::Entity) -> Self {
        let attributes = match entity.attributes {
            EntityAttributes::Player {
                character_id,
                guild_name,
            } => Variant::from(Gd::from_object(PlayerAttributes {
                character_id,
                guild_name: guild_name.map_or(GString::new(), GString::from),
            })),
            EntityAttributes::Npc => Variant::from(Gd::from_object(NpcAttributes {})),
        };

        Self {
            id: entity.id as i64,
            name: GString::from(entity.name),
            hp: entity.vitals.hp,
            level: entity.level,
            transform: convert_transform(entity.transform),
            attributes,
        }
    }
}
