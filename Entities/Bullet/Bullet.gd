extends KinematicBody

export(int) var SPEED = 100
export (int) var dmg = 1

func init(start_translation: Vector3, start_rotation: Vector3):
	translation = start_translation
	rotation = start_rotation


func _physics_process(delta):
	# If collide with something
	var collision = move_and_collide(-global_transform.basis.z * SPEED * delta, true, false)
	if collision:
		if collision.collider is Player:
			collision.collider.damage(dmg)
		queue_free()
