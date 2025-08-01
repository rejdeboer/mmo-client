extends Node

var _jwt: String
var _character_id: int

var jwt: String:
	get: return _jwt
var character_id: int:
	get: return _character_id
	set(id): character_id = id 

var is_authenticated: bool:
	get: return not _jwt.is_empty()


func store_session(new_jwt: String) -> void:
	_jwt = new_jwt

func clear_session() -> void:
	_jwt = ""
	print("PlayerSession: Session cleared.")
