extends Label


func _ready():
	self.text = str(get_parent().get_parent().MAX_HIT_POINTS)


func _on_player_health_changed(amount):
	self.text = str(amount)
	
