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
    fn social_chat_received(name: GString, text: GString, channel: u8);

    #[signal]
    fn system_message_received(text: GString);

    #[func]
    pub fn connect_to_server(&mut self, server_url: String, token: String) {
        let (confirm_tx, confirm_rx) = oneshot::channel::<ConnectionResult>();

        let server_url = server_url.replacen("http", "ws", 1);
        AsyncRuntime::spawn(async move {
            let result = web_client::connect(&format!("{server_url}/social"), &token).await;
            if confirm_tx.send(result).is_err() {
                godot_error!("failed to send connection confirmation");
            } else {
                godot_print!("successfully sent connection result through oneshot");
            }
        });

        self.state = ConnectionState::Connecting { confirm_rx };
    }

    #[func]
    pub fn send_chat(&mut self, message_type: u8, text: String) {
        let Some(channel) = MessageType::to_social_channel(message_type) else {
            return;
        };
        self.send_action(SocialAction::Chat { channel, text });
    }

    #[func]
    pub fn send_whisper(&mut self, recipient_name: String, text: String) {
        self.send_action(SocialAction::WhisperByName {
            recipient_name,
            text,
        });
    }

    fn send_action(&mut self, action: SocialAction) {
        let ConnectionState::Connected {
            action_tx,
            event_rx: _,
        } = &mut self.state
        else {
            self.signals()
                .system_message_received()
                .emit("Something went wrong, please try relogging");
            godot_error!("tried to send {:?} while not connected to server", action);
            return;
        };

        if let Err(err) = action_tx.try_send(action) {
            match err {
                mpsc::error::TrySendError::Full(_) => {
                    self.signals()
                        .system_message_received()
                        .emit("Too many actions to send, please wait a moment");
                    godot_error!("action channel is full");
                }
                mpsc::error::TrySendError::Closed(_) => {
                    self.signals()
                        .system_message_received()
                        .emit("Something went wrong, please try relogging");
                    godot_error!("action channel is closed prematurely");
                    self.state = ConnectionState::Disconnected;
                }
            }
        }
    }

    fn process_event(&mut self, event: SocialEvent) {
        match event {
            SocialEvent::Chat {
                channel,
                text,
                sender_name,
                sender_id,
            } => self.signals().social_chat_received().emit(
                &sender_name,
                &text,
                MessageType::from_social_channel(channel),
            ),
            SocialEvent::Whisper {
                text,
                sender_name,
                sender_id,
            } => self.signals().social_chat_received().emit(
                &sender_name,
                &text,
                MessageType::WHISPER,
            ),
            SocialEvent::WhisperReceipt {
                text,
                recipient_name,
                recipient_id,
            } => self.signals().social_chat_received().emit(
                &recipient_name,
                &text,
                MessageType::WHISPER_RECEIPT,
            ),
            SocialEvent::SystemMessage { text } => {
                self.signals().system_message_received().emit(&text)
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
