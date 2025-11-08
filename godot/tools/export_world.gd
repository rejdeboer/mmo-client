@tool
extends EditorScript

const SOURCE_SCENE_PATH = "res://game/world.tscn" 
const EXPORT_PATH = "res://../../mmo-server/mmo-server/assets/world.gltf"

func _run():
	print("Starting collision export...")

	var source_scene = load(SOURCE_SCENE_PATH)
	if not source_scene:
		printerr("Failed to load source scene at: ", SOURCE_SCENE_PATH)
		return

	var scene_instance = source_scene.instantiate()
	var scene_root = get_scene()
	scene_root.add_child(scene_instance)
	
	var collision_shapes_to_export = []
	_find_collision_shapes(scene_instance, collision_shapes_to_export)

	if collision_shapes_to_export.is_empty():
		printerr("No CollisionShape3D nodes found in the scene.")
		scene_instance.free()
		return
	
	print("Found %d collision shapes to export." % collision_shapes_to_export.size())

	var temp_scene_root = Node3D.new()

	for shape_node in collision_shapes_to_export:
		if not shape_node is CollisionShape3D:
			continue
			
		var shape_transform = shape_node.global_transform
		var original_parent = shape_node.get_parent()
		if original_parent:
			original_parent.remove_child(shape_node)
			shape_node.owner = null

		temp_scene_root.add_child(shape_node)
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = shape_node.shape.get_debug_mesh()
		mesh_instance.global_transform = shape_transform
		temp_scene_root.remove_child(shape_node)
		
		temp_scene_root.add_child(mesh_instance)
		mesh_instance.owner = temp_scene_root

	var gltf_state = GLTFState.new()
	var gltf_doc = GLTFDocument.new()
	var error = gltf_doc.append_from_scene(temp_scene_root, gltf_state)
	
	if error != OK:
		printerr("Failed to generate GLTF document from temporary scene.")
		temp_scene_root.free()
		scene_instance.free()
		return

	error = gltf_doc.write_to_filesystem(gltf_state, EXPORT_PATH)

	temp_scene_root.free()
	scene_instance.free()

	if error == OK:
		print("Successfully exported collision geometry to: ", EXPORT_PATH)
	else:
		printerr("Error writing GLTF file to disk. Error code: ", error)

func _find_collision_shapes(node, list):
	if node is CollisionShape3D and node.get_parent().name == "Ground":
		list.append(node)
	
	for child in node.get_children():
		_find_collision_shapes(child, list)
