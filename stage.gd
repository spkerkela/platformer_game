extends Node

onready	var enemies_count = $enemies.get_children().size()
onready var alive_enemies = enemies_count
func enemy_died():
	alive_enemies -= 1
	if alive_enemies == 0:
		get_node("/root/global").setScene("res://main_menu.tscn")
