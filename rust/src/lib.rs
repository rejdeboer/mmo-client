mod game;
mod social;

use godot::classes::Engine;
use godot::prelude::*;
use godot_tokio::AsyncRuntime;

use crate::game::NetworkManager;

struct NetcodeExtension;

#[gdextension]
unsafe impl ExtensionLibrary for NetcodeExtension {
    fn on_level_init(level: InitLevel) {
        if level == InitLevel::Scene {
            Engine::singleton().register_singleton("NetworkManager", &NetworkManager::new_alloc());
            Engine::singleton()
                .register_singleton(AsyncRuntime::SINGLETON, &AsyncRuntime::new_alloc());
        }
    }

    fn on_level_deinit(level: InitLevel) {
        if level == InitLevel::Scene {
            let mut engine = Engine::singleton();
            let singletons = vec!["NetworkManager", AsyncRuntime::SINGLETON];
            for singleton_name in singletons.into_iter() {
                if let Some(singleton) = engine.get_singleton(singleton_name) {
                    engine.unregister_singleton(singleton_name);
                    singleton.free();
                } else {
                    godot_error!("Failed to get singleton: {:?}", singleton_name);
                }
            }
        }
    }
}
