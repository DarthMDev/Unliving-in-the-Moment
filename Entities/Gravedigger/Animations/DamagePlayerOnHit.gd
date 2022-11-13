extends Area

var velocity = Vector3.ZERO
var lastPosition = Vector3.ZERO
var hitTimer = 0
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _process(delta):
	velocity = global_translation - lastPosition
	lastPosition = Vector3(global_translation.x, global_translation.y, global_translation.z)
	if hitTimer > 0:
		hitTimer -= delta

func _on_Area_body_entered(body: Node) -> void:
	if body is Player && $CollisionShape.disabled == false:
		if body.alpha >= 1.0 && hitTimer <= 0:
			body.damage(1)
			body.velocity = velocity * 50
			body.knockback_timer = 1.0
			hitTimer = 1.0
	pass # Replace with function body.
