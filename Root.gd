extends Spatial

onready var GRAVEYARD_SCENE = load("res://Level/Graveyard.tscn")

var checkpoint := Vector3(0, 0, 40)
var heardSpeech := false

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)

func reload():
	get_child(0).queue_free()
	var new_graveyard = GRAVEYARD_SCENE.instance()
	add_child(new_graveyard)
