extends KinematicBody2D

var FLOOR_NORMAL = Vector2.UP

var velocity = Vector2()
var target_speed = 0

var MAX_SPEED = 80
var GRAVITY = 10
var jump_speed = -200


var inventory = {
	1:{
		"Selected" : true,
		"Item" : "",
		"Count" : 0
	}
}



var body
var body_colliding = false

func _ready():
	for i in range(2, 9):
		inventory[i] = {
		"Selected" : false,
		"Item" : "",
		"Count" : 0
	}

 
func _physics_process(delta):
	if Input.is_action_just_pressed("LMB"):
		lancia_pugnale()
	pickup_item()
	
	
	animation()
	get_inputs()
	velocity.x = lerp(velocity.x, target_speed, 0.4)
	
	velocity.y += GRAVITY
	
	if abs(velocity.x) < 1:
		velocity.x = 0
	
	
	
	velocity = move_and_slide(velocity, FLOOR_NORMAL)


func get_inputs():
	target_speed = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")) * MAX_SPEED
	
	if Input.is_action_pressed("ui_up") and is_on_floor():
		velocity.y = jump_speed

func animation():
	if velocity.x < 0:
		$Sprite.flip_h = true

		$Hand.flip_h = true
		$Hand.position.x = -4
		$RayCast2D.cast_to.x = -10


		$WalkParticles.visible = true
		$WalkParticles.process_material.initial_velocity = 1000
		$WalkParticles.rotation_degrees = -33.4
	elif velocity.x > 0:
		$Sprite.flip_h = false

		$Hand.flip_h = false
		$Hand.position.x = 4
		$RayCast2D.cast_to.x = 10
		
		$WalkParticles.visible = true
		$WalkParticles.process_material.initial_velocity = -1000
		$WalkParticles.rotation_degrees = 19.2
	
	if velocity.y != 0:
		$WalkParticles.visible = false
#	print($Particles2D.process_material.scale)

	elif velocity.x > 0:
		$Sprite.flip_h = false
	
	
	if velocity.y < 0:
		$AnimationPlayer.play("Jump")
	if velocity.x != 0 and velocity.y == 0:
		$AnimationPlayer.play("Run")
	elif velocity.x == 0 and velocity.y == 0:
		$AnimationPlayer.play("Idle")

		$WalkParticles.visible = false


func lancia_pugnale():
	var pugnale = load("res://Scenes/Pugnale.tscn").instance()
	pugnale.position = self.position + $RayCast2D.cast_to.normalized()*3
	pugnale.apply_impulse(Vector2(), $RayCast2D.cast_to.normalized())
	if !$Sprite.flip_h:
		pugnale.linear_velocity.x = 100
	else:
		pugnale.linear_velocity.x = -100
		#individua lo sprite
		for i in pugnale.get_children():
			if i.name == "Sprite":
				#specchia lo sprite
				i.flip_h = true
	pugnale.linear_velocity.y = -10
	get_node("/root/Node").add_child(pugnale)



func inv_check(item):
	for i in inventory:
		if item == inventory[i]["Item"] and inventory[i]["Count"] < 20:
			return true
		if inventory[i]["Item"] == "":
			return true

func inv_add(item):
	for i in inventory:
		if item == inventory[i]["Item"] and inventory[i]["Count"] < 20:
			inventory[i]["Count"] += 1
			break
		if inventory[i]["Item"] == "":
			inventory[i]["Item"] = item
			inventory[i]["Count"] += 1
			break

func inv_remove(item):
	pass



func pickup_item():
	if body:
		if Input.is_action_just_pressed("Pick") and body.is_in_group("Drop") and inv_check(body.name):
			body.queue_free()
			if "pugnale" in body.name:
				inv_add("pugnale")
			else:
				inv_add(body.name)
			print(inventory)
			body = null

func Body_Entered(n_body):
	body_colliding = true
	body = n_body

func Body_Exited(body):
	body_colliding = false
