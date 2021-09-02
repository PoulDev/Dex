extends Area2D


func _ready():
	pass # Replace with function body.


func _on_Area2D_area_entered(area):
	print(area.name)


func _on_Area2D_body_entered(body):
	print(body.name)
	if "Maiale" in body.name:
		body.get_node("Sprite").texture = load("res://Assets/Maiale-Cotto.png")
