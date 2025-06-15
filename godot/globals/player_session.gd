extends Node

var _jwt: String

var jwt: String:
	get: return _jwt

var is_authenticated: bool:
	get: return not _jwt.is_empty()


func store_session(new_jwt: String) -> void:
	_jwt = new_jwt

func clear_session() -> void:
	_jwt = ""
	print("PlayerSession: Session cleared.")
