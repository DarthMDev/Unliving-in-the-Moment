extends Area

onready var BOSS_SCENE = load("res://Entities/Gravedigger/GraveDigger.tscn")

func _on_BossLoadArea_body_entered(body):
	if body is Player:
		$CollisionShape.disabled = true
		$"../../BossBridge".visible = false
		var boss = BOSS_SCENE.instance()
		boss.global_translation = Vector3(-15, -2.5, -245)
		get_parent().get_parent().add_child(boss)
