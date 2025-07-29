use crate::domain::MessageType;
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
#[class(base=Node, init)]
pub struct SocialManagerSingleton {
    state: ConnectionState,

    base: Base<Node>,
}

#[godot_api]
impl SocialManagerSingleton {
    #[signal]
    fn social_chat_received(name: String, text: String, channel: u8);

    #[signal]
    fn system_message_received(text: String);

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

    fn process_event(&mut self, event: SocialEvent) {
        match event {
            SocialEvent::Chat {
                channel,
                text,
                sender_name,
                sender_id,
            } => self.signals().social_chat_received().emit(
                sender_name,
                text,
                MessageType::from_social_channel(channel),
            ),
            SocialEvent::Whisper {
                text,
                sender_name,
                sender_id,
            } => {
                self.signals()
                    .social_chat_received()
                    .emit(sender_name, text, MessageType::WHISPER)
            }
            SocialEvent::WhisperReceipt {
                text,
                recipient_name,
                recipient_id,
            } => self.signals().social_chat_received().emit(
                recipient_name,
                text,
                MessageType::WHISPER_RECEIPT,
            ),
            SocialEvent::SystemMessage { text } => {
                self.signals().system_message_received().emit(text)
            }
        }
    }
}

#[godot_api]
impl INode for SocialManagerSingleton {
    fn process(&mut self, _dt: f64) {
        match &mut self.state {
            ConnectionState::Disconnected => (),
            ConnectionState::Connecting { confirm_rx } => {
                let connection_result = match confirm_rx.try_recv() {
                    Ok(res) => res,
                    Err(err) => match err {
                        oneshot::error::TryRecvError::Empty => return,
                        oneshot::error::TryRecvError::Closed => {
                            godot_error!("oneshot channel was prematurely closed");
                            self.state = ConnectionState::Disconnected;
                            return;
                        }
                    },
                };

                match connection_result {
                    Ok((action_tx, event_rx)) => {
                        self.state = ConnectionState::Connected {
                            action_tx,
                            event_rx,
                        };
                    }
                    Err(err) => {
                        godot_error!("failed to connect to social server: {:?}", err);
                    }
                }
            }
            ConnectionState::Connected {
                action_tx: _,
                event_rx,
            } => {
                let event = match event_rx.try_recv() {
                    Ok(event) => event,
                    Err(err) => match err {
                        mpsc::error::TryRecvError::Empty => return,
                        mpsc::error::TryRecvError::Disconnected => {
                            godot_error!("event channel was disconnected by server");
                            self.state = ConnectionState::Disconnected;
                            return;
                        }
                    },
                };

                self.process_event(event);
            }
        }
    }
}
