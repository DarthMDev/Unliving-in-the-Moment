extends Area

func _on_CheckpointArea_body_entered(body):
	if body is Player:
		get_tree().current_scene.checkpoint = $Spatial.global_translation
		$CollisionShape.disabled = true
