extends Node


var player_name = null
var player_zone = null
var need_refresh = true

# zones
var zones = {}
var players = {}

# player data
var character_scene = null
var monster_scene = null
var container_scene = null

var client = null

# Ui stuff
var player_item_index = []
var player_quest_index = []
var equipped_color = null
var icons = {}


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	client = StreamPeerTCP.new()
	#client.connect('127.0.0.1',10000)
	#client = get_node("/root/global").connection

	# Load zones
	zones['start'] = preload('res://zones/start.scn')
	zones['start2'] = preload('res://zones/start2.scn')
	
	# Load instance scenes
	character_scene = preload('res://Character.tscn')
	monster_scene = preload('res://Monster.tscn')
	container_scene = preload('res://Container.tscn')
	
	set_process(true)
	set_process_unhandled_input(true)
	
	# Load icons
	icons['chainhood'] = load('res://client_data/icons/chain_hood.png')
	icons['wand'] = load('res://client_data/icons/wand.png')
	icons['sword'] = load('res://client_data/icons/sword.png')
	icons['spear'] = load('res://client_data/icons/spear.png')
	icons['bow'] = load('res://client_data/icons/bow.png')
	icons['chain'] = load('res://client_data/icons/chain_armor.png')
	icons['axe'] = load('res://client_data/icons/axe.png')
	icons['chainhat'] = load('res://client_data/icons/chain_hat.png')
	icons['clothhood'] = load('res://client_data/icons/cloth_hood.png')
	icons['hammer'] = load('res://client_data/icons/hammer.png')
	icons['helmet'] = load('res://client_data/icons/helmet.png')
	icons['leather'] = load('res://client_data/icons/leather_armor.png')
	icons['plate'] = load('res://client_data/icons/plate_armor.png')
	icons['blue_potion'] = load('res://client_data/icons/potionBlue.png')
	icons['red_potion'] = load('res://client_data/icons/potionRed.png')
	icons['green_potion'] = load('res://client_data/icons/potionGreen.png')
	
	get_node("ui/Connection").popup_centered()
	
	equipped_color = Color(0,0,255)
	
func _unhandled_input(event):
	if player_zone:
		if event.type == InputEvent.MOUSE_BUTTON:
			var pos = event.pos - get_viewport().get_canvas_transform().o
			var tile = get_node(player_zone + '/character').world_to_map(pos)
			if event.button_index == BUTTON_LEFT && !Input.is_mouse_button_pressed(BUTTON_LEFT):
				_send({'action': 'goto', 'x': tile.x, 'y': tile.y})


func set_target(sig, target_name, target_type):
	_send({'action': 'settarget', 'target_type': target_type, 'target_name': target_name})

	for child in get_node(player_zone + '/character').get_children():
		child.set_is_target(false)

	get_node(player_zone + '/character/' + target_name).set_is_target(true)
	
	
func get_gamestate():
	print("REQUESTING REFRESH!")
	_send({"action": "refresh"})
	need_refresh = false

func refresh(data):
	for child in get_children():
		if child.get_name() != 'ui':
			child.queue_free()
	
	load_inventory(data['player_inventory']['inventory'])
	load_stats(data['player_stats']['stats'])
	load_quests(data['player_quests']['quests'])
	
	
	# Load zone
	player_zone = data['zone']
	player_name = data['player_name']
	
	var new_zone = zones[data['zone_source']].instance()
	new_zone.set_name(data['zone'])
	add_child(new_zone)
	
	# Load players
	for player in data['players']:
		var x = data['players'][player]['x']
		var y = data['players'][player]['y']
		var title = data['players'][player]['title']
		var gender = data['players'][player]['gender']
		var body = data['players'][player]['body']
		var armor = data['players'][player]['armor']
		var head = data['players'][player]['head']
		var weapon = data['players'][player]['weapon']
		var haircolor = data['players'][player]['haircolor']
		var hairstyle = data['players'][player]['hairstyle']
		var zone = data['players'][player]['zone']
		
		add_character(player, title, 'player', x, y, gender, body, armor, head, weapon, haircolor, hairstyle, zone, false, false, false)
	
	# Load npcs
	for npc in data['npcs']:
		var x = data['npcs'][npc]['x']
		var y = data['npcs'][npc]['y']
		var title = data['npcs'][npc]['title']
		var gender = data['npcs'][npc]['gender']
		var body = data['npcs'][npc]['body']
		var armor = data['npcs'][npc]['armor']
		var head = data['npcs'][npc]['head']
		var weapon = data['npcs'][npc]['weapon']
		var haircolor = data['npcs'][npc]['haircolor']
		var hairstyle = data['npcs'][npc]['hairstyle']
		var zone = data['npcs'][npc]['zone']
		var villan = data['npcs'][npc]['villan']
		var shop = data['npcs'][npc]['shop']
		var quest = data['npcs'][npc]['quest']
		
		add_character(npc, title, 'npc', x, y, gender, body, armor, head, weapon, haircolor, hairstyle, zone, villan, shop, quest)
		
	
	# Load monsters
	for monster in data['monsters']:
		var title = data['monsters'][monster]['title']
		var x = data['monsters'][monster]['x']
		var y = data['monsters'][monster]['y']
		var source = data['monsters'][monster]['source']
		var zone = data['monsters'][monster]['zone']
		
		add_monster(monster, title, x, y, source, zone)
		
	# TODO: container
	for container in data['containers']:
		var title = data['containers'][container]['title']
		var x = data['containers'][container]['x']
		var y = data['containers'][container]['y']
		var zone = data['containers'][container]['zone']
		
		add_container(container, title, x, y, zone)
	
	# Follow Player
	var player_node = get_node(player_zone + '/character/' + player_name)
	var cam = Camera2D.new()
	cam.set_name('PlayerCam')
	cam.set_limit(MARGIN_TOP, 0)
	cam.set_limit(MARGIN_LEFT, 0)
	var map_w = new_zone.get_node('ground').get_used_rect().end.x * 32
	var map_h = new_zone.get_node('ground').get_used_rect().end.y * 32
	cam.set_limit(MARGIN_BOTTOM, map_h)
	cam.set_limit(MARGIN_RIGHT, map_w)
	player_node.add_child(cam)
	cam.make_current()
	
	
func _send(data):

	var ready_data = data.to_json() + "\r\n"
	
	if client.get_status() == 2:
		client.put_utf8_string(ready_data)
	else:
		print("Not connected")

func add_container(name, title, x, y, zone):
	if get_node(zone + '/character'):
		var new_container = container_scene.instance()
		new_container.set_name(name)
		new_container.set_container(title, x, y)
		new_container.connect('targeted', self, 'set_target', [ name, 'container' ])
		new_container.connect('open_container', self, 'get_container_inventory', [ name ])
		get_node(zone + '/character').add_child(new_container)

func add_monster(name, title, x, y, source, zone):
	if get_node(zone + '/character'):
		var new_monster = monster_scene.instance()
		new_monster.set_name(name)
		new_monster.set_monster(title, x, y, source)
		new_monster.connect('targeted', self, 'set_target', [ name, 'monster' ])
		get_node(zone + '/character').add_child(new_monster)
	
func add_character(name, title, type, x, y, gender, body, armor, head, weapon, haircolor, hairstyle, zone, villan, shop, quest):
	if get_node(zone + '/character'):
		var new_character = character_scene.instance()
		new_character.set_name(name)
		new_character.set_character(x, y, title, type, gender, body, armor, head, weapon, haircolor, hairstyle, villan, shop, quest)
		new_character.connect('targeted', self, 'set_target', [ name, type ])
		new_character.connect('open_shop', self, 'get_shop_inventory', [ shop ])
		get_node(zone + '/character').add_child(new_character)

func drop_character(name, zone):
	get_node(zone + '/character/' + name).queue_free()
	
func drop_monster(name, zone):
	get_node(zone + '/character/' + name).queue_free()

func drop_container(name, zone):
	get_node(zone + '/character/' + name).queue_free()

func get_container_inventory(sig, name):
	_send({'action': 'getcontainerinv', 'name': name })
	
func take_container_item(sig, container_name, item_name):
	_send({'action': 'takecontaineritem', 'container_name': container_name, 'item_name': item_name})

func get_shop_inventory(sig, name):
	print("Getting shop inv")
	_send({'action': 'getshopinv', 'name': name })
	
func load_inventory(inventory):
	print("Loading inventory")
	var item_index = 0
	get_node("ui/Inventory/InventoryItemList").clear()
	get_node("ui/Inventory/InventoryItemList").set_allow_rmb_select(true)
	for item in inventory:
		var item_data = inventory[item]
		var item_title = item_data['title']
		var item_dam = item_data['dam']
		var item_hit = item_data['hit']
		var item_arm = item_data['arm']
		var item_value = item_data['value']
		var item_type = item_data['gear_type']
		var item_tooltip = "%s\nDamage: %s\nHit: %s\nArmor: %s\nValue: %s" % [ item_title, item_dam, item_hit, item_arm, item_value ]
		get_node("ui/Inventory/InventoryItemList").add_item(item_title,null,true)
		get_node("ui/Inventory/InventoryItemList").set_item_metadata(item_index, item_data)
		get_node("ui/Inventory/InventoryItemList").set_item_tooltip(item_index, item_tooltip)
		get_node("ui/Inventory/InventoryItemList").set_item_icon(item_index, icons[item_type])
		if item_data['equipped']:
			get_node("ui/Inventory/InventoryItemList").set_item_custom_bg_color(item_index, equipped_color)
		item_index += 1
	
	_send({'action': 'playerstats' })

func load_container_inventory(container_name, container_title, inventory):
	var item_index = 0
	get_node("ui/ContainerInventory/Label").set_text(container_title)
	get_node("ui/ContainerInventory/ContainerItemList").clear()
	get_node("ui/ContainerInventory/ContainerItemList").set_allow_rmb_select(true)
	for item in inventory:
		var item_data = inventory[item]
		item_data['container_name'] = container_name
		var item_title = item_data['title']
		var item_dam = item_data['dam']
		var item_hit = item_data['hit']
		var item_arm = item_data['arm']
		var item_value = item_data['value']
		var item_type = item_data['gear_type']
		var item_tooltip = "%s\nDamage: %s\nHit: %s\nArmor: %s\nValue: %s" % [ item_title, item_dam, item_hit, item_arm, item_value ]
		get_node("ui/ContainerInventory/ContainerItemList").add_item(item_title,null,true)
		get_node("ui/ContainerInventory/ContainerItemList").set_item_metadata(item_index, item_data)
		get_node("ui/ContainerInventory/ContainerItemList").set_item_tooltip(item_index, item_tooltip)
		get_node("ui/ContainerInventory/ContainerItemList").set_item_icon(item_index, icons[item_type])
		item_index += 1
		
		get_node("ui/ContainerInventory").popup_centered()
		
func load_shop_inventory(shop_name, shop_title, inventory, player_inventory):
	var item_index = 0
	get_node("ui/ShopInventory/Label").set_text(shop_title)
	get_node("ui/ShopInventory/ShopItemList").clear()
	get_node("ui/ShopInventory/ShopItemList").set_allow_rmb_select(true)
	for item in inventory:
		var item_data = inventory[item]
		item_data['shop_name'] = shop_name
		item_data['name'] = item
		var item_title = "%s  %sg" % [item_data['title'], item_data['value']]
		var item_dam = item_data['dam']
		var item_hit = item_data['hit']
		var item_arm = item_data['arm']
		var item_value = item_data['value']
		var item_type = item_data['gear_type']
		var item_tooltip = "%s\nDamage: %s\nHit: %s\nArmor: %s\nValue: %s" % [ item_title, item_dam, item_hit, item_arm, item_value ]
		get_node("ui/ShopInventory/ShopItemList").add_item(item_title,null,true)
		get_node("ui/ShopInventory/ShopItemList").set_item_metadata(item_index, item_data)
		get_node("ui/ShopInventory/ShopItemList").set_item_tooltip(item_index, item_tooltip)
		get_node("ui/ShopInventory/ShopItemList").set_item_icon(item_index, icons[item_type])
		item_index += 1
		
		
	item_index = 0
	get_node("ui/ShopInventory/PlayerItemList").clear()
	get_node("ui/ShopInventory/PlayerItemList").set_allow_rmb_select(true)
	for item in player_inventory:
		var item_data = player_inventory[item]
		print(item_data)
		item_data['shop_name'] = shop_name
		item_data['name'] = item
		var item_title = "%s  %sg" % [item_data['title'], int(item_data['value']/2)]
		var item_dam = item_data['dam']
		var item_hit = item_data['hit']
		var item_arm = item_data['arm']
		var item_value = item_data['value']
		var item_type = item_data['gear_type']
		var icon = item_data['icon']
		var item_tooltip = "%s\nDamage: %s\nHit: %s\nArmor: %s\nValue: %s" % [ item_title, item_dam, item_hit, item_arm, item_value ]
		get_node("ui/ShopInventory/PlayerItemList").add_item(item_title,null,true)
		get_node("ui/ShopInventory/PlayerItemList").set_item_metadata(item_index, item_data)
		get_node("ui/ShopInventory/PlayerItemList").set_item_tooltip(item_index, item_tooltip)
		get_node("ui/ShopInventory/PlayerItemList").set_item_icon(item_index, icons[item_type])
		item_index += 1
		
		
	get_node("ui/ShopInventory").popup_centered()


func load_stats(stats):
	var title = stats['title']
	var level = stats['level']
	var hit = stats['hit']
	var dam = stats['dam']
	var arm = stats['arm']
	var gold = stats['gold']
	var hp = stats['hp']
	var mp = stats['mp']
	var expp = stats['exp']
	var title_text = "%s (%s)" % [title, level]
	get_node("ui/MenuBar/HBoxContainer/PlayerTitle").set_text(title_text)
	
	# Update health bar
	get_node("ui/MenuBar/HBoxContainer/VBoxContainer/HealthBar").set_max(hp[1])
	get_node("ui/MenuBar/HBoxContainer/VBoxContainer/HealthBar").set_value(hp[0])
	get_node("ui/MenuBar/HBoxContainer/VBoxContainer/HealthBar").set_tooltip("%s/%s" % hp)
	get_node("ui/MenuBar/HBoxContainer/VBoxContainer/HealthBar").update()
	
	# update mana bar
	get_node("ui/MenuBar/HBoxContainer/VBoxContainer/ManaBar").set_max(mp[1])
	get_node("ui/MenuBar/HBoxContainer/VBoxContainer/ManaBar").set_value(mp[0])
	get_node("ui/MenuBar/HBoxContainer/VBoxContainer/ManaBar").set_tooltip("%s/%s" % mp)
	get_node("ui/MenuBar/HBoxContainer/VBoxContainer/ManaBar").update()
	
	# Update character panel
	get_node("ui/Character/CharacterLabel").set_text(title)
	get_node("ui/Character/MPValue").set_text(str(mp[1]))
	get_node("ui/Character/HPValue").set_text(str(hp[1]))
	get_node("ui/Character/GoldValue").set_text(str(gold))
	get_node("ui/Character/EXPValue").set_text(str(expp))
	get_node("ui/Character/LevelValue").set_text(str(level))
	get_node("ui/Character/HitValue").set_text(str(hit))
	get_node("ui/Character/DAMValue").set_text(str(dam))
	get_node("ui/Character/ARMValue").set_text(str(arm))
	
func load_quests(quests):
	print("Loading quests")

func attack():
	print("Attacking target with weapon")
	_send({"action": "attack"})
	
func get_npc_dialog():
	print("Getting NPC dialog")
	_send({"action": "get_npc_dialog"})

func _process(delta):
	
	if client.is_connected():
		var input_data = ""
		if client.get_available_bytes() > 0:
			input_data += client.get_string(client.get_available_bytes())
		
		var data = {}
		data.parse_json(input_data)

		if not data.empty():
			if data['type'] == 'playeroptions':
				print(data)
				set_playeroptions(data)
				if not get_node("ui/CharacterCreation").is_visible():
					get_node("ui/CharacterCreation").popup_centered()
				
			elif data['type'] == 'loginsucceeded':
				print(data)
				get_node("ui/CharacterCreation").queue_free()
				get_gamestate()
				
			elif data['type'] == 'refresh':
				#print(data)
				refresh(data)
			
			elif data['type'] == 'playerstats':
				print(data)
				load_stats(data['stats'])
					
			elif data['type'] == 'playerquests':
				print(data)
				load_quests(data['quests'])
						
			elif data['type'] == 'inventory':
				print(data)
				load_inventory(data['inventory'])
			
			elif data['type'] == 'containerinventory':
				print(data)
				load_container_inventory(data['name'],data['title'],data['inventory'])
			
			elif data['type'] == 'shopinv':
				print(data)
				load_shop_inventory(data['name'],data['title'],data['inventory'], data['player_inventory'])
			
			elif data['type'] == 'events':
				for event in data['events']:
					if not event['type'] in ['monstermove','npcmove','playermove']:
						print(event)
					
					# We MUST have the zone for these event
					if event.has('zone'):
						if not get_node(event['zone']):
							print("No zone %s" % event['zone'])
							get_gamestate()
					
					if event['type'] == 'monstermove':
						var m = get_node(event['zone'] + '/character/' + event['name'])
						if m:
							m.go(event['direction'], event['start'], event['end'])
						else:
							_send({'action': 'getmonster', 'name': event['name']})
						
					elif event['type'] == 'playermove':
						var p = get_node(event['zone'] + '/character/' + event['name'])
						if p:
							p.go(event['direction'], event['start'], event['end'])
						else:
							_send({'action': 'getmonster', 'name': event['name']})
					
					elif event['type'] == 'npcmove':
						var n = get_node(event['zone'] + '/character/' + event['name'])
						if n:
							n.go(event['direction'], event['start'], event['end'])
						else:
							_send({'action': 'getnpc', 'name': event['name']})
					
					elif event['type'] == 'addmonster':
						
						add_monster(event['name'],
									event['title'], 
									event['x'], 
									event['y'], 
									event['source'], 
									event['zone'])
					
					elif event['type'] == 'addplayer':
						
						add_character(event['name'],
									  event['title'],
									  'player',
									  event['x'],
									  event['y'],
									  event['gender'],
									  event['body'],
									  event['armor'],
									  event['head'],
									  event['weapon'],
									  event['haircolor'],
									  event['hairstyle'],
									  event['zone'],
									  false,
									  false,
									  false)
									
					elif event['type'] == 'addnpc':
						
						add_character(event['name'],
									  event['title'],
									  'npc',
									  event['x'],
									  event['y'],
									  event['gender'],
									  event['body'],
									  event['armor'],
									  event['head'],
									  event['weapon'],
									  event['haircolor'],
									  event['hairstyle'],
									  event['zone'],
									  event['villan'],
									  event['shop'],
									  event['quest'])
					
					elif event['type'] == 'addcontainer':
						add_container(event['name'], 
									  event['title'], 
									  event['x'], 
									  event['y'], 
									  event['zone'])
					
					elif event['type'] == 'dropplayer':
						drop_character(event['name'], event['zone'])
					
					elif event['type'] == 'dropmonster':
						drop_monster(event['name'], event['zone'])
						
					elif event['type'] == 'dropnpc':
						drop_character(event['name'], event['zone'])
						
					elif event['type'] == 'dropcontainer':
						drop_container(event['name'], event['zone'])
						
					elif event['type'] == 'setplayerarmor':
						var p = get_node(event['zone'] + '/character/' + event['name'])
						if p:
							p.set_armor(event['armor'])
							_send({'action': 'inventory'})
						else:
							_send({'action': 'getplayer', 'name': event['name']})
					
					elif event['type'] == 'setplayerweapon':
						var p = get_node(event['zone'] + '/character/' + event['name'])
						if p:
							p.set_weapon(event['weapon'])
							_send({'action': 'inventory'})
						else:
							_send({'action': 'getplayer', 'name': event['name']})
					
					elif event['type'] == 'setplayerhead':
						var p = get_node(event['zone'] + '/character/' + event['name'])
						if p:
							p.set_head(event['head'])
							_send({'action': 'inventory'})
						else:
							_send({'action': 'getplayer', 'name': event['name']})
							
					elif event['type'] == 'playerstats':
						load_stats(event['stats'])
					
					elif event['type'] == 'playerquests':
						load_quests(event['quests'])
						
					elif event['type'] == 'inventory':
						load_inventory(event['inventory'])
					
					# COMBAT STUFF
					elif event['type'] == 'playerthrust':
						get_node(event['zone'] + '/character/' + event['name']).thrust()
					
					elif event['type'] == 'playerslash':
						get_node(event['zone'] + '/character/' + event['name']).slash()
					
					elif event['type'] == 'playerbow':
						get_node(event['zone'] + '/character/' + event['name']).bow()
						
					elif event['type'] == 'playerdie':
						get_node(event['zone'] + '/character/' + event['name']).die()
						
					elif event['type'] == 'npcthrust':
						get_node(event['zone'] + '/character/' + event['name']).thrust()
						
					elif event['type'] == 'npcslash':
						get_node(event['zone'] + '/character/' + event['name']).slash()
						
					elif event['type'] == 'npcbow':
						get_node(event['zone'] + '/character/' + event['name']).bow()
						
					elif event['type'] == 'npcdie':
						get_node(event['zone'] + '/character/' + event['name']).die()
						
					elif event['type'] == 'monsterattack':
						get_node(event['zone'] + '/character/' + event['name']).attack()
						
					elif event['type'] == 'monsterdie':
						get_node(event['zone'] + '/character/' + event['name']).die()
							
					elif event['type'] == 'monsterdamage':
						get_node(event['zone'] + '/character/' + event['name']).set_healthbar(event['hp'])
						get_node(event['zone'] + '/character/' + event['name']).take_damage(event['damage'])
						
					elif event['type'] == 'monsterheal':
						get_node(event['zone'] + '/character/' + event['name']).set_healthbar(event['hp'])
						get_node(event['zone'] + '/character/' + event['name']).heal(event['heal'])
					
					elif event['type'] == 'npcdamage':
						get_node(event['zone'] + '/character/' + event['name']).set_healthbar(event['hp'])
						get_node(event['zone'] + '/character/' + event['name']).take_damage(event['damage'])
					
					elif event['type'] == 'npcheal':
						get_node(event['zone'] + '/character/' + event['name']).set_healthbar(event['hp'])
						get_node(event['zone'] + '/character/' + event['name']).heal(event['heal'])
						
					
					elif event['type'] == 'playerdamage':
						get_node(event['zone'] + '/character/' + event['name']).set_healthbar(event['hp'])
						get_node(event['zone'] + '/character/' + event['name']).take_damage(event['damage'])
						
						if event['name'] == player_name:
							var hp = event['hp']
							var ratio = float(hp[0])/float(hp[1])
							var color = Color(255.0 * (1.0-ratio), 255.0 * ratio, 0.0)
							get_node("ui/MenuBar/HBoxContainer/VBoxContainer/HealthBar").set_value(hp[0])
							get_node("ui/MenuBar/HBoxContainer/VBoxContainer/HealthBar").set_max(hp[1])
							get_node("ui/MenuBar/HBoxContainer/VBoxContainer/HealthBar").set_tooltip("%s/%s" % hp)
							get_node("ui/MenuBar/HBoxContainer/VBoxContainer/HealthBar").get_stylebox('fg').set_bg_color(color)
							
						
					elif event['type'] == 'playerheal':
						get_node(event['zone'] + '/character/' + event['name']).set_healthbar(event['hp'])
						get_node(event['zone'] + '/character/' + event['name']).heal(event['heal'])
						
						
						if event['name'] == player_name:
							var hp = event['hp']
							var ratio = float(hp[0])/float(hp[1])
							var color = Color(255.0 * (1.0-ratio), 255.0 * ratio, 0.0)
							get_node("ui/MenuBar/HBoxContainer/VBoxContainer/HealthBar").set_value(hp[0])
							get_node("ui/MenuBar/HBoxContainer/VBoxContainer/HealthBar").set_max(hp[1])
							get_node("ui/MenuBar/HBoxContainer/VBoxContainer/HealthBar").set_tooltip("%s/%s" % hp)
							get_node("ui/MenuBar/HBoxContainer/VBoxContainer/HealthBar").get_stylebox('fg').set_bg_color(color)
							

						
					#else:
					#	print(event)
			#else:
			#	print(data)
	

func _on_InventoryItemList_item_rmb_selected( index, atpos ):
	var item = get_node("ui/Inventory/InventoryItemList").get_item_metadata(index)
	var item_name = item['name']
	var item_menu = PopupMenu.new()
	item_menu.set_pos(get_viewport().get_mouse_pos())
	if item['equipped'] == true:
		item_menu.add_item("Unequip",3)
	else:
		item_menu.add_item("Equip",0)
	item_menu.add_item("Drop",1)
	item_menu.add_item("Use",2)
	item_menu.connect("item_pressed", self, '_on_inventory_item_action', [item_name])
	get_node("ui/Inventory/InventoryItemList").add_child(item_menu)
	item_menu.popup()
	
func _on_inventory_item_action(index, item_name):
	if index == 0:
		_send({'action': 'equip', 'item': item_name })
		#_send({'action': 'inventory' })
	elif index == 1:
		_send({'action': 'drop', 'item': item_name })
		#_send({'action': 'inventory' })
	elif index == 2:
		_send({'action': 'use', 'item': item_name })
		#_send({'action': 'inventory' })
	elif index == 3:
		_send({'action': 'unequip', 'item': item_name })
		#_send({'action': 'inventory' })
	


# Login Process
func set_playeroptions(data):
	# Gender options
	get_node("ui/CharacterCreation/SelectGender").add_item("Male", 0)
	get_node("ui/CharacterCreation/SelectGender").add_item("Female", 1)
	
	get_node("ui/CharacterCreation/SelectHairStyle").add_item("Plain", 0)
	get_node("ui/CharacterCreation/SelectHairStyle").add_item("Long", 1)
	get_node("ui/CharacterCreation/SelectHairStyle").add_item("None", 2)
	
	get_node("ui/CharacterCreation/SelectHairColor").add_item("Black", 0)
	get_node("ui/CharacterCreation/SelectHairColor").add_item("Blonde", 1)
	get_node("ui/CharacterCreation/SelectHairColor").add_item("Brunette", 2)
	get_node("ui/CharacterCreation/SelectHairColor").add_item("White", 3)
	
	get_node("ui/CharacterCreation/SelectClass").add_item("Fighter", 0)
	get_node("ui/CharacterCreation/SelectClass").add_item("Mage", 1)
	get_node("ui/CharacterCreation/SelectClass").add_item("Thief", 2)
	get_node("ui/CharacterCreation/SelectClass").add_item("Cleric", 3)

func try_connect():
	var ip = get_node("ui/Connection/IPEntry").get_text()
	var port = get_node("ui/Connection/PortEntry").get_text()
	
	print("Trying to connect to %s:%s" % [ip,port])

	client.connect(ip,int(port))
	
	while client.get_status() == 1:
		# Wait for connection to complete or fail
		pass
	
	if client.get_status() != 2:
		return false
		
	return true

func _on_ConnectButton_pressed():
	if try_connect():
		get_node("ui/Connection").queue_free()


func _on_EnterButton_pressed():
	var name = get_node("ui/CharacterCreation/PlayerNameEntry").get_text()
	var sel_gender = get_node("ui/CharacterCreation/SelectGender").get_selected()
	var sel_hairstyle =  get_node("ui/CharacterCreation/SelectHairStyle").get_selected()
	var sel_haircolor =  get_node("ui/CharacterCreation/SelectHairColor").get_selected()
	var sel_class =  get_node("ui/CharacterCreation/SelectClass").get_selected()

	_send({"action": "createplayer", "name": name, "gender": sel_gender, "hairstyle": sel_hairstyle, "haircolor": sel_haircolor, "class": sel_class })



func _on_InventoryButton_pressed():
	if get_node("ui/Inventory").is_visible():
		get_node("ui/Inventory").hide()
	else:
		get_node("ui/Inventory").show()
		get_node("ui/Abilities").hide()
		get_node("ui/Quests").hide()
		get_node("ui/Options").hide()
		get_node("ui/Character").hide()


func _on_AbilitiesButton_pressed():
	if get_node("ui/Abilities").is_visible():
		get_node("ui/Abilities").hide()
	else:
		get_node("ui/Abilities").show()
		get_node("ui/Inventory").hide()
		get_node("ui/Quests").hide()
		get_node("ui/Options").hide()
		get_node("ui/Character").hide()

func _on_QuestsButton_pressed():
	if get_node("ui/Quests").is_visible():
		get_node("ui/Quests").hide()
	else:
		get_node("ui/Quests").show()
		get_node("ui/Inventory").hide()
		get_node("ui/Abilities").hide()
		get_node("ui/Options").hide()
		get_node("ui/Character").hide()

func _on_OptionsButton_pressed():
	if get_node("ui/Options").is_visible():
		get_node("ui/Options").hide()
	else:
		get_node("ui/Options").show()
		get_node("ui/Inventory").hide()
		get_node("ui/Abilities").hide()
		get_node("ui/Quests").hide()
		get_node("ui/Character").hide()

func _on_CharacterButton1_pressed():
	if get_node("ui/Character").is_visible():
		get_node("ui/Character").hide()
	else:
		get_node("ui/Character").show()
		get_node("ui/Inventory").hide()
		get_node("ui/Abilities").hide()
		get_node("ui/Quests").hide()
		get_node("ui/Options").hide()

func _on_RefreshButton_pressed():
	get_gamestate()

func _on_HotButton1_pressed():
	attack()

func _on_ContainerInventoryCloseButton_pressed():
	_send({'action': 'inventory' })
	get_node("ui/ContainerInventory").hide()


func _on_ContainerItemList_item_rmb_selected( index, atpos ):
	var item = get_node("ui/ContainerInventory/ContainerItemList").get_item_metadata(index)
	var item_name = item['name']
	var container_name = item['container_name']
	var item_menu = PopupMenu.new()
	item_menu.set_pos(get_viewport().get_mouse_pos())
	item_menu.add_item("Take",0)
	item_menu.connect("item_pressed", self, '_on_container_inventory_item_action', [container_name, item_name])
	get_node("ui/ContainerInventory/ContainerItemList").add_child(item_menu)
	item_menu.popup()

func _on_container_inventory_item_action(index, container_name, item_name):
	if index == 0:
		_send({'action': 'takecontaineritem', 'name': container_name, 'item_name': item_name })



func _on_ShopItemList_item_rmb_selected( index, atpos ):
	var item = get_node("ui/ShopInventory/ShopItemList").get_item_metadata(index)
	var item_name = item['name']
	var shop_name = item['shop_name']
	var item_menu = PopupMenu.new()
	item_menu.set_pos(get_viewport().get_mouse_pos())
	item_menu.add_item("Buy",0)
	item_menu.connect("item_pressed", self, '_on_shop_inventory_item_action', [shop_name, item_name])
	get_node("ui/ShopInventory/ShopItemList").add_child(item_menu)
	item_menu.popup()

func _on_shop_inventory_item_action(index, shop_name, item_name):
	if index == 0:
		_send({'action': 'buyshopitem', 'name': shop_name, 'item_name': item_name })

func _on_ShopInventoryCloseButton_pressed():
	_send({'action': 'inventory' })
	get_node("ui/ShopInventory").hide()

func _on_PlayerItemList_item_rmb_selected( index, atpos ):
	var item = get_node("ui/ShopInventory/PlayerItemList").get_item_metadata(index)
	var item_name = item['name']
	var shop_name = item['shop_name']
	var item_menu = PopupMenu.new()
	item_menu.set_pos(get_viewport().get_mouse_pos())
	item_menu.add_item("Sell",0)
	item_menu.connect("item_pressed", self, '_on_shop_player_inventory_item_action', [shop_name, item_name])
	get_node("ui/ShopInventory/PlayerItemList").add_child(item_menu)
	item_menu.popup()

func _on_shop_player_inventory_item_action(index, shop_name, item_name):
	if index == 0:
		_send({'action': 'sellitem', 'shop_name': shop_name, 'item_name': item_name })