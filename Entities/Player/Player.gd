extends Area2D

export(int) var TILE_SIZE = 16

var INPUTS := {
	"player_up": Vector2.UP,
	"player_down": Vector2.DOWN,
	"player_left": Vector2.LEFT,
	"player_right": Vector2.RIGHT
}

onready var ray_cast_2d := $RayCast2D
onready var position_tween := $PositionTween


func _unhandled_input(event: InputEvent) -> void:
	if position_tween.is_active():
		return
	
	for input in INPUTS.keys():
		if event.is_action_pressed(input):
			move(INPUTS[input])


func move(direction: Vector2):
	ray_cast_2d.cast_to = direction * TILE_SIZE
	ray_cast_2d.force_raycast_update()
	
	if not ray_cast_2d.is_colliding():
		position_tween.move(position, direction)
