mod client;

use godot::classes::Engine;
use godot::prelude::*;

use crate::client::NetworkManager;

struct NetcodeExtension;

#[gdextension]
unsafe impl ExtensionLibrary for NetcodeExtension {
    fn on_level_init(level: InitLevel) {
        if level == InitLevel::Scene {
            Engine::singleton().register_singleton("NetworkManager", &NetworkManager::new_alloc());
        }
    }

    fn on_level_deinit(level: InitLevel) {
        if level == InitLevel::Scene {
            let mut engine = Engine::singleton();
            let singleton_name = "NetworkManager";

            if let Some(my_singleton) = engine.get_singleton(singleton_name) {
                engine.unregister_singleton(singleton_name);
                my_singleton.free();
            } else {
                godot_error!("Failed to get singleton");
            }
        }
    }
}
