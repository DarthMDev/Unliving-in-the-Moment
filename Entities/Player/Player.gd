extends KinematicBody

export(int) var MAX_SPEED = 10
export(int) var ACCELERATION = 4
export(int) var FRICTION = 10

onready var CLOTH = $Cloth
onready var MESH_INSTANCE = $MeshInstance

var velocity = Vector3.ZERO

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
	
	velocity = move_and_slide(velocity)
	
	var mousePos = get_viewport().get_mouse_position() - Vector2(get_viewport().size.x * 0.55, get_viewport().size.y * 0.5)
	
	MESH_INSTANCE.rotation.y = lerp_angle(MESH_INSTANCE.rotation.y, atan2(mousePos.x, mousePos.y), delta * 3)

	
