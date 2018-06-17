extends Area2D

var taken=false

signal coin_taken

func _on_coin_body_enter( body ):
	if not taken and body is preload("res://player.gd"):
		$anim.play("taken")
		emit_signal("coin_taken")
		taken = true
