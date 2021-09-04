extends Node2D

func _ready():
	pass # Replace with function body.


func _process(delta):
	$Player/CanvasLayer/dev.text = "Player X: " + str($Player.global_position.x) + " Y: " + str($Player.global_position.y) + "\nStamina: " + str($Player/CanvasLayer/Stamina.value) + "\nHealth: " + str($Player.vita)
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

	if Input.is_action_just_pressed("dev_info"):
		$Player/CanvasLayer/dev.visible = !$Player/CanvasLayer/dev.visible
