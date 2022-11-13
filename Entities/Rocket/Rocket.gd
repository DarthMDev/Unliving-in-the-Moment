extends KinematicBody

export(int) var SPEED = 10
export(Array) var PARTICLES = []

onready var particle_timer = $ParticleTimer

func init(start_translation: Vector3, start_rotation: Vector3):
	translation = start_translation
	rotation = start_rotation


func _physics_process(delta):
	# If collide with something
	var collision = move_and_collide(global_transform.basis.z.rotated(Vector3(0, 1, 0), deg2rad(-90)) * SPEED * delta, true, false)
	if collision:
		
		axis_lock_motion_x = true
		axis_lock_motion_z = true
		$MeshInstance.visible = false
		$CollisionShape.disabled = true
		
		particle_timer.start()
		
		for particle in PARTICLES:
			get_node(particle).emitting = true
			


func _on_ParticleTimer_timeout():
	# Delete rocket after particles are done.
	queue_free()
