extends CharacterBody3D

var target_transform = Transform3D()

func _ready():
	target_transform = self.transform

func _physics_process(delta):
	transform = transform.interpolate_with(target_transform, 0.2)
	# if transform.origin.distance_to(target_transform.origin) >= 0.05:
	# 	%Character/AnimationPlayer.current_animation = "run"
	# else:
	# 	%Character/AnimationPlayer.current_animation = "idle"
