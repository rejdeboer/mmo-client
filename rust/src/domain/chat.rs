use godot::prelude::*;
use mmo_client::ChannelType as GameChannelType;
use web_client::ChannelType as SocialChannelType;

#[derive(GodotClass)]
#[class(base=RefCounted, init)]
pub struct MessageType {}

#[godot_api]
impl MessageType {
    #[constant]
    pub const SAY: u8 = 0;
    #[constant]
    pub const YELL: u8 = 1;
    #[constant]
    pub const ZONE: u8 = 2;
    #[constant]
    pub const GUILD: u8 = 3;
    #[constant]
    pub const PARTY: u8 = 4;
    #[constant]
    pub const TRADE: u8 = 5;
    #[constant]
    pub const WHISPER: u8 = 6;
    #[constant]
    pub const WHISPER_RECEIPT: u8 = 7;
    #[constant]
    pub const UNKNOWN: u8 = 255;

    pub fn from_game_channel(channel: GameChannelType) -> u8 {
        match channel {
            GameChannelType::Say => Self::SAY,
            GameChannelType::Yell => Self::YELL,
            GameChannelType::Zone => Self::ZONE,
            other => {
                godot_warn!("unhandled game channel type: {:?}", other);
                Self::UNKNOWN
            }
        }
    }

    pub fn to_game_channel(message_type: u8) -> Option<GameChannelType> {
        match message_type {
            Self::SAY => Some(GameChannelType::Say),
            Self::YELL => Some(GameChannelType::Yell),
            Self::ZONE => Some(GameChannelType::Zone),
            other => {
                godot_warn!("unhandled game message type: {:?}", other);
                None
            }
        }
    }

    pub fn from_social_channel(channel: SocialChannelType) -> u8 {
        match channel {
            SocialChannelType::Guild => Self::GUILD,
            SocialChannelType::Party => Self::PARTY,
            SocialChannelType::Trade => Self::TRADE,
            other => {
                godot_warn!("unhandled social channel type: {:?}", other);
                Self::UNKNOWN
            }
        }
    }

    pub fn to_social_channel(message_type: u8) -> Option<SocialChannelType> {
        match message_type {
            Self::GUILD => Some(SocialChannelType::Guild),
            Self::PARTY => Some(SocialChannelType::Party),
            Self::TRADE => Some(SocialChannelType::Trade),
            other => {
                godot_warn!("unhandled social message type: {:?}", other);
                None
            }
        }
    }
}
