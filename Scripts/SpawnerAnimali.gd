extends Node2D

var rng = RandomNumberGenerator.new()

func _ready():
	var pollo = load("res://Scenes/Pollo.tscn").instance()
	var maiale = load("res://Scenes/Maiale.tscn").instance()
	
	randomize()
	var rand = randi() % 2
	if rand == 0:
		pollo.global_position = Vector2(rng.randf_range(0, 100), 0)
		get_node("/root/Node").call_deferred("add_child", pollo)
	else:
		maiale.global_position = Vector2(rng.randf_range(0, 100), 0)
		get_node("/root/Node").call_deferred("add_child", maiale)
	$Timer.start()


func _on_Timer_timeout():
	randomize()
	$Timer.wait_time = randi() % 40
	var pollo = load("res://Scenes/Pollo.tscn").instance()
	var maiale = load("res://Scenes/Maiale.tscn").instance()
	
	randomize()
	var rand = randi() % 2
	if rand == 0:
		pollo.global_position = Vector2(rng.randf_range(0, 100), 0)
		get_node("/root/Node").call_deferred("add_child", pollo)
	else:
		maiale.global_position = Vector2(rng.randf_range(0, 100), 0)
		get_node("/root/Node").call_deferred("add_child", maiale)
	$Timer.start()

