extends KinematicBody

class_name Enemy
# gravity
var gravity = 15


var xlocation = rand_range(-360, 360)
var zlocation = rand_range(-360, 360)
# following player
var harass = false
# player escape event

var player_escape = false
export (NodePath)  var AREAPATH
onready var area = get_node(AREAPATH)
# face the direction of the player
onready var target = get_parent().get_node("Player")
var rot_speed = 0.05
# map navigation
onready var agent: NavigationAgent = $agent

onready var ANIM_IDLE = $MeshInstance/skeleton_idle/AnimationPlayer
onready var ANIM_EQUIP = $MeshInstance/skeleton_equip_glonk/AnimationPlayer
onready var ANIM_MARCH = $MeshInstance/skeleton_march/AnimationPlayer
onready var ANIM_SHOOT = $MeshInstance/skeleton_shoot/AnimationPlayer

var equipped = false
var equipping = false
var fire_timer = 3
var chase_timer = 0.0
var clip = 5
var max_clip = 5
var shots = 0

onready var target_location: Node = $"../Player"
var speed = 5
var minimum_speed = 3
var idle_speed = rand_range(minimum_speed, speed)
var move_or_not = [true, false]
var start_move = move_or_not[randi() % move_or_not.size()]

var chasing = true
export var MAX_HEALTH = 3
export var health = 3
func _ready():
	# 
	area.connect("body_entered", self, "on_body_entered")
	area.connect("body_exited", self, "on_body_exited")

func on_body_entered(body):
	if body.name ==  'Player':
		if body.alpha >= 1.0:
			rot_speed = 0.1
			harass = true
			
func shoot_projectile():
	#TODO: make it shoot
	pass

func do_animations(delta):
	
	ANIM_IDLE.get_parent().visible = false
	ANIM_EQUIP.get_parent().visible = false
	ANIM_MARCH.get_parent().visible = false
	ANIM_SHOOT.get_parent().visible = false
	
	var distance = global_translation.distance_to(target.global_translation)
	chasing = distance > 24 && target.alpha == 1.0 || chase_timer > 0
	
	var attacking = distance <= 24 && target.alpha == 1.0 && chase_timer <= 0
	
	var spaceState = get_world().direct_space_state
	
	var rayArray = spaceState.intersect_ray(global_translation + Vector3.UP, target.global_translation + Vector3.UP * 0.5)
	
	if rayArray.has("collider"):
		chase_timer = 1
	
	
	if (attacking):
		if !equipped:
			ANIM_EQUIP.get_parent().visible = true
			
			#.seek(0, true)
			if !equipping:
				clip = max_clip
				equipping = true
				#$MeshInstance/skeleton_equip_glonk/AnimationPlayer
				ANIM_EQUIP.stop()
				ANIM_EQUIP.seek(0, true)
				ANIM_EQUIP.play("Animation")
			elif !ANIM_EQUIP.is_playing():
				equipped = true
		else:
			look_at(target.global_translation, Vector3.UP)
			ANIM_SHOOT.get_parent().visible = true
			if fire_timer > 0:
				fire_timer -= delta
				if fire_timer <= 0:
					if clip <= 0:
						equipped = false
						equipping = false
					elif rand_range(0, 10) <= 1 && distance > 8:
						chase_timer = rand_range(2, 4)
					else:
						if rand_range(0, 10) < 3:
							shots = 2
						else:
							shots = 0
			else:
				shoot_projectile()
				ANIM_SHOOT.stop()
				ANIM_SHOOT.seek(0, true)
				ANIM_SHOOT.play("Animation")
				if shots > 0:
					fire_timer = 0.5
					shots = shots - 1
				else:
					fire_timer = 3
				clip = clip - 1
				
	
	elif !chasing:
		ANIM_IDLE.get_parent().visible = true
		
		ANIM_IDLE.play("Animation")
		
	if chasing:
		ANIM_MARCH.get_parent().visible = true
		ANIM_MARCH.playback_speed = 2
	
		ANIM_MARCH.play("Animation")
		
	if chase_timer > 0:
			chase_timer -= delta
	
	
	
	

func _process(delta):
	do_animations(delta)
	var global_pos = self.global_transform.origin
	var target_pos = target.global_transform.origin
	var wtransform = self.global_transform.looking_at(Vector3(target_pos.x, global_pos.y, target_pos.z), Vector3.UP)
	var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rot_speed)
	if harass:
		if chasing:
			if $"../Player" != null and $"../Player".alpha >= 1.0:
				# face player
				global_pos = self.global_transform.origin
				target_pos = target.global_transform.origin
				wtransform = self.global_transform.looking_at(Vector3(target_pos.x, global_pos.y, target_pos.z), Vector3.UP)
				wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rot_speed)
				self.global_transform = Transform(Basis(wrotation), global_pos)
				
				# set the player location
				agent.set_target_location(target.global_transform.origin)
				# move to them
				var next = agent.get_next_location()
				var velocity = (next - transform.origin).normalized() * speed * delta
				move_and_collide(velocity)
			elif player_escape == false:
				# idle
				global_pos = self.global_transform.origin
				wtransform = self.global_transform.looking_at(Vector3(xlocation, global_pos.y, zlocation), Vector3.UP)
				wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rot_speed)
				self.global_transform = Transform(Basis(wrotation), global_pos)
				if start_move == true:
					var velocity = global_transform.basis.z.normalized() * idle_speed * delta
					move_and_collide(-velocity)
			else:
				# Enemy looks at the player when they escape
				global_pos = self.global_transform.origin
				target_pos = target.global_transform.origin
				wtransform = self.global_transform.looking_at(Vector3(target_pos.x, global_pos.y, target_pos.z), Vector3.UP)
				wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rot_speed)
				self.global_transform = Transform(Basis(wrotation), global_pos)

			if not is_on_floor():
				move_and_collide(-global_transform.basis.y.normalized() * gravity * delta)
				
func on_body_exited(body):
	if body.name == ('Player'):
		rot_speed = 0.05
		harass = false
		# when player escapes enemy waits and looks at the player
		player_escape = true
		$Timer2.start()

# Timer for random looking
func _on_Timer_timeout():
	$Timer.set_wait_time(rand_range(4, 8))
	xlocation = rand_range(-360, 360)
	zlocation = rand_range(-360, 360)
	# random speed of idle moving
	idle_speed = rand_range(minimum_speed, speed)
	# Enemy will move or look around
	start_move = move_or_not[randi() % move_or_not.size()]
	$Timer.start()
	AnimationPlayer

func _on_agent_velocity_computed(safe_velocity):
	move_and_collide(safe_velocity)

func _on_Timer2_timeout():
	# enemy is going back to idle
	player_escape = false			
							
func damage(dmg):
	health -= dmg
	if health <= 0:
		# TODO play death animation
		self.queue_free()
