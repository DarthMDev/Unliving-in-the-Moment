extends KinematicBody

export(int) var MAX_SPEED = 10
export(int) var ACCELERATION = 4
export(int) var FRICTION = 10
export(int) var GRAVITY = 1

export(float) var alpha = 1.0

onready var CLOTH: SoftBody = $ClothRotation/Cloth
onready var CLOTH_ROTATION = $ClothRotation
onready var ANIMATION_PLAYER = $AnimationPlayer

var material = SpatialMaterial.new()
var velocity = Vector3.ZERO


func _ready():
	material.flags_transparent = true
	CLOTH.material_override = material


func _process(delta):
	if Input.is_action_just_pressed("ethereal"):
		ANIMATION_PLAYER.play("Ethereal")
	
	material.albedo_color = Color(1.0, 1.0, 1.0, alpha)


func _physics_process(delta):
	var x_input = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	var z_input = Input.get_action_strength("player_down") - Input.get_action_strength("player_up")
	var direction = Vector3(x_input, 0, z_input).normalized()
	
	if direction.x == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	else:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED, ACCELERATION)
	
	if direction.z == 0:
		velocity.z = move_toward(velocity.z, 0, FRICTION)
	else:
		velocity.z = move_toward(velocity.z, direction.z * MAX_SPEED, ACCELERATION)
	
	velocity.y += -GRAVITY
	
	velocity = move_and_slide(velocity, Vector3.UP, true, 4, deg2rad(45))
	
	var mousePos = get_viewport().get_mouse_position() - Vector2(get_viewport().size.x * 0.55, get_viewport().size.y * 0.5)
	
	CLOTH_ROTATION.rotation.y = lerp_angle(CLOTH_ROTATION.rotation.y, atan2(mousePos.x, mousePos.y), delta * 3)
