class_name Player

extends KinematicBody

export(int) var MAX_SPEED = 10
export(int) var ACCELERATION = 4
export(int) var FRICTION = 10
export(int) var GRAVITY = 1
export (int) var HEALTH = 100
export (int) var MAX_HEALTH = 100
export(float) var alpha = 1.0
export (int) var LIVES = 3
export (int) var MAX_LIVES = 3

onready var CLOTH: SoftBody = $ClothRotation/Cloth
onready var CLOTH_ROTATION = $ClothRotation
onready var ANIMATION_PLAYER = $AnimationPlayer

onready var ROCKET_LAUNCHER_MESH = $ClothRotation/RocketLauncherMesh

onready var ROCKET_SCENE = load("res://Entities/Rocket/Rocket.tscn")

var material = SpatialMaterial.new()
var velocity = Vector3.ZERO
var player = self
var hidden_mouse = false

func _ready():
	material.flags_transparent = true
	CLOTH.material_override = material

	# hide the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	hidden_mouse = true
func _process(delta):
	if Input.is_action_just_pressed("ethereal"):
		ANIMATION_PLAYER.play("Ethereal")
	if HEALTH == 0:
		# TODO add death animation
		# ANIMATION_PLAYER.play('Death')
		# TODO add death sound effect
		# reset the scene
		get_tree().reload_current_scene()
		# TODO add death screen
		LIVES -= 1
	# if esc is pressed show the mouse again
	if Input.is_action_just_pressed("ui_cancel") and hidden_mouse == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		hidden_mouse = false
	elif Input.is_action_just_pressed("ui_cancel") and hidden_mouse == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		hidden_mouse = true

	if Input.is_action_just_pressed("shoot"):
		var rocket = ROCKET_SCENE.instance()
		rocket.init($ClothRotation/RocketLauncherMesh/RocketMesh.global_translation, $ClothRotation/RocketLauncherMesh/RocketMesh.global_rotation)
		get_parent().add_child(rocket)
	
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
	
	var mousePos = getMousePosition3D()
	var mouseDelta = mousePos - translation
	
	var angle = atan2(mouseDelta.x, mouseDelta.z);
	
	CLOTH_ROTATION.rotation.y = lerp_angle(CLOTH_ROTATION.rotation.y, angle, delta * 3)
	
	ROCKET_LAUNCHER_MESH.rotation.y = angle - CLOTH_ROTATION.rotation.y + deg2rad(90)
	
	# if the player is below the ground respawn them back at their previous position
	if player.translation.y < -50:
		# reset the scene
		get_tree().reload_current_scene()
		# TODO reset the player position nearest to their last position on the ground
		

func getMousePosition3D():
	
	var spaceState = get_world().direct_space_state
	
	var mousePos = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera()
	var rayOrigin = camera.project_ray_origin(mousePos)
	var rayEnd = rayOrigin + camera.project_ray_normal(mousePos) * 2000
	var rayArray = spaceState.intersect_ray(rayOrigin, rayEnd)
	
	if rayArray.has("position"):
		return rayArray["position"]
	return Vector3()

func change_health(amount):
	HEALTH += amount
	if HEALTH == clamp(HEALTH, 0, MAX_HEALTH):
		HEALTH = 0
		LIVES -= 1
		checkLives()
	else:
		# Update health bar
		pass
		
func checkLives():
	if LIVES == clamp(LIVES, 0, MAX_LIVES):
		LIVES = 0
		# Game over
	else:
		# Respawn and update lives GUI
		get_tree().reload_current_scene()

func change_lives(amount):
	LIVES += amount
	checkLives()
