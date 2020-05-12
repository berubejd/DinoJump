extends Area2D


func _ready():
	var _ret = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(_body):
	get_tree().call_group("Gamestate", "hurt")
