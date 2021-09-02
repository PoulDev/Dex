extends Node2D



func _ready():
	var pollo = load("res://Scenes/Pollo.tscn").instance()
	get_node("/root/Node").add_child(pollo)


func _on_Timer_timeout():
	var pollo = load("res://Scenes/Pollo.tscn").instance()
	get_node("/root/Node").add_child(pollo)
