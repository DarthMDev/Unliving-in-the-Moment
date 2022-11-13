class_name Player
extends KinematicBody

export(int) var MAX_SPEED = 10
export(int) var ACCELERATION = 4
export(int) var FRICTION = 10
export(int) var GRAVITY = 1
export(float) var alpha = 1.0
export (int) var lives = 3
export (int) var MAX_LIVES = 3
onready var CLOTH: SoftBody = $ClothRotation/Cloth
onready var CLOTH_ROTATION = $ClothRotation
onready var ETHEREAL_PLAYER = $EtherealPlayer
onready var ROCKET_LAUNCHER_PLAYER = $RocketLauncherPlayer

onready var ROCKET_SCENE = load("res://Entities/Rocket/Rocket.tscn")

var material = SpatialMaterial.new()
var velocity = Vector3.ZERO
var player = self
var hidden_mouse = false
onready var ui = $UserInterface
onready var livesSprite = $"CanvasLayer/UserInterface/LivesCounter/Sprite"
var livesToY = {
	3: 0,
	2: 22,
	1: 44,
	0: 66
}
func _ready():
	material.flags_transparent = true
	CLOTH.material_override = material

	# hide the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	hidden_mouse = true
func _process(delta):
	if Input.is_action_just_pressed("ethereal"):
		ETHEREAL_PLAYER.play("Ethereal")
	if lives == 0:
		# TODO add death animation
		# ANIMATION_PLAYER.play('Death')
		# TODO add death sound effect
		# reset the scene
		get_tree().reload_current_scene()
		# TODO add death screen
		
	# if esc is pressed show the mouse again
	if Input.is_action_just_pressed("ui_cancel") and hidden_mouse == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		hidden_mouse = false
	elif Input.is_action_just_pressed("ui_cancel") and hidden_mouse == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		hidden_mouse = true

	if Input.is_action_just_pressed("shoot") and not ROCKET_LAUNCHER_PLAYER.is_playing():
		var rocket = ROCKET_SCENE.instance()
		rocket.init($ClothRotation/RocketLauncherMesh/RocketMesh.global_translation, $ClothRotation/RocketLauncherMesh/RocketMesh.global_rotation)
		ROCKET_LAUNCHER_PLAYER.play("Launch")
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
	
	var mousePos = get_viewport().get_mouse_position() - Vector2(get_viewport().size.x * 0.55, get_viewport().size.y * 0.5)
	
	CLOTH_ROTATION.rotation.y = lerp_angle(CLOTH_ROTATION.rotation.y, atan2(mousePos.x, mousePos.y), delta * 3)

	# if the player is below the ground respawn them back at their previous position
	if player.translation.y < -50:
		# reset the scene
		# get_tree().reload_current_scene()
		player.translation = Vector3(1, 1, 1)
		# TODO reset the player position nearest to their last position on the ground


func checkLives():
	if lives == 0:
		lives = 0
		# TODO add death GUI animation
		# Game over
	elif lives > MAX_LIVES:
		lives = MAX_LIVES
	else:
		# Respawn and update lives GUI
		pass
		# get_tree().reload_current_scene()
	livesSprite.region_rect  =  Rect2(0, livesToY[lives], 33, 11)

func damage(amount):
	lives -= amount
	checkLives()

func get_lives():
	return lives
