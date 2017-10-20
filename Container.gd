extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal targeted
signal open_container

var is_target = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func set_container(title, x, y):
	
	get_node("Title").set_text(title)
	set_pos(Vector2(x * 32, y * 32))

func set_is_target(is_target):
	if is_target:
		get_node("Title").show()
		is_target = true
	else:
		get_node("Title").hide()
		is_target = false

func _on_Area2D_input_event( viewport, event, shape_idx ):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_RIGHT && !Input.is_mouse_button_pressed(BUTTON_RIGHT):
			emit_signal('open_container', get_name())
			emit_signal('targeted', get_name())
