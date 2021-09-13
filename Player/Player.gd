extends KinematicBody2D

var FLOOR_NORMAL = Vector2.UP

var velocity = Vector2()
var target_speed = 0

var MAX_SPEED = 80
var GRAVITY = 10
var jump_speed = -200
var WallJump = 500
var JumpWall = 10
var gestione_particelle = 1
var movimenti = true

var stamina = 100
var vita = 10
var maxvita = 10
var rallentamento = 1 #false

var rng = RandomNumberGenerator.new()

var inventory = {
	"1":{
		"Selected" : true,
		"Item" : "pugnale",
		"Count" : 3
	}
}

var cibi = {
	"Pollo-Cotto" : {"stamina": 20, "vita": 1},
	"Pollo-Crudo" : {"stamina": 5, "vita": 0},
	"Maiale-Cotto" : {"stamina": 20, "vita": 1},
	"Maiale-Crudo" : {"stamina": 5, "vita": 0}
}

var body
var area
var body_colliding = false
var area_colliding = false

func _ready():
	if Global.save["player"]["vite"] <= 0:
		Global.save["player"]["vite"] = vita
	position = Vector2(Global.save["player"]["x"], Global.save["player"]["y"])
	vita = Global.save["player"]["vite"]
	stamina = Global.save["player"]["stamina"]
	Global.ora = Global.save["Orario"]["ora"]
	Global.minuto = Global.save["Orario"]["minuto"]

	
	
	inventory.clear()
	inventory = Global.save["inventario"]
	
	
	
	
	$AreaButton.visible = false
	$BodyButton.visible = false
	$CanvasLayer/HealthBoxContainer.MaxLife(maxvita)
	for i in range(2, 9):
		inventory[str(i)] = {
		"Selected" : false,
		"Item" : "",
		"Count" : 0
	}
	


func _process(delta):
	$view_collision.visible = Global.show_collision
	Global.save["player"]["x"] = position.x
	Global.save["player"]["y"] = position.y
	if Global.save["player"]["vite"] > 0:
		Global.save["player"]["vite"] = vita
	Global.save["player"]["stamina"] = stamina
	Global.save["inventario"] = inventory
	Global.save["Orario"]["ora"] = Global.ora
	Global.save["Orario"]["minuto"] = Global.minuto
	
	Global._save()
	if vita == 0:
		$DeadParticles/Timer.start()
		movimenti = false
		print("mlml")
		vita = -1
	
	if vita < -1:
		vita = -1
	$CanvasLayer/HealthBoxContainer.UpdateLife(vita)
	$CanvasLayer/Stamina.value = stamina
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




func _physics_process(delta):
	var item_selected = ""
	for i in inventory:
		if inventory[i]["Selected"]:
			item_selected = inventory[i]["Item"]
	
	if item_selected != "":
		$Hand.texture = load("res://Assets/" + item_selected + ".png")
	else:
		$Hand.texture = null

	if Input.is_action_just_pressed("RMB"):
		if item_selected == "pugnale" and stamina > 1:
			lancia_pugnale()
			stamina -= 1
	
	
	if Input.is_action_just_pressed("LMB"):
		if item_selected == "pugnale" and stamina > 1:
			stamina -= 1
			if $Hand.flip_h:
				$Hand/AnimationPlayer.play("Melee-left")
			else:
				$Hand/AnimationPlayer.play("Melee-right")
		
		elif item_selected in cibi and stamina < 100:
			stamina += cibi[item_selected]["stamina"]
			if vita < maxvita:
				vita += cibi[item_selected]["vita"]
			inv_remove(item_selected)
	
	pickup_item()
	for i in inventory:
		if inventory[i]["Selected"] and inventory[i]["Count"] > 0:
			drop_item(i)
	
	animation()
	if movimenti: get_inputs()
	velocity.x = lerp(velocity.x, target_speed, 0.4)
	
	velocity.y += GRAVITY
	
	if abs(velocity.x) < 1:
		velocity.x = 0
	
	
	
	velocity = move_and_slide(velocity, FLOOR_NORMAL)


func get_inputs():
	if stamina <= 0:
		rallentamento = 2
		stamina = 0
	elif stamina > 100:
		stamina = 100
	else:
		rallentamento = 1
	
	if Input.is_action_pressed("run_"):
		MAX_SPEED = 130
	else:
		MAX_SPEED = 80
	
	target_speed = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")) * ( MAX_SPEED / rallentamento )
	if int(target_speed) != 0:
		if MAX_SPEED == 80:
			stamina -= 0.008
		else:
			stamina -= 0.01
	if Input.is_action_pressed("ui_up") and is_on_floor() and stamina > 1:
		$AnimationPlayer.play("Jump")
		velocity.y = jump_speed
		stamina -= 1
	if Input.is_action_just_pressed("ui_up") and stamina > 1:
		$AnimationPlayer.play("Jump")
		if nextToWall():
			stamina -= 1
			velocity.y = jump_speed
			if not is_on_floor() and nextToRightWall():
				velocity.x += WallJump
				velocity.y -= JumpWall
			
			if not is_on_floor() and nextToLeftWall():
				velocity.x -= WallJump
				velocity.y -= JumpWall


	if nextToWall() and velocity.y > 30:
		$AnimationPlayer.play("WallJump")
		velocity.y = 30
		if nextToRightWall():
			$Sprite.flip_h = false
			$Hand.flip_h = false
			$Hand.position.x = 4
			$RayCast2D.cast_to.x = 10
			$WalkParticles.visible = true
			$WalkParticles.process_material.initial_velocity = -1000
			$WalkParticles.rotation_degrees = 19.2
		if nextToLeftWall():
			$Sprite.flip_h = true
			$Hand.flip_h = true
			$Hand.position.x = -4
			$RayCast2D.cast_to.x = -10
			$WalkParticles.visible = true
			$WalkParticles.process_material.initial_velocity = 1000
			$WalkParticles.rotation_degrees = -33.4

	if Input.is_action_just_pressed("item_roll"):
		rng.randomize()
		var random_animation = rng.randf_range(1, 4)
		if random_animation >= 2:
			if not $Sprite.flip_h:
				$Hand/AnimationPlayer.play("trick2")
			else:
				$Hand/AnimationPlayer.play("trick2 left")
		else:
			$Hand/AnimationPlayer.play("trick1")


#WALL JUMP
func nextToWall():
	return nextToRightWall() or nextToLeftWall()


func nextToRightWall():
	var collider = $Destra.get_collider()
	if collider != null:
		if not "Lama" in collider.name:
			return $Destra.is_colliding()

func nextToLeftWall():
	var collider = $Sinistra.get_collider()
	if collider != null:
		if not "Lama" in collider.name:
			return $Sinistra.is_colliding()
#FINE WALL JUMP

func animation():
	if velocity.x < 0:
		$Sprite.flip_h = true
		$Hand.flip_h = true
		$Hand.position.x = -4
		$RayCast2D.cast_to.x = -10
		
		if $RayParticles.is_colliding() and "Tilemap" in $RayParticles.get_collider().name:
			$WalkParticles.visible = true
			$WalkParticles.process_material.initial_velocity = 1000
			$WalkParticles.rotation_degrees = -33.4
	elif velocity.x > 0:
		$Sprite.flip_h = false
		$Hand.flip_h = false
		$Hand.position.x = 4
		$RayCast2D.cast_to.x = 10
		
		if $RayParticles.is_colliding() and "Tilemap" in $RayParticles.get_collider().name:
			$WalkParticles.visible = true
			$WalkParticles.process_material.initial_velocity = -1000
			$WalkParticles.rotation_degrees = 19.2
	
	if velocity.y != 0:
		$WalkParticles.visible = false

	elif velocity.x > 0:
		$Sprite.flip_h = false
	
	
	if velocity.x != 0 and is_on_floor():
		$AnimationPlayer.play("Run")
	elif velocity.x == 0 and is_on_floor():
		$AnimationPlayer.play("Idle")

		$WalkParticles.visible = false


func lancia_pugnale():
	if inventory[inv_selected()]["Count"] > 0:
		inventory[inv_selected()]["Count"] -= 1
		if inventory[inv_selected()]["Count"] <= 0:
			inventory[inv_selected()] = {"Selected" : true, "Item" : "","Count" : 0}
		var pugnale = load("res://Scenes/pugnale.tscn").instance()
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

func inv_remove(item):
	for i in inventory:
		if inventory[i]["Item"] == item:
				inventory[i]["Count"] -= 1
				if inventory[i]["Count"] <= 0:
					inventory[i]["Item"] = ""


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
	if body and body_colliding:
		if body.is_in_group("Drop"):
			$BodyButton.visible = true
		
		
		if Input.is_action_just_pressed("Pick") and body.is_in_group("Drop") and inv_check(body.name):
			if "pugnale" in body.name:
				inv_add("pugnale")
			elif "Maiale" in body.name:
				if "Crudo" in body.get_node("Sprite").texture.load_path:
					inv_add("Maiale-Crudo")
				else:
					inv_add("Maiale-Cotto")
			elif "Pollo" in body.name:
				if "Crudo" in body.get_node("Sprite").texture.load_path:
					inv_add("Pollo-Crudo")
				else:
					inv_add("Pollo-Cotto")
			body.queue_free()
			body = null
		
		if area and area_colliding:
			if Input.is_action_just_pressed("Pick") and "Spaghetto" in area.name:
				$scolapasta.visible = true
				area = null
	
	if !body_colliding:
		$BodyButton.visible = false
		
	if area and area_colliding:
		if area.name == "Falo":
			$AreaButton.visible = true
		if get_node("/root/Node/Falo/Sprite/Fire").emitting:
			$AreaButton.visible = false
		if "cartello" in area.name:
			$AreaButton.visible = false
			$CanvasLayer/text_area/chat_text.text = area.editor_description
		if "Falo" in area.name and Input.is_action_just_pressed("Pick"):
			get_node("/root/Node/Falo/Sprite/Fire").emitting = true
			get_node("/root/Node/Falo/Sprite/Fire/Smoke").emitting = true
			get_node("/root/Node/Falo/Timer").start()
	
	if !area_colliding:
		$AreaButton.visible = false

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
		if inventory[item]["Count"] <= 0:
			inventory[item]["Item"] = ""




func PickUp_Body_Entered(n_body):
	body_colliding = true
	body = n_body



func PickUp_Body_Exited(body):
	body_colliding = false
	body = null




func PickUp_area_entered(n_area):
	area_colliding = true
	area = n_area
	if "cartello" in area.name:
		$CanvasLayer/text_area/chat_text.visible = true
		$CanvasLayer/text_area.visible = true

func PickUp_area_exited(area):
	area_colliding = false
	if "cartello" in area.name:
		$CanvasLayer/text_area/chat_text.visible = false
		$CanvasLayer/text_area.visible = false



func _on_Hitbox_area_entered(area):
	if area.name == "Attack":
		vita -= 1


func _on_Hitbox_area_exited(area):
	pass # Replace with function body.






func on_vite_finite():
	print(gestione_particelle)
	if gestione_particelle == 1:
		$DeadParticles.emitting = true
		gestione_particelle = 2
		$DeadParticles/Timer.start()
	elif gestione_particelle == 2:
		self.visible = false
		gestione_particelle = 3
		$DeadParticles/Timer.start()
	elif gestione_particelle == 3:
		$DeadParticles.emitting = false
		gestione_particelle = 4
		$DeadParticles/Timer.wait_time = 0.1
		$DeadParticles/Timer.start()
	elif gestione_particelle == 4:
		Global.save["player"]["x"] = 0
		Global.save["player"]["y"] = 0
		$DeadParticles/Timer.stop()
		$DeadParticles/Timer.wait_time = 1.5
		var gestione_particelle = 1
		get_tree().reload_current_scene()
