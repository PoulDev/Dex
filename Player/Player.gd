extends KinematicBody2D

var FLOOR_NORMAL = Vector2.UP

var velocity = Vector2()
var target_speed = 0

var MAX_SPEED = 80
var GRAVITY = 10
var jump_speed = -200

var stamina = 100
var vita = 5
var rallentamento = 1 #false

var inventory = {
	"1":{
		"Selected" : true,
		"Item" : "pugnale",
		"Count" : 3
	},
	"2":{
		"Selected" : false,
		"Item" : "cocco",
		"Count" : 3
	}
	
}



var body
var body_colliding = false

func _ready():
	for i in range(3, 7):
		inventory[str(i)] = {
		"Selected" : false,
		"Item" : "",
		"Count" : 0
	}
	
	# test chat con npc: #ho capito perchè
	$"CanvasLayer/label-test/Timer".start()
	

var text = "ehy ciao come va?"
var current_text_num = 0
func TextTimeout():
	$"CanvasLayer/label-test".text += text[current_text_num]
	current_text_num += 1
	if current_text_num >= len(text):
		$"CanvasLayer/label-test/Timer".stop()

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
							c.visible = true
		
		# deselezziona la casella selezionata in precedenza
		if not inventory[i]["Selected"]:
			for child in $CanvasLayer/Inventory.get_children():
				if child.name == i:
					for c in child.get_children():
						if c.name == "Selected":
							c.visible = false

		# testo aggiornamento stamina e vita
		$CanvasLayer/infos.text = "stamina: " + str(int(stamina)) + " vita: " + str(vita)


func _physics_process(delta):
	var item_selected
	for i in inventory:
		if inventory[i]["Selected"]:
			item_selected = inventory[i]["Item"]
	if item_selected != "":
		$Hand.texture = load("res://Assets/" + item_selected + ".png")
	else:
		$Hand.texture = null
	if Input.is_action_just_pressed("RMB") and item_selected == "pugnale":
		stamina -= 1
		lancia_pugnale()
	
	if Input.is_action_just_pressed("LMB") and item_selected == "pugnale":
		stamina -= 1
		if $Hand.flip_h:
			$Hand/AnimationPlayer.play("Melee-left")
		else:
			$Hand/AnimationPlayer.play("Melee-right")
	
	pickup_item()
	for i in inventory:
		if inventory[i]["Selected"]:
			drop_item(i)
	
	animation()
	get_inputs()
	velocity.x = lerp(velocity.x, target_speed, 0.4)
	
	velocity.y += GRAVITY
	
	if abs(velocity.x) < 1:
		velocity.x = 0
	
	
	
	velocity = move_and_slide(velocity, FLOOR_NORMAL)


func get_inputs():
	if stamina <= 0:
		rallentamento = 2
		stamina = 0
	else:
		rallentamento = 1
	
	target_speed = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")) * ( MAX_SPEED / rallentamento )
	
	if int(target_speed) != 0:
		stamina -= 0.03
	
	if Input.is_action_pressed("ui_up") and is_on_floor() and stamina > 0:
		velocity.y = jump_speed
		stamina -= 1

	if Input.is_action_pressed("item_roll"):
		$Hand/AnimationPlayer.play("trick")

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
			pugnale.linear_velocity.x = 130
		else:
			pugnale.linear_velocity.x = -130
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

func inv_selected():
	for i in inventory:
		if inventory[i]["Selected"] == true:
			return i


var selected = 1
func select():
	if Input.is_action_just_released("RollUp"):
		if selected == 1:
			selected = 6
		else:
			selected -= 1
	if Input.is_action_just_released("RollDown"):
		if selected == 6:
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


func drop_item(item):
	if Input.is_action_just_pressed("Drop") and inventory[item]["Count"] > 0:
		inventory[item]["Count"] -= 1
		var drop = load("res://Scenes/" + inventory[item]["Item"] + ".tscn").instance()
		drop.position = self.position + $RayCast2D.cast_to.normalized()*3
		drop.apply_impulse(Vector2(), $RayCast2D.cast_to.normalized())
		if !$Sprite.flip_h:
			drop.linear_velocity.x = 20
		else:
			drop.linear_velocity.x = -20
			#individua lo sprite
			for i in drop.get_children():
				if i.name == "Sprite":
					#specchia lo sprite
					i.flip_h = true
		drop.linear_velocity.y = -10
		get_node("/root/Node").add_child(drop)
		



func Body_Entered(n_body):
	body_colliding = true
	body = n_body

func Body_Exited(body):
	body_colliding = false



