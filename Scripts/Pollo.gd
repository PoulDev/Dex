extends KinematicBody2D

var FLOOR_NORMAL : = Vector2.UP

var life = 3

var gravity : = 10
var speed : = 45
var velocity : = Vector2()

var rng = RandomNumberGenerator.new()

onready var animated_sprite : Sprite = $Sprite as Sprite

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
	if !is_on_floor():
		FLOOR_NORMAL = Vector2.UP
		animated_sprite.flip_v = false
		velocity.y += gravity
		

	if abs(velocity.x) < 1:
		velocity.x = 0
		
	velocity = move_and_slide(velocity*speed*delta, FLOOR_NORMAL)



func _on_HitBox_body_entered(body):
	if "pugnale" in body.name:
		life -= 1
		$AnimationPlayer2.play("Damage")
		velocity.y = -30


func _on_HitBox_area_entered(area):
	if "Melee" in area.name:
		life -= 1
		$AnimationPlayer2.play("Damage")
		velocity.y = -30




func _on_fai_qualcosa_timer_timeout():
	$fai_qualcosa_timer.start()
	randomize()
	var rand = randi() % 4

	if rand == 0:
		velocity.x = 0
		print("fermo")
	elif rand == 1:
		velocity.x = 50 * speed
		print("destra")
	elif rand == 2:
		velocity.x = -50 * speed
		print("sinistra")
	elif rand == 3:
		velocity.y = -100
		print("salta")
