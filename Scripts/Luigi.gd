extends KinematicBody2D


var FLOOR_NORMAL = Vector2.UP

var velocity = Vector2()

var MAX_SPEED = 40
var GRAVITY = 10
var jump_speed = -170

var life = 3

var player_collided = false
var Attack = false

var player : KinematicBody2D

func _ready():
	pass

func _physics_process(delta):
	if player_collided:
		Attack = true
	animation()
	if life <= 0:
		var pugnale = load("res://Scenes/pugnale.tscn").instance()
		pugnale.global_position = global_position
		get_node("/root/Node").add_child(pugnale)
		queue_free()
	if player != null:
		if player.position.x > position.x:
			velocity.x = MAX_SPEED
		elif player.position.x < position.x:
			velocity.x = -MAX_SPEED
	else:
		velocity.x = 0
		
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR_NORMAL)

func animation():
	if velocity.x == 0 and !Attack:
		$AnimationPlayer.play("Idle")
	if !velocity.x == 0 and !Attack:
		$AnimationPlayer.play("Run")
	if Attack:
		$AnimationPlayer.play("Attack")
	
	if velocity.x < 0:
		$Sprite.flip_h = true
		$Attack/CollisionShape2D.position.x = -5.5
	
	if velocity.x > 0:
		$Sprite.flip_h = false
		$Attack/CollisionShape2D.position.x = 5.5


func _on_Range_body_entered(body):
	if body.name == "Player":
		player = body

func _on_Range_body_exited(body):
	if body.name == "Player":
		player = null



func _on_HitBox_body_entered(body):
	if "pugnale" in body.name:
		life -= 1
		$AnimationPlayer2.play("Damage")
	
	elif body.name == "Player":
		player_collided = true

func _on_HitBox_body_exited(body):
	if body.name == "Player":
		player_collided = false



func _on_HitBox_area_entered(area):
	if "Melee" in area.name:
		life -= 1
		$AnimationPlayer2.play("Damage")



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		Attack = false


