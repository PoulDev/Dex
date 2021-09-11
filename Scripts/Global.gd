extends Node


func _ready():
	pass

var show_collision = false

var ora = 0
var minuto = 0


var save = {
	"Orario": {
		"ora" : 6,
		"minuto" : 0
	},
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


var file = "user://_file3_.save"

func _save():
	var file_ = File.new()
	file_.open(file, File.WRITE)
	file_.store_var(save)
	file_.close()


func _load():
	var file_ = File.new()
	if file_.file_exists(file):
		file_.open(file, File.READ)
		save = file_.get_var()
		file_.close()
	else:
		save = {
	"Orario": {
		"ora" : 6,
		"minuto" : 0
	},
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
