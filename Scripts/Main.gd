extends Node2D

func _ready():
	pass # Replace with function body.

var dev = false

func _physics_process(delta):
	$Player/CanvasLayer/dev.text = "Player X: " + str(int($Player.global_position.x)) + " Y: " + str(int($Player.global_position.y)) + "\nStamina: " + str($Player/CanvasLayer/Stamina.value) + "\nHealth: " + str($Player.vita)
	$Player/CanvasLayer/dev2.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS)) + "\nMemory Static: " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC)/1024/1024)) + " MB"
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

	if Input.is_action_just_pressed("dev_info"):
		$Player/CanvasLayer/dev.visible = dev
		$Player/CanvasLayer/dev2.visible = dev
	
		for child in self.get_children():
			if "maiale" in child.name or "pollo" in child.name:
				child.view_collisions(dev)
		
		dev = !dev
