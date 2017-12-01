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
var effect_scene = null

var client = null

# Ui stuff
var player_item_index = []
var player_quest_index = []
var equipped_color = null
var icons = {}
var hotbutton1_action = null
var hotbutton2_action = null
var hotbutton3_action = null
var hotbutton4_action = null


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	client = StreamPeerTCP.new()
	#client.connect('127.0.0.1',10000)
	#client = get_node("/root/global").connection

	# Load zones
	zones['overworld'] = preload('res://overworld.scn')
	
	# Load instance scenes
	character_scene = preload('res://Character.tscn')
	monster_scene = preload('res://Monster.tscn')
	container_scene = preload('res://Container.tscn')
	effect_scene = preload('res://Effect.tscn')
	
	set_process(true)
	set_process_unhandled_input(true)
	
	# Load icons
	icons['chain_hood'] = load('res://client_data/icons/chain_hood.png')
	icons['wand'] = load('res://client_data/icons/wand.png')
	icons['sword'] = load('res://client_data/icons/sword.png')
	icons['wood_sword'] = load('res://client_data/icons/swordWood.png')
	icons['spear'] = load('res://client_data/icons/spear.png')
	icons['bow'] = load('res://client_data/icons/bow.png')
	icons['chain'] = load('res://client_data/icons/chain_armor.png')
	icons['axe'] = load('res://client_data/icons/axe.png')
	icons['chain_hat'] = load('res://client_data/icons/chain_hat.png')
	icons['cloth_hood'] = load('res://client_data/icons/cloth_hood.png')
	icons['chain_armor'] = load('res://client_data/icons/chain_armor.png')
	icons['hammer'] = load('res://client_data/icons/hammer.png')
	icons['helmet'] = load('res://client_data/icons/helmet.png')
	icons['leather_armor'] = load('res://client_data/icons/leather_armor.png')
	icons['leather_cap'] = load('res://client_data/icons/leather_cap.png')
	icons['plate'] = load('res://client_data/icons/plate_armor.png')
	icons['blue_potion'] = load('res://client_data/icons/potionBlue.png')
	icons['red_potion'] = load('res://client_data/icons/potionRed.png')
	icons['green_potion'] = load('res://client_data/icons/potionGreen.png')
	icons['fire_lion'] = load('res://client_data/icons/fire_lion32.png')
	icons['earth_spike'] = load('res://client_data/icons/earth_spike32.png')
	icons['earth_spikes'] = load('res://client_data/icons/earth_spikes32.png')
	icons['lightning_claw'] = load('res://client_data/icons/lightning_claw.png')
	icons['snake_bite'] = load('res://client_data/icons/snake_bite32.png')
	icons['tornado'] = load('res://client_data/icons/tornado32.png')
	icons['turtle_shell'] = load('res://client_data/icons/turtle_shell32.png')
	icons['water_tentacles'] = load('res://client_data/icons/water_tentacle32.png')
	icons['ice_spike'] = load('res://client_data/icons/ice_spike32.png')
	icons['ice_spikes'] = load('res://client_data/icons/ice_spikes32.png')
	icons['ice_shield'] = load('res://client_data/icons/ice_shield32.png')
	
	get_node("ui/Connection").popup_centered()
	
	equipped_color = Color(0,0,255)
	
func _unhandled_input(event):
	if player_zone:
		if event.type == InputEvent.MOUSE_BUTTON:
			var pos = event.pos - get_viewport().get_canvas_transform().o
			var tile = get_node(player_zone + '/character').world_to_map(pos)
			if event.button_index == BUTTON_LEFT && !Input.is_mouse_button_pressed(BUTTON_LEFT):
				_send({'action': 'goto', 'x': tile.x, 'y': tile.y})
		elif event.type == InputEvent.KEY && !Input.is_key_pressed(event.scancode):
			if event.scancode == KEY_1:
				_send({'action': 'activate', 'ability_name': hotbutton1_action })
			elif event.scancode == KEY_2:
				_send({'action': 'activate', 'ability_name': hotbutton2_action })
			elif event.scancode == KEY_3:
				_send({'action': 'activate', 'ability_name': hotbutton3_action })
			elif event.scancode == KEY_4:
				_send({'action': 'activate', 'ability_name': hotbutton4_action })

func set_target(sig, target_name, target_type):
	_send({'action': 'settarget', 'target_type': target_type, 'target_name': target_name})

	for child in get_node(player_zone + '/character').get_children():
		child.set_is_target(false)
	
	if get_node(player_zone + '/character/').has_node(target_name):
		get_node(player_zone + '/character/' + target_name).set_is_target(true)
	
	
func get_gamestate():
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

func add_effect(name, target, animation, zone):
	if get_node(zone + '/character/' + target):
		var new_effect = effect_scene.instance()
		new_effect.set_name(name)
		new_effect.connect('effect_completed', self, 'cleanup_effect', [ name, target ])
		get_node(zone + '/character/' + target).add_child(new_effect)
		get_node(zone + '/character/' + target + '/' + name).set_animation(animation, target)
		get_node(zone + '/character/' + target + '/' + name).activate()
		

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
	_send({'action': 'getshopinv', 'name': name })

func load_abilities(abilities):
	
	var ability_index = 0
	get_node("ui/Abilities/AbilityItemList").clear()
	get_node("ui/Abilities/AbilityItemList").set_allow_rmb_select(true)
	for ability in abilities:
		var ability_data = abilities[ability]
		var ability_title = ability_data['title']
		var ability_icon = ability_data['icon']
		var ability_description = ability_data['description']
		
		get_node("ui/Abilities/AbilityItemList").add_item(ability_title, null, true)
		get_node("ui/Abilities/AbilityItemList").set_item_metadata(ability_index, ability_data)
		get_node("ui/Abilities/AbilityItemList").set_item_icon(ability_index, icons[ability_icon])
		get_node("ui/Abilities/AbilityItemList").set_item_tooltip(ability_index, ability_description)
		
		ability_index += 1
		
func load_inventory(inventory):
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
		var icon = item_data['icon']
		var item_tooltip = "%s\nDamage: %s\nHit: %s\nArmor: %s\nValue: %s" % [ item_title, item_dam, item_hit, item_arm, item_value ]
		get_node("ui/Inventory/InventoryItemList").add_item(item_title,null,true)
		get_node("ui/Inventory/InventoryItemList").set_item_metadata(item_index, item_data)
		get_node("ui/Inventory/InventoryItemList").set_item_tooltip(item_index, item_tooltip)
		get_node("ui/Inventory/InventoryItemList").set_item_icon(item_index, icons[icon])
		if item_data['equipped']:
			get_node("ui/Inventory/InventoryItemList").set_item_custom_bg_color(item_index, equipped_color)
		item_index += 1

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
		var icon = item_data['icon']
		var item_tooltip = "%s\nDamage: %s\nHit: %s\nArmor: %s\nValue: %s" % [ item_title, item_dam, item_hit, item_arm, item_value ]
		get_node("ui/ContainerInventory/ContainerItemList").add_item(item_title,null,true)
		get_node("ui/ContainerInventory/ContainerItemList").set_item_metadata(item_index, item_data)
		get_node("ui/ContainerInventory/ContainerItemList").set_item_tooltip(item_index, item_tooltip)
		get_node("ui/ContainerInventory/ContainerItemList").set_item_icon(item_index, icons[icon])
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
		var icon = item_data['icon']
		var item_tooltip = "%s\nDamage: %s\nHit: %s\nArmor: %s\nValue: %s" % [ item_title, item_dam, item_hit, item_arm, item_value ]
		get_node("ui/ShopInventory/ShopItemList").add_item(item_title,null,true)
		get_node("ui/ShopInventory/ShopItemList").set_item_metadata(item_index, item_data)
		get_node("ui/ShopInventory/ShopItemList").set_item_tooltip(item_index, item_tooltip)
		get_node("ui/ShopInventory/ShopItemList").set_item_icon(item_index, icons[icon])
		item_index += 1
		
		
	item_index = 0
	get_node("ui/ShopInventory/PlayerItemList").clear()
	get_node("ui/ShopInventory/PlayerItemList").set_allow_rmb_select(true)
	for item in player_inventory:
		var item_data = player_inventory[item]
		item_data['shop_name'] = shop_name
		item_data['name'] = item
		var item_title = "%s  %sg" % [item_data['title'], int(item_data['value']/2)]
		var item_dam = item_data['dam']
		var item_hit = item_data['hit']
		var item_arm = item_data['arm']
		var item_value = item_data['value']
		var icon = item_data['icon']
		var item_tooltip = "%s\nDamage: %s\nHit: %s\nArmor: %s\nValue: %s" % [ item_title, item_dam, item_hit, item_arm, item_value ]
		get_node("ui/ShopInventory/PlayerItemList").add_item(item_title,null,true)
		get_node("ui/ShopInventory/PlayerItemList").set_item_metadata(item_index, item_data)
		get_node("ui/ShopInventory/PlayerItemList").set_item_tooltip(item_index, item_tooltip)
		get_node("ui/ShopInventory/PlayerItemList").set_item_icon(item_index, icons[icon])
		item_index += 1
		
		
	get_node("ui/ShopInventory").popup_centered()
	get_node("ui/Inventory").hide()


func load_stats(stats):
	var title = stats['title']
	var level = stats['level']
	var hit = stats['hit']
	var dam = stats['dam']
	var arm = stats['arm']
	var spi = stats['spi']
	var gold = stats['gold']
	var hp = stats['hp']
	var mp = stats['mp']
	var expp = stats['exp']
	var playerclass = stats['playerclass']
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
	get_node("ui/Character/SPIValue").set_text(str(spi))
	get_node("ui/Character/PlayerClass").set_text(playerclass)
	
func load_quests(quests):
	print("Loading quests")

func attack():
	_send({"action": "attack"})
	
func _process(delta):
	
	if client.is_connected():
		var input_data = ""
		if client.get_available_bytes() > 0:
			input_data += client.get_string(client.get_available_bytes())
		
		var data = {}
		data.parse_json(input_data)

		if not data.empty():
			if data['type'] == 'authenticationfailed':
				print(data)
				
			elif data['type'] == 'playeroptions':
				set_playeroptions(data)
				if get_node("ui/Login").is_visible():
					get_node("ui/Login").hide()
					
				if get_node("ui/CharacterCreation").is_hidden():
					get_node("ui/CharacterCreation").popup_centered()
				
			elif data['type'] == 'entergame':
				get_node("ui/CharacterCreation").hide()
				get_gamestate()
				
			elif data['type'] == 'refresh':
				refresh(data)
			
			elif data['type'] == 'targetinfo':
				pass
				
			elif data['type'] == 'playerstats':
				load_stats(data['stats'])
					
			elif data['type'] == 'playerquests':
				load_quests(data['quests'])
						
			elif data['type'] == 'inventory':
				load_inventory(data['inventory'])
				
			elif data['type'] == 'abilities':
				load_abilities(data['abilities'])
			
			elif data['type'] == 'containerinventory':
				load_container_inventory(data['name'],data['title'],data['inventory'])
			
			elif data['type'] == 'shopinv':
				load_shop_inventory(data['name'],data['title'],data['inventory'], data['player_inventory'])
			
			elif data['type'] == 'message':
				get_node("ui/ChatPanel/ChatText").add_text("* " + data['message'])
				get_node("ui/ChatPanel/ChatText").newline()
				get_node("ui/ChatPanel/ChatText").set_scroll_follow(true)
			
			elif data['type'] == 'events':
				for event in data['events']:
					
					# We MUST have the zone for these event
					if event.has('zone'):
						if not get_node(event['zone']):
							get_gamestate()
							return
					
					if event['type'] == 'playerchat':
						var msg = "[%s] %s" % [event['title'], event['message']]
						get_node("ui/ChatPanel/ChatText").add_text(msg)
						get_node("ui/ChatPanel/ChatText").newline()
						get_node("ui/ChatPanel/ChatText").set_scroll_follow(true)
					
					elif event['type'] == 'monstermove':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).go(event['direction'], event['start'], event['end'])
						else:
							_send({'action': 'getmonster', 'name': event['name']})
						
					elif event['type'] == 'playermove':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).go(event['direction'], event['start'], event['end'])
						else:
							_send({'action': 'getplayer', 'name': event['name']})
					
					elif event['type'] == 'npcmove':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).go(event['direction'], event['start'], event['end'])
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
						if get_node(event['zone'] + '/character').has_node(event['name']):
							drop_character(event['name'], event['zone'])
						else:
							_send({'action': 'getplayer', 'name': event['name']})
							
					elif event['type'] == 'dropmonster':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							drop_monster(event['name'], event['zone'])
						else:
							_send({'action': 'getmonster', 'name': event['name']})
							
					elif event['type'] == 'dropnpc':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							drop_character(event['name'], event['zone'])
						else:
							_send({'action': 'getnpc', 'name': event['name']})
							
					elif event['type'] == 'dropcontainer':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							drop_container(event['name'], event['zone'])
						
					elif event['type'] == 'setplayerarmor':
						var p = get_node(event['zone'] + '/character/' + event['name'])
						if p:
							p.set_armor(event['armor'])
							#_send({'action': 'inventory'})
						else:
							_send({'action': 'getplayer', 'name': event['name']})
					
					elif event['type'] == 'setplayerweapon':
						var p = get_node(event['zone'] + '/character/' + event['name'])
						if p:
							p.set_weapon(event['weapon'])
							#_send({'action': 'inventory'})
						else:
							_send({'action': 'getplayer', 'name': event['name']})
					
					elif event['type'] == 'setplayerhead':
						var p = get_node(event['zone'] + '/character/' + event['name'])
						if p:
							p.set_head(event['head'])
							#_send({'action': 'inventory'})
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
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).thrust(event['hit'])
						else:
							_send({'action': 'getplayer', 'name': event['name']})
							
					elif event['type'] == 'playercast':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).cast(event['hit'])
						else:
							_send({'action': 'getplayer', 'name': event['name']})
							
					elif event['type'] == 'playerslash':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).slash(event['hit'])
						else:
							_send({'action': 'getplayer', 'name': event['name']})
							
					elif event['type'] == 'playerbow':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).bow(event['hit'])
						else:
							_send({'action': 'getplayer', 'name': event['name']})
							
					elif event['type'] == 'playerdie':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).die()
						else:
							_send({'action': 'getplayer', 'name': event['name']})
							
					elif event['type'] == 'npcthrust':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).thrust(event['hit'])
						else:
							_send({'action': 'getnpc', 'name': event['name']})
							
					elif event['type'] == 'npccast':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).cast(event['hit'])
						else:
							_send({'action': 'getnpc', 'name': event['name']})
							
					elif event['type'] == 'npcslash':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).slash(event['hit'])
						else:
							_send({'action': 'getnpc', 'name': event['name']})
							
					elif event['type'] == 'npcbow':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).bow(event['hit'])
						else:
							_send({'action': 'getnpc', 'name': event['name']})
							
					elif event['type'] == 'npcdie':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).die()
						else:
							_send({'action': 'getnpc', 'name': event['name']})
							
					elif event['type'] == 'monsterattack':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).attack(event['hit'])
						else:
							_send({'action': 'getmonster', 'name': event['name']})
							
					elif event['type'] == 'monsterdie':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).die()
						else:
							_send({'action': 'getmonster', 'name': event['name']})
							
					elif event['type'] == 'monsterdamage':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).set_healthbar(event['hp'])
							get_node(event['zone'] + '/character/' + event['name']).take_damage(event['damage'])
						else:
							_send({'action': 'getmonster', 'name': event['name']})
							
					elif event['type'] == 'monsterheal':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).set_healthbar(event['hp'])
							get_node(event['zone'] + '/character/' + event['name']).heal(event['heal'])
						else:
							_send({'action': 'getmonster', 'name': event['name']})
							
					elif event['type'] == 'npcdamage':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).set_healthbar(event['hp'])
							get_node(event['zone'] + '/character/' + event['name']).take_damage(event['damage'])
						else:
							_send({'action': 'getnpc', 'name': event['name']})
							
					elif event['type'] == 'npcheal':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							get_node(event['zone'] + '/character/' + event['name']).set_healthbar(event['hp'])
							get_node(event['zone'] + '/character/' + event['name']).heal(event['heal'])
						else:
							_send({'action': 'getnpc', 'name': event['name']})
							
					elif event['type'] == 'playerdamage':
						if get_node(event['zone'] + '/character').has_node(event['name']):
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
						else:
							_send({'action': 'getplayer', 'name': event['name']})
							
					elif event['type'] == 'playerheal':
						if get_node(event['zone'] + '/character').has_node(event['name']):
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
						else:
							_send({'action': 'getplayer', 'name': event['name']})
							
					elif event['type'] == 'playermpused':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							if event['name'] == player_name:
								var mp = event['mp']
								get_node("ui/MenuBar/HBoxContainer/VBoxContainer/ManaBar").set_value(mp[0])
								get_node("ui/MenuBar/HBoxContainer/VBoxContainer/ManaBar").set_max(mp[1])
								get_node("ui/MenuBar/HBoxContainer/VBoxContainer/ManaBar").set_tooltip("%s/%s" % mp)
						
					elif event['type'] == 'playermprestore':
						if get_node(event['zone'] + '/character').has_node(event['name']):
							if event['name'] == player_name:
								var mp = event['mp']
								get_node("ui/MenuBar/HBoxContainer/VBoxContainer/ManaBar").set_value(mp[0])
								get_node("ui/MenuBar/HBoxContainer/VBoxContainer/ManaBar").set_max(mp[1])
								get_node("ui/MenuBar/HBoxContainer/VBoxContainer/ManaBar").set_tooltip("%s/%s" % mp)
								
					
					elif event['type'] == 'addeffect':
						if get_node(event['zone'] + '/character').has_node(event['target']):
							add_effect(event['name'], event['target'], event['animation'], event['zone'])

						
					else:
						print(event)
			else:
				print(data)
	

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
	if item['consumeable'] == true:
		item_menu.add_item("Use",2)
	item_menu.connect("item_pressed", self, '_on_inventory_item_action', [item_name])
	get_node("ui/Inventory/InventoryItemList").add_child(item_menu)
	item_menu.popup()
	
func _on_inventory_item_action(index, item_name):
	if index == 0:
		_send({'action': 'equip', 'item': item_name })
	elif index == 1:
		_send({'action': 'drop', 'item': item_name })
	elif index == 2:
		_send({'action': 'use', 'item': item_name })
	elif index == 3:
		_send({'action': 'unequip', 'item': item_name })
	

# Login Process
func set_playeroptions(data):
	
	# Create Player
	get_node("ui/CharacterCreation/SelectGender").add_item("Male", 0)
	get_node("ui/CharacterCreation/SelectGender").add_item("Female", 1)
	
	get_node("ui/CharacterCreation/SelectHairStyle").add_item("Plain", 0)
	get_node("ui/CharacterCreation/SelectHairStyle").add_item("Long", 1)
	get_node("ui/CharacterCreation/SelectHairStyle").add_item("None", 2)
	
	get_node("ui/CharacterCreation/SelectHairColor").add_item("Black", 0)
	get_node("ui/CharacterCreation/SelectHairColor").add_item("Blonde", 1)
	get_node("ui/CharacterCreation/SelectHairColor").add_item("Brunette", 2)
	get_node("ui/CharacterCreation/SelectHairColor").add_item("White", 3)
	
	var idx = 0
	for pc in data['classes']:
		var meta = data['classes'][pc]
		var title = data['classes'][pc]['title']
		get_node("ui/CharacterCreation/SelectClass").add_item(title,idx)
		get_node("ui/CharacterCreation/SelectClass").set_item_metadata(idx,meta)
		idx += 1
	
	var idx = 0
	for c in data['characters']:
		var meta = data['characters'][c]
		var title = data['characters'][c]['title']
		get_node("ui/CharacterCreation/ExistingChar").add_item(title,idx)
		get_node("ui/CharacterCreation/ExistingChar").set_item_metadata(idx,meta)
		idx += 1

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
		get_node("ui/Login").popup_centered()

func _on_CreateChar_pressed():
	var name = get_node("ui/CharacterCreation/PlayerNameEntry").get_text()
	var sel_gender = get_node("ui/CharacterCreation/SelectGender").get_selected()
	var sel_hairstyle =  get_node("ui/CharacterCreation/SelectHairStyle").get_selected()
	var sel_haircolor =  get_node("ui/CharacterCreation/SelectHairColor").get_selected()
	var sel_class =  get_node("ui/CharacterCreation/SelectClass").get_selected()

	var gender = get_node("ui/CharacterCreation/SelectGender").get_item_text(sel_gender)
	var hairstyle = get_node("ui/CharacterCreation/SelectHairStyle").get_item_text(sel_hairstyle)
	var haircolor = get_node("ui/CharacterCreation/SelectHairColor").get_item_text(sel_haircolor)
	
	var pc_meta = get_node("ui/CharacterCreation/SelectClass").get_selected_metadata()
	print(pc_meta)
	
	_send({"action": "createplayer", "name": name, "gender": gender, "hairstyle": hairstyle, "haircolor": haircolor, "playerclass": pc_meta['name'] })

func _on_UseChar_pressed():
	var selected = get_node("ui/CharacterCreation/ExistingChar").get_selected()
	var meta = get_node("ui/CharacterCreation/ExistingChar").get_item_metadata(selected)
	_send({"action": "chooseplayer", "name": meta['name'] })

func _on_InventoryButton_pressed():
	if get_node("ui/Inventory").is_visible():
		get_node("ui/Inventory").hide()
	else:
		_send({'action': 'inventory' })
		get_node("ui/Inventory").show()
		get_node("ui/Abilities").hide()
		get_node("ui/Quests").hide()
		get_node("ui/Options").hide()
		get_node("ui/Character").hide()


func _on_AbilitiesButton_pressed():
	if get_node("ui/Abilities").is_visible():
		get_node("ui/Abilities").hide()
	else:
		_send({'action': 'abilities' })
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

func _on_CharacterButton_pressed():
	if get_node("ui/Character").is_visible():
		get_node("ui/Character").hide()
	else:
		_send({'action': 'playerstats' })
		get_node("ui/Character").show()
		get_node("ui/Inventory").hide()
		get_node("ui/Abilities").hide()
		get_node("ui/Quests").hide()
		get_node("ui/Options").hide()

func _on_ChatMenu_pressed():
	if get_node("ui/ChatPanel").is_visible():
		get_node("ui/ChatPanel").hide()
	else:
		get_node("ui/ChatPanel").show()


func _on_LoginButton_pressed():
	var username = get_node("ui/Login/Username").get_text()
	var password = get_node("ui/Login/Password").get_text()
	_send({'action': 'login', 'username': username, 'password': password })


func _on_RefreshButton_pressed():
	get_gamestate()


func _on_ContainerInventoryCloseButton_pressed():
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

func _on_AbilityItemList_item_rmb_selected( index, atpos ):
	var ability = get_node("ui/Abilities/AbilityItemList").get_item_metadata(index)
	var ability_name = ability['name']
	var ability_icon = ability['icon']
	var ability_menu = PopupMenu.new()
	ability_menu.set_pos(get_viewport().get_mouse_pos())
	ability_menu.add_item('Activate', 0)
	ability_menu.add_separator()
	ability_menu.add_item('Set to HotButton 1', 1)
	ability_menu.add_item('Set to HotButton 2', 2)
	ability_menu.add_item('Set to HotButton 3', 3)
	ability_menu.add_item('Set to HotButton 4', 4)
	ability_menu.connect("item_pressed", self, "_on_player_ability_item_action", [ability_name, ability_icon])
	get_node("ui/Abilities/AbilityItemList").add_child(ability_menu)
	ability_menu.popup()
	
	
func _on_shop_player_inventory_item_action(index, shop_name, item_name):
	if index == 0:
		_send({'action': 'sellitem', 'shop_name': shop_name, 'item_name': item_name })
		
func cleanup_effect(sig, foo, name, target):
	get_node(player_zone + '/character/' + target + '/' + name).queue_free()

func _on_player_ability_item_action(index, ability_name, ability_icon):
	if index == 0:
		_send({'action': 'activate', 'ability_name': ability_name })
	elif index == 1:
		hotbutton1_action = ability_name
		get_node('ui/MenuBar/HBoxContainer/HotButton1').set_button_icon(icons[ability_icon])
	elif index == 2:
		hotbutton2_action = ability_name
		get_node('ui/MenuBar/HBoxContainer/HotButton2').set_button_icon(icons[ability_icon])
	elif index == 3:
		hotbutton3_action = ability_name
		get_node('ui/MenuBar/HBoxContainer/HotButton3').set_button_icon(icons[ability_icon])
	elif index == 4:
		hotbutton4_action = ability_name
		get_node('ui/MenuBar/HBoxContainer/HotButton4').set_button_icon(icons[ability_icon])
		
func _on_HotButton1_pressed():
	if hotbutton1_action:
		_send({'action': 'activate', 'ability_name': hotbutton1_action })

func _on_HotButton2_pressed():
	if hotbutton2_action:
		_send({'action': 'activate', 'ability_name': hotbutton2_action })

func _on_HotButton3_pressed():
	if hotbutton3_action:
		_send({'action': 'activate', 'ability_name': hotbutton3_action })

func _on_HotButton4_pressed():
	if hotbutton4_action:
		_send({'action': 'activate', 'ability_name': hotbutton4_action })

func _on_ChatEntry_text_entered( text ):
	_send({'action': 'chat', 'message': text })
	get_node("ui/ChatPanel/ChatEntry").clear()




