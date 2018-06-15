extends Node

onready	var enemies_count = $enemies.get_children().size()
func _process(delta):
	var alive_enemies = 0
	for i in range(enemies_count):
		if ($enemies.get_child(i)):
			alive_enemies += 1
	if alive_enemies == 0:
		get_node("/root/global").setScene("res://main_menu.tscn")


