extends Node2D

var dev = false
var dizionario = {}


func _ready():
	$Orario.start()
	if Global.save["Entity"] != {}:
		for entity in Global.save["Entity"]:
			if "pollo" in entity:
				var child = load("res://Scenes/Pollo.tscn").instance()
				add_child(child)
				child.position = Vector2(Global.save["Entity"][entity]["x"], Global.save["Entity"][entity]["y"])
			elif "maiale" in entity:
				var child = load("res://Scenes/Maiale.tscn").instance()
				add_child(child)
				child.position = Vector2(Global.save["Entity"][entity]["x"], Global.save["Entity"][entity]["y"])
			elif "Luigi" in entity:
				var child = load("res://Scenes/Luigi.tscn").instance()
				add_child(child)
				child.position = Vector2(Global.save["Entity"][entity]["x"], Global.save["Entity"][entity]["y"])
			else:
				var child = load("res://Scenes/" + entity.replace("1234567890", "") + ".tscn").instance()
				add_child(child)
				child.position = Vector2(Global.save["Entity"][entity]["x"], Global.save["Entity"][entity]["y"])
			

func _physics_process(delta):
	Global.save["Entity"].clear()
	for child in get_children():
		if child.is_in_group("Save") or child.is_in_group("Drop"):
			dizionario[child.name] = {
				"x" : child.position.x,
				"y" : child.position.y
			}
		Global.save["Entity"] = dizionario
	$Player/CanvasLayer/dev.text = "Player X: " + str(int($Player.global_position.x)) + " Y: " + str(int($Player.global_position.y)) + "\nStamina: " + str($Player/CanvasLayer/Stamina.value) + "\nHealth: " + str($Player.vita)
	$Player/CanvasLayer/dev2.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS)) + "\nMemory Static: " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC)/1024/1024)) + " MB"
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

	if Input.is_action_just_pressed("dev_info"):
		$Player/CanvasLayer/dev.visible = dev
		$Player/CanvasLayer/dev2.visible = dev
		Global.show_collision = dev
		
		
		dev = !dev



func _on_Orario_timeout():
	if Global.minuto < 10:
		$Player/CanvasLayer/Orario.text = str(Global.ora) + ":0" + str(Global.minuto)
	else:
		$Player/CanvasLayer/Orario.text = str(Global.ora) + ":" + str(Global.minuto)
	if Global.ora < 10:
		$Player/CanvasLayer/Orario.text = "0" + str(Global.ora) + str(Global.minuto)
	else:
		$Player/CanvasLayer/Orario.text = str(Global.ora) + ":" + str(Global.minuto)
	if Global.ora < 10 and Global.minuto < 10:
		$Player/CanvasLayer/Orario.text = "0" + str(Global.ora) + ":0" + str(Global.minuto)
	else:
		$Player/CanvasLayer/Orario.text = str(Global.ora) + ":" + str(Global.minuto)
	Global.minuto += 1
	if Global.minuto >= 60:
		Global.minuto = 0
		Global.ora += 1
	if Global.ora >= 24:
		Global.ora = 0
	if Global.ora == 20 and Global.minuto == 0:
		$CanvasModulate/AnimationPlayer.play("Tramonto")
	elif Global.ora == 5 and Global.minuto == 32:
		$CanvasModulate/AnimationPlayer.play("Alba")
