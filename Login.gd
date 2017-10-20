extends Node

var connection = null

var male_icon = load("res://client_data/icons/male.png")
var female_icon = load("res://client_data/icons/female.png")
var gender = 'male'

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connection = get_node("/root/global").connection
	
	get_node("PanelContainer/PopupPanel").popup_centered()
	
	get_node("PanelContainer/HBoxContainer/VBoxContainer/Gender").add_item("Male", 1)
	get_node("PanelContainer/HBoxContainer/VBoxContainer/Gender").add_item("Female", 2)
	get_node("PanelContainer/HBoxContainer/VBoxContainer/HairStyle").add_item("Plain Hair", 1)
	get_node("PanelContainer/HBoxContainer/VBoxContainer/HairStyle").add_item("Long Hair", 2)
	get_node("PanelContainer/HBoxContainer/VBoxContainer/HairColor").add_item("Brown", 1)
	get_node("PanelContainer/HBoxContainer/VBoxContainer/HairColor").add_item("Black", 2)
	get_node("PanelContainer/HBoxContainer/VBoxContainer/HairColor").add_item("Blonde", 3)
	get_node("PanelContainer/HBoxContainer/VBoxContainer/HairColor").add_item("White", 4)
	get_node("PanelContainer/HBoxContainer/VBoxContainer/Class").add_item("Fighter", 1) # Arm 0 Dam 1 Hit 0 HP 20 MP 10 
	get_node("PanelContainer/HBoxContainer/VBoxContainer/Class").add_item("Thief", 2) # Arm 0 Dam 1 Hit 1 HP 10 MP 10
	get_node("PanelContainer/HBoxContainer/VBoxContainer/Class").add_item("Mage", 3) # Arm 0 Dam 0 Hit 1 HP 10 MP 20
	get_node("PanelContainer/HBoxContainer/VBoxContainer/Class").add_item("Cleric", 4) # Arm 1 Dam 0 Hit 0 HP 15 MP 15

	set_process(true)

func try_connect():
	var ip = get_node("PanelContainer/PopupPanel/Hostname").get_text()
	var port = get_node("PanelContainer/PopupPanel/Port").get_text()
	
	print("Trying to connect to %s:%s" % [ip,port])
	
	connection.connect(ip,int(port))
	
	if connection.is_connected():
		get_player_options()
		return true
	else:
		return false

func try_enter_world():
	var name = get_node("PanelContainer/HBoxContainer/VBoxContainer/PlayerName").get_text()
	_send({"action": "createplayer", "name": name, "gender": gender })

func get_player_options():
	_send({"action": "getplayeroptions"})

func _process(delta):
	
	if connection.is_connected():
		var input_data = ""
		if connection.get_available_bytes() > 0:
			input_data += connection.get_string(connection.get_available_bytes())
	
		var data = {}
		data.parse_json(input_data)

		if not data.empty():
			
			if data['type'] == 'playeroptions':
				pass
			
			elif data['type'] == 'loginsucceeded':
				print("Starting Game!")
				get_node("/root/global").goto_scene("res://Client.tscn")
		

func _send(data):
	
	var ready_data = data.to_json() + "\r\n"
	
	connection.put_utf8_string(ready_data)

func _on_OptionButton_item_selected( ID ):
	if ID == 0:
		gender = 'male'
		get_node("PanelContainer/HBoxContainer/TextureFrame").set_texture(male_icon)
	elif ID == 1:
		gender = 'female'
		get_node("PanelContainer/HBoxContainer/TextureFrame").set_texture(female_icon)


func _on_ConnectButton_pressed():
	if try_connect():
		get_node("PanelContainer/PopupPanel").queue_free()
		
		get_player_options()


func _on_Enter_pressed():
	try_enter_world()
