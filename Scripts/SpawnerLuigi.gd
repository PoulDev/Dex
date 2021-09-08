extends Node2D


var rng = RandomNumberGenerator.new()

func _ready():
	$Timer.start()


func _on_Timer_timeout():
	if Global.save["Entity"].size() < 50:
		var luigi = load("res://Scenes/Luigi.tscn").instance()
	
		luigi.global_position = Vector2(position.x + rng.randf_range(0, 100), position.y)
		get_node("/root/Node").call_deferred("add_child", luigi)

		randomize()
		$Timer.wait_time = randi() % 40
		$Timer.start()

