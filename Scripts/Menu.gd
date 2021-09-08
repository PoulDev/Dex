extends Control


func _ready():
	pass

func _process(delta):
	var file_ = File.new()
	if file_.file_exists(Global.file):
		$Continue.disabled = false

	var anim = $AnimationPlayer.get_animation("main")
	anim.set_loop(true)
	$AnimationPlayer.play("main")

func _on_NewGame_button_down():
	get_tree().change_scene("res://Scenes/Main.tscn")
	Global.save = {
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
	},
	"nemici":
		{
			"1": {"x": 537.259, "y": 131.638},
			"2": {"x": 585.259, "y": 131.638},
			"3": {"x": 593.259, "y": 88.638},
			"4": {"x": 822.565, "y": 297.785},
			"5": {"x": 1166.24, "y": 404.934},
			"6": {"x": 601.259, "y": 481.185},
		}
}



func _on_Continue_button_down():
	get_tree().change_scene("res://Scenes/Main.tscn")
	Global._load()

func _on_Exit_button_down():
	get_tree().quit()
