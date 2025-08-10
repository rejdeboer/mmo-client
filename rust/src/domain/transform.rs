use godot::prelude::*;

pub fn convert_transform(transform: mmo_client::Transform) -> Transform3D {
    let basis = Basis::from_axis_angle(Vector3::new(0., 1., 0.), transform.yaw);
    let pos = Vector3::new(
        transform.position.x,
        transform.position.y,
        transform.position.z,
    );
    Transform3D::new(basis, pos)
}
