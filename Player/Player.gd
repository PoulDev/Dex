extends KinematicBody2D

var FLOOR_NORMAL = Vector2.UP

var velocity = Vector2()
var target_speed = 0

var MAX_SPEED = 80
var GRAVITY = 10
var jump_speed = -200


var inventory = {
	"1":{
		"Selected" : true,
		"Item" : "pugnale",
		"Count" : 25
	}
}



var body
var body_colliding = false

func _ready():
	for i in range(2, 9):
		inventory[str(i)] = {
		"Selected" : false,
		"Item" : "",
		"Count" : 0
	}

func _process(delta):
	select()
	#	aggiornamento grafica hotbar
	for i in inventory:
		for child in $CanvasLayer/Inventory.get_children():
			if child.name == i:
				for c in child.get_children():
					if c.name == "Sprite":
						#se l'item esiste aggiunge la texture
						if inventory[i]["Count"] > 0:
							c.texture = load("res://Assets/" + inventory[i]["Item"] + ".png")
						else: #altrimenti la toglie
							c.texture = null
					#aggiorna il numero di item nella hotbar
					if c.name == "Count":
						if inventory[i]["Count"] > 0: 
							c.text = str(inventory[i]["Count"])
						else:
							c.text = ""
	for i in inventory:
		# aggiorna casella selezionata
		if inventory[i]["Selected"]:
			for child in $CanvasLayer/Inventory.get_children():
				if child.name == i:
					for c in child.get_children():
						if c.name == "Selected":
							print(c)
							c.visible = true
		
		# deselezziona la casella selezionata in precedenza
		if not inventory[i]["Selected"]:
			for child in $CanvasLayer/Inventory.get_children():
				if child.name == i:
					for c in child.get_children():
						if c.name == "Selected":
							print(c)
							c.visible = false



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
	if inventory[inv_selected()]["Count"] > 0:
		inventory[inv_selected()]["Count"] -= 1
		if inventory[inv_selected()]["Count"] <= 0:
			inventory[inv_selected()] = {"Selected" : true,	"Item" : "","Count" : 0}
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
	var trovato = false
	
	for inv_item in inventory:
		if item == inventory[inv_item]["Item"] and inventory[inv_item]["Count"] < 20:
			inventory[inv_item]["Count"] += 1
			trovato = true
			break

	if not trovato:
		for inv_item in inventory:
			if inventory[inv_item]["Item"] == "":
				inventory[inv_item]["Item"] = item
				inventory[inv_item]["Count"] += 1
				break


func inv_remove(item):
	pass

func inv_selected():
	for i in inventory:
		if inventory[i]["Selected"] == true:
			return i

var selected = 1
func select():
	if Input.is_action_just_released("RollUp"):
		if selected == 1:
			selected = 8
		else:
			selected -= 1
	if Input.is_action_just_released("RollDown"):
		if selected == 8:
			selected = 1
		else:
			selected += 1
	for i in inventory:
		if i == str(selected):
			inventory[i]["Selected"] = true
		else:
			inventory[i]["Selected"] = false
	

func pickup_item():
	if body:
		if Input.is_action_just_pressed("Pick") and body.is_in_group("Drop") and inv_check(body.name):
			body.queue_free()
			if "pugnale" in body.name:
				inv_add("pugnale")
			else:
				inv_add(body.name)
			body = null

func Body_Entered(n_body):
	body_colliding = true
	body = n_body

func Body_Exited(body):
	body_colliding = false
