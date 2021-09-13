extends Area2D


func _ready():
	pass # Replace with function body.


func _on_Area2D_area_entered(area):
	print(area.name)


func _on_Area2D_body_entered(body):
	if $Sprite/Fire.emitting:
		if "Maiale-Crudo" in body.name:
			var Cotto = load("res://Scenes/Maiale-Cotto.tscn").instance()
			Cotto.global_position = body.global_position
			get_node("/root/Node").call_deferred("add_child", Cotto)
			body.queue_free()
		if "Pollo-Crudo" in body.name:
			var Cotto = load("res://Scenes/Pollo-Cotto.tscn").instance()
			Cotto.global_position = body.global_position
			get_node("/root/Node").call_deferred("add_child", Cotto)
			body.queue_free()


func _on_Timer_timeout():
	$Sprite/Fire.emitting = false
	$Sprite/Fire/Smoke.emitting = false
