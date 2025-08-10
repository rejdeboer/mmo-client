use crate::domain::convert_transform;
use godot::prelude::*;

#[derive(GodotClass, Debug, Clone)]
#[class(base=RefCounted, init)]
pub struct Entity {
    #[var]
    pub entity_id: i64,
    #[var]
    pub name: GString,
    #[var]
    pub hp: i32,
    #[var]
    pub level: i32,
    #[var]
    pub transform: Transform3D,
}

impl From<mmo_client::Entity> for Entity {
    fn from(entity: mmo_client::Entity) -> Self {
        Self {
            entity_id: entity.id as i64,
            name: GString::from(entity.name),
            hp: entity.vitals.hp,
            level: entity.level,
            transform: convert_transform(entity.transform),
        }
    }
}
