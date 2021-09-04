extends Node2D

func _ready():
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
