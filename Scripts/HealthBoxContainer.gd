extends HBoxContainer

export(PackedScene) var life_object






func MaxLife(value : int):
	clear()
	for i in range(value/2):
		var obj = life_object.instance()
		add_child(obj)

func clear():
	for child in get_children():
		child.queue_free()


func UpdateLife(value : int):
	var containertoupdate = int(value/2)
	for i in range(get_child_count()):
		if i < containertoupdate:
			get_child(i).value = 2
		elif i == containertoupdate:
			get_child(i).value = value - (2 * i) 
		else:
			get_child(i).value = 0
