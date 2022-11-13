extends KinematicBody
# gravity
var gravity = 15

var xlocation = rand_range(-360, 360)
var zlocation = rand_range(-360, 360)

export (NodePath)  var AREAPATH
onready var area = get_node(AREAPATH)
# face the direction of the player
onready var target = get_parent().get_node("Player")
var rot_speed = 0.05
# map navigation
onready var agent: NavigationAgent = $agent

onready var ANIM_IDLE = $MeshInstance/gravedigger_idle/AnimationPlayer
onready var ANIM_DIG = $MeshInstance/gravedigger_dig/AnimationPlayer
onready var ANIM_SWIPE = $MeshInstance/gravedigger_swipe/AnimationPlayer
onready var ANIM_WALK = $MeshInstance/gravedigger_walk/AnimationPlayer
onready var ANIM_SMASH = $MeshInstance/gravedigger_smash/AnimationPlayer
onready var SHOCKWAVE = $MeshInstance/shockwave/AnimationPlayer


var chase_timer = 0.0


var STATE_SPEECH = 0
var STATE_IDLE = 1
var STATE_FOLLOWING = 2
var STATE_SWIPE = 3
var STATE_SMASH = 4
var STATE_DIG = 5
var state = 0.0
var target_pos = Vector3(0, 0, 0)
var shockwave_pos = Vector3(0, 0, 0)
var shockwave_time = 0

var time_in_state = 0.0

onready var target_location: Node = $"../Player"
var speed = 5
var minimum_speed = 3
var idle_speed = rand_range(minimum_speed, speed)
var move_or_not = [true, false]
var start_move = move_or_not[randi() % move_or_not.size()]

var chasing = true

func set_state(new_state):
	if state != new_state:
		state = new_state
		time_in_state = 0

func do_animations(delta):
	
	if shockwave_time > 0:
		shockwave_time = shockwave_time - delta;
		SHOCKWAVE.get_parent().global_translation = shockwave_pos
		SHOCKWAVE.get_parent().visible = true
		SHOCKWAVE.get_parent().scale = Vector3.ONE * ((1.0 - shockwave_time) * 3 + 1.0)
	else:
		SHOCKWAVE.get_parent().visible = false
		
		
	
	ANIM_IDLE.get_parent().visible = false
	ANIM_DIG.get_parent().visible = false
	ANIM_SMASH.get_parent().visible = false
	ANIM_SWIPE.get_parent().visible = false
	ANIM_WALK.get_parent().visible = false
	
	var distance = global_translation.distance_to(target.global_translation)
	chasing = false
	
	var attack_distance = 8
	
	var spaceState = get_world().direct_space_state
	
	var canSeePlayer = target.alpha >= 1.0
	
	if state == STATE_SPEECH:
		set_state(STATE_IDLE)
		if false:
			if !$AudioStreamPlayer.playing:
				$AudioStreamPlayer.play()
			
			if time_in_state > 23:
				global_translation += Vector3(0, 10, 0)
				set_state(STATE_FOLLOWING)
				$AudioStreamPlayer.stop()
			
	elif state == STATE_IDLE:
		ANIM_IDLE.get_parent().visible = true
		ANIM_IDLE.play("Animation")
		
		if time_in_state > 0.25 && canSeePlayer:
			if distance <= attack_distance:
				if rand_range(0, 10) <= 5:
					if rand_range(0, 10) <= 5:
						set_state(STATE_DIG)
					else:
						set_state(STATE_SMASH)
				else:
					set_state(STATE_SWIPE)
			else:
				set_state(STATE_FOLLOWING)
	elif state == STATE_FOLLOWING:
		chasing = true
		ANIM_WALK.get_parent().visible = true
		ANIM_WALK.playback_speed = 2
	
		ANIM_WALK.play("Animation")
		
		if canSeePlayer:
			if distance <= attack_distance:
				if rand_range(0, 10) <= 5:
					if rand_range(0, 10) <= 5:
						set_state(STATE_DIG)
					else:
						set_state(STATE_SMASH)
				else:
					set_state(STATE_SWIPE)
		else:
			set_state(STATE_IDLE)
	elif state == STATE_SWIPE:
		ANIM_SWIPE.get_parent().visible = true
		ANIM_SWIPE.playback_speed = 2
		if !ANIM_SWIPE.is_playing():
			if time_in_state < 0.25:
				ANIM_SWIPE.stop()
				ANIM_SWIPE.play("Animation")
			elif time_in_state > 1.5:
				set_state(STATE_IDLE)
				
		if time_in_state > 0.7 * 0.5:
			target_pos = Vector3(target.global_transform.origin.x, target.global_transform.origin.y, target.global_transform.origin.z)
			var look = target_pos - global_transform.origin
			
			rotation.y = lerp_angle(rotation.y, atan2(-look.x, -look.z), delta * 5)
				
	elif state == STATE_SMASH:
		ANIM_SMASH.get_parent().visible = true
		if !ANIM_SMASH.is_playing():
			if time_in_state < 0.25:
				target_pos = Vector3(target.global_transform.origin.x, target.global_transform.origin.y, target.global_transform.origin.z)
				ANIM_SMASH.stop()
				ANIM_SMASH.play("Animation")
			elif time_in_state > 2.5:
				set_state(STATE_IDLE)
		elif time_in_state > 0.5:
			var velocity = (target_pos - global_transform.origin).normalized() * speed * delta
			move_and_collide(velocity)
		if time_in_state > 1.3:
			if shockwave_time <= 0:
				shockwave_time = 1
				shockwave_pos = global_translation + Vector3.UP
				SHOCKWAVE.stop();
				SHOCKWAVE.seek(0, true);
				SHOCKWAVE.play();
	elif state == STATE_DIG:
		ANIM_DIG.get_parent().visible = true
		if !ANIM_DIG.is_playing():
			if time_in_state < 0.25:
				ANIM_DIG.stop()
				ANIM_DIG.play("Animation")
			elif time_in_state > 5:
				set_state(STATE_IDLE)
		if time_in_state > 1.5 && time_in_state < 4:
			target_pos = Vector3(target.global_transform.origin.x, target.global_transform.origin.y, target.global_transform.origin.z)
			if canSeePlayer:
				chasing = true
			else:
				var velocity = (target_pos - global_transform.origin).normalized() * speed * 3 * delta
				move_and_collide(velocity)
			
			
	time_in_state = time_in_state + delta
	

func _process(delta):
	do_animations(delta)
	
	var global_pos = self.global_transform.origin
	var target_pos = target.global_transform.origin
	var wtransform = self.global_transform.looking_at(Vector3(target_pos.x, global_pos.y, target_pos.z), Vector3.UP)
	var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rot_speed)
	if chasing:
		if $"../Player" != null and $"../Player".alpha >= 1.0:
			# face player
			global_pos = self.global_transform.origin
			target_pos = target.global_transform.origin
			wtransform = self.global_transform.looking_at(Vector3(target_pos.x, global_pos.y, target_pos.z), Vector3.UP)
			wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rot_speed)
			self.global_transform = Transform(Basis(wrotation), global_pos)
			
			var velocity = (target.global_transform.origin - global_transform.origin).normalized() * speed * 2 * delta
			
			move_and_collide(velocity)
		else:
			# Enemy looks at the player when they escape
			global_pos = self.global_transform.origin
			target_pos = target.global_transform.origin
			wtransform = self.global_transform.looking_at(Vector3(target_pos.x, global_pos.y, target_pos.z), Vector3.UP)
			wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rot_speed)
			self.global_transform = Transform(Basis(wrotation), global_pos)

		if not is_on_floor():
			move_and_collide(-global_transform.basis.y.normalized() * gravity * delta)
