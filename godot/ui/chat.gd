extends Control

@onready var chat_display = $Panel/VBoxContainer/Display
@onready var message_input = $Panel/VBoxContainer/ChatInput

enum ChannelType {
	SAY = 1,
}

func _ready():
	message_input.text_submitted.connect(_on_text_submitted)
	
func _process(delta):
	if Input.is_action_pressed("enter"):
		if message_input.has_focus():
			send_message()
		else:
			message_input.grab_focus()

func _on_text_submitted(text):
	pass
	#send_message()

func send_message():
	var text = message_input.text
	if text.strip_edges().is_empty():
		return

	NetworkManager.queue_chat(ChannelType.SAY, message_input.text)

	message_input.text = ""
	message_input.grab_focus()

func add_message(username, message):
	chat_display.append_text("[b]" + username + ":[/b] " + message + "\n")
