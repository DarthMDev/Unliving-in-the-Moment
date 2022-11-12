extends Timer

func setInvisible():
	get_parent().visible = false
	start()


func _on_Timer_timeout():
	get_parent().visible = true
