use mmo_client::ChannelType as GameChannelType;
use web_client::ChannelType as SocialChannelType;

pub enum MessageType {
    Say = 0,
    Yell = 1,
    Zone = 2,
    Guild = 3,
    Party = 4,
}
