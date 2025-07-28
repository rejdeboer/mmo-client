use godot::prelude::*;
use godot_tokio::AsyncRuntime;
use tokio::sync::{mpsc, oneshot};
use web_client::{ConnectionResult, SocialAction, SocialEvent};

#[derive(Default)]
pub enum ConnectionState {
    #[default]
    Disconnected,
    Connecting {
        confirm_rx: oneshot::Receiver<ConnectionResult>,
    },
    Connected {
        action_tx: mpsc::Sender<SocialAction>,
        event_rx: mpsc::Receiver<SocialEvent>,
    },
}

#[derive(GodotClass)]
#[class(base=Object, init)]
pub struct SocialManager {
    state: ConnectionState,

    base: Base<Object>,
}

#[godot_api]
impl SocialManager {
    #[func]
    pub fn connect(&mut self, server_url: String, token: String) {
        let (confirm_tx, confirm_rx) = oneshot::channel::<ConnectionResult>();

        AsyncRuntime::spawn(async move {
            let result = web_client::connect(&server_url, &token).await;
            if confirm_tx.send(result).is_err() {
                godot_error!("failed to send connection confirmation");
            }
        });

        self.state = ConnectionState::Connecting { confirm_rx };
    }
}
