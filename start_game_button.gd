extends Button

func _pressed():
	get_node("/root/global").setScene("res://stage.tscn")
