extends Control


func _ready():
	pass

func _process(delta):
	var file_ = File.new()
	if file_.file_exists(Global.file):
		$Continue.disabled = false

func _on_NewGame_button_down():
	get_tree().change_scene("res://Scenes/Main.tscn")
	Global.save = {
	"Entity" : {
		
	},
	"player" : {
		"x" : 0,
		"y" : 0,
		"vite" : 10,
		"stamina" : 100
	},
	"inventario" : {
		"1": {
			"Selected" : true,
			"Item" : "pugnale",
			"Count" : 3
		},
		"2": {
			"Selected" : false,
			"Item" : "",
			"Count" : 0
		},
		"3": {
			"Selected" : false,
			"Item" : "",
			"Count" : 0
		},
		"4": {
			"Selected" : false,
			"Item" : "",
			"Count" : 0
		},
		"5": {
			"Selected" : false,
			"Item" : "",
			"Count" : 0
		},
		"6": {
			"Selected" : false,
			"Item" : "",
			"Count" : 0
		},
		"7": {
			"Selected" : false,
			"Item" : "",
			"Count" : 0
		},
		"8": {
			"Selected" : false,
			"Item" : "",
			"Count" : 0
		}
	}
}


func _on_Continue_button_down():
	get_tree().change_scene("res://Scenes/Main.tscn")
	Global._load()


func _on_Exit_button_down():
	get_tree().quit()
