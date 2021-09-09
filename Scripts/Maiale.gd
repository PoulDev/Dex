extends KinematicBody2D

var FLOOR_NORMAL : = Vector2.UP

var life = 3

var gravity : = 10
var speed : = 20
var velocity : = Vector2()

var scelta = "fermo"

onready var animated_sprite : Sprite = $Sprite as Sprite

func _process(delta: float) -> void:
	$view_collision.visible = Global.show_collision
	if life <= 0:
		var carne = load("res://Scenes/Maiale-Crudo.tscn").instance()
		carne.global_position = global_position
		get_node("/root/Node").add_child(carne)
		queue_free()
		
	$AnimationPlayer.play("Run")
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true

var unavolta = true

func _physics_process(delta: float) -> void:
	velocity.y += gravity
	
	
	if scelta == "fermo":
		velocity.x = 0
	
	elif scelta == "destra":
		velocity.x = 1 * speed
	
	elif scelta == "sinistra":
		velocity.x = -1 * speed
	
	elif scelta == "salta":
		if unavolta and is_on_floor():
			velocity.y = -100
			unavolta = false

	velocity = move_and_slide_with_snap(velocity, Vector2.UP, FLOOR_NORMAL)

	if velocity.x == 0:
		$AnimationPlayer.play("idle")
	else:
		$AnimationPlayer.play("Run")


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
	randomize()
	var rand = randi() % 4
	
	if rand == 0:
		scelta = "fermo"
	elif rand == 1:
		scelta = "destra"
	elif rand == 2:
		scelta = "sinistra"
	elif rand == 3:
		scelta = "salta"
	$fai_qualcosa_timer.start()


