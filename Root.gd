extends Spatial

onready var GRAVEYARD_SCENE = load("res://Level/Graveyard.tscn")

var counter = 0

func add():
	counter += 1

func reload():
	get_child(0).queue_free()
	var new_graveyard = GRAVEYARD_SCENE.instance()
	add_child(new_graveyard)
