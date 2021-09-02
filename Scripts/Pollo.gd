extends KinematicBody2D

var FLOOR_NORMAL : = Vector2.UP

var life = 3

var gravity : = 1
var speed : = 45
var velocity : = Vector2()
var target_speed : = 0.0



onready var animated_sprite : Sprite = $Sprite as Sprite
onready var ray : RayCast2D = $RayCast2D as RayCast2D


func _process(delta: float) -> void:
	if life <= 0:
		var carne = load("res://Scenes/Pollo-Crudo.tscn").instance()
		carne.global_position = global_position
		get_node("/root/Node").add_child(carne)
		queue_free()
		
	$AnimationPlayer.play("Run")
	if velocity.x > 0:
		animated_sprite.flip_h = false
		$Sprite.position.x = 4
	elif velocity.x < 0:
		animated_sprite.flip_h = true
		$Sprite.position.x = -5


func _physics_process(delta: float) -> void:
	get_inputs()
	if !is_on_floor():
		FLOOR_NORMAL = Vector2.UP
		animated_sprite.flip_v = false
		velocity.y += gravity
		
	velocity.x = lerp(velocity.x, target_speed, .4)

	if abs(velocity.x) < 1:
		velocity.x = 0

	var snap : = Vector2.DOWN * 8
	velocity = move_and_slide_with_snap(velocity, snap, FLOOR_NORMAL)



func get_inputs() -> void:
	randomize()
	if ray.is_colliding():
		ray.cast_to *= -1
			
	target_speed = sign(ray.cast_to.x) * speed








func _on_HitBox_body_entered(body):
	if "pugnale" in body.name:
		life -= 1
		$AnimationPlayer2.play("Damage")


func _on_HitBox_area_entered(area):
	if "Melee" in area.name:
		life -= 1
		$AnimationPlayer2.play("Damage")


