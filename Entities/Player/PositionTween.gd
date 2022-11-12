extends Tween

# TODO: Move to a global resource
export(int) var TILE_SIZE = 16
export(int) var TWEEN_SPEED = 8

onready var parent: Node2D = get_parent()


func move(position: Vector2, direction: Vector2):
	interpolate_property(
		parent,
		"position",
		position, 
		position + (direction * TILE_SIZE),
		1.0 / TWEEN_SPEED,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	start()
