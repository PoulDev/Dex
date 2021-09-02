extends CenterContainer

var value = 2 setget set_value, get_value

func set_value(new_value : int):
	$Heart.value = new_value
func get_value():
	return $Heart.value
