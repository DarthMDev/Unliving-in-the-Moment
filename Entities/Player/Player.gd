extends Area2D

export(int) var TILE_SIZE = 16
export(int) var MAX_ETHEREAL_TIMER = 3
export(int) var TWEEN_SPEED = 8

export(float) var alpha = 1.0
export(bool) var ethereal = false

var INPUTS := {
	"player_up": Vector2.UP,
	"player_down": Vector2.DOWN,
	"player_left": Vector2.LEFT,
	"player_right": Vector2.RIGHT
}

onready var sprite := $Sprite
onready var ray_cast_2d := $RayCast2D
onready var position_tween := $PositionTween
onready var alpha_animation := $AlphaAnimation


func _process(_delta):
	sprite.material.set_shader_param("alpha", alpha)
	
	if Input.is_action_just_pressed("ethereal"):
		alpha_animation.play("Ethereal")
	
	if ethereal:
		#sprite.region_rect = Rect2(16, 0, 16, 16)
		ray_cast_2d.set_collision_mask_bit(1, false)
	else:
		#sprite.region_rect = Rect2(0, 0, 16, 16)
		ray_cast_2d.set_collision_mask_bit(1, true)


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
		position_tween.interpolate_property(
			self,
			"position",
			position, 
			position + (direction * TILE_SIZE),
			1.0 / TWEEN_SPEED,
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)
		position_tween.start()
