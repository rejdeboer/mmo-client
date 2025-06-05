mod client;

use godot::prelude::*;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}

#[derive(GodotClass)]
#[class(init)]
struct TestStruct {}

#[godot_api]
impl TestStruct {
    #[func]
    fn print(&mut self) {
        godot_print!("Print from extension!");
    }
}
