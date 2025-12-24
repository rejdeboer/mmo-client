extends Node

var library = preload("res://entities/asset_library.tres")


func get_by_id(id: int):
	return library.entity_assets.get(id)
