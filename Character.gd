extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var tempElapsed = 0
var gender = 'male'
var title = 'Noname'
var dest = null
var direction = 'south'
var base = 'res://client_data/Universal-LPC-spritesheet/'

signal targeted

func set_head(head):
	
	var head_tex = null
	
	if head == 'hat':
		head_tex = load(base + "head/caps/"+gender+"/leather_cap_"+gender+".png")
	elif head == 'clothhood':
		head_tex = load(base + "head/hoods/"+gender+"/cloth_hood_"+gender+".png")
	elif head == 'chainhood':
		head_tex = load(base + "head/hoods/"+gender+"/chain_hood_"+gender+".png")
	elif head == 'chainhat':
		head_tex = load(base + "head/helms/"+gender+"/chainhat_"+gender+".png")
	elif head == 'helm':
		head_tex = load(base + "head/helms/"+gender+"/metal_helm_"+gender+".png")
		
	get_node("head").set_texture(head_tex)
	
func set_weapon(weapon):
	
	var weapon_tex = null
	var ammo_tex = null
	var back_tex = null
	
	if weapon == 'bow':
		weapon_tex = load(base + "weapons/right hand/either/bow.png")
		back_tex = load(base + "behind_body/equipment/quiver.png")
		ammo_tex = load(base + "weapons/left hand/either/arrow.png")
	elif weapon == 'sword':
		ammo_tex = null
		weapon_tex = load(base + "weapons/right hand/"+gender+"/dagger_"+gender+".png")
	elif weapon == 'spear':
		ammo_tex = null
		weapon_tex = load(base + "weapons/right hand/"+gender+"/spear_"+gender+".png")
	elif weapon == 'wand':
		ammo_tex = null
		weapon_tex = load(base + "weapons/right hand/"+gender+"/woodwand_"+gender+".png")

	get_node("weapon").set_texture(weapon_tex)
	get_node("ammo").set_texture(ammo_tex)
	
func set_armor(armor):
	
	var hands_tex = null
	var torso_tex = null
	var legs_tex = null
	var feet_tex = null
	var shoulders_tex = null
	
	# Set armors texture
	if armor.begins_with('clothes'):
		var clothes = armor.split("_", true)
		var shirtcolor = 'white'
		var pantscolor = 'red'
		if clothes.size() > 2:
			shirtcolor = clothes[1]
			pantscolor = clothes[2]
		elif clothes.size() > 1:
			shirtcolor = clothes[1]
		if gender == 'male':
			torso_tex = load(base + '/torso/shirts/longsleeve/male/'+shirtcolor+'_longsleeve.png')
		elif gender == 'female':
			torso_tex = load(base + 'torso/shirts/sleeveless/female/'+shirtcolor+'_sleeveless.png')
		legs_tex = load(base + 'legs/pants/'+gender+'/'+pantscolor+'_pants_'+gender+'.png')
		feet_tex = load(base + 'feet/shoes/'+gender+'/black_shoes_'+gender+'.png')
	elif armor == 'leather':
		hands_tex = load(base + "hands/bracers/"+gender+"/leather_bracers_"+gender+".png")
		torso_tex = load(base + "torso/leather/chest_"+gender+".png")
		shoulders_tex = load(base + "torso/leather/shoulders_"+gender+".png")
		feet_tex = load(base + "feet/shoes/"+gender+"/black_shoes_"+gender+".png")
		legs_tex = load(base + "legs/pants/"+gender+"/white_pants_"+gender+".png")
	elif armor == 'chain':
		hands_tex = load(base + "hands/bracers/"+gender+"/leather_bracers_"+gender+".png")
		torso_tex = load(base + "torso/chain/mail_"+gender+".png")
		shoulders_tex = load(base + "torso/leather/shoulders_"+gender+".png")
		feet_tex = load(base + "feet/shoes/"+gender+"/black_shoes_"+gender+".png")
		legs_tex = load(base + "legs/pants/"+gender+"/white_pants_"+gender+".png")
	elif armor == 'plate':
		hands_tex = load(base + "hands/gloves/"+gender+"/metal_gloves_"+gender+".png")
		torso_tex = load(base + "torso/plate/chest_"+gender+".png")
		shoulders_tex = load(base + "torso/plate/arms_"+gender+".png")
		feet_tex = load(base + "feet/armor/"+gender+"/metal_boots_"+gender+".png")
		legs_tex = load(base + "legs/armor/"+gender+"/metal_pants_"+gender+".png")
		
	get_node("feet").set_texture(feet_tex)
	get_node("legs").set_texture(legs_tex)
	get_node("torso").set_texture(torso_tex)
		
func set_character(x, y, set_title, set_type, set_gender, body, armor, head, weapon, haircolor, hairstyle, villan):
	
	title = set_title
	gender = set_gender

	set_pos(Vector2(x * 32, y * 32))
	get_node("Title").set_text(title)
	
	if set_type == 'player':
		get_node("Title").set('cutom_color/font_color', Color(0.0, 255.0, 0.0))
	elif set_type == 'npc':
		if villan:
			get_node("Title").set('cutom_color/font_color', Color(255.0, 0.0, 0.0))
		else:
			get_node("Title").set('cutom_color/font_color', Color(0.0, 0.0, 255.0))
	
	var back_tex = null
	var body_tex = null
	var feet_tex = null
	var legs_tex = null
	var torso_tex = null
	var hands_tex = null
	var shoulders_tex = null
	var hair_tex = null
	var head_tex = null
	var weapon_tex = null
	var ammo_tex = null
	
	# Set body texture
	body_tex = load(base + '/body/' + gender + '/' + body + '.png')

	# Set hair texture
	if hairstyle == 'none':
		get_node("hair").set_texture(null)
	else:
		hair_tex = load(base + '/hair/' + gender + '/' + hairstyle + '/' + haircolor + '.png')
	
	# Set armors texture
	if armor.begins_with('clothes'):
		var clothes = armor.split("_", true)
		var shirtcolor = 'white'
		var pantscolor = 'red'
		if clothes.size() > 2:
			shirtcolor = clothes[1]
			pantscolor = clothes[2]
		elif clothes.size() > 1:
			shirtcolor = clothes[1]
		if gender == 'male':
			torso_tex = load(base + '/torso/shirts/longsleeve/male/'+shirtcolor+'_longsleeve.png')
		elif gender == 'female':
			torso_tex = load(base + 'torso/shirts/sleeveless/female/'+shirtcolor+'_sleeveless.png')
		legs_tex = load(base + 'legs/pants/'+gender+'/'+pantscolor+'_pants_'+gender+'.png')
		feet_tex = load(base + 'feet/shoes/'+gender+'/black_shoes_'+gender+'.png')
		
	elif armor == 'leather':
		hands_tex = load(base + "hands/bracers/"+gender+"/leather_bracers_"+gender+".png")
		torso_tex = load(base + "torso/leather/chest_"+gender+".png")
		shoulders_tex = load(base + "torso/leather/shoulders_"+gender+".png")
		feet_tex = load(base + "feet/shoes/"+gender+"/black_shoes_"+gender+".png")
		legs_tex = load(base + "legs/pants/"+gender+"/white_pants_"+gender+".png")
		
	elif armor == 'chain':
		hands_tex = load(base + "hands/bracers/"+gender+"/leather_bracers_"+gender+".png")
		torso_tex = load(base + "torso/chain/mail_"+gender+".png")
		shoulders_tex = load(base + "torso/leather/shoulders_"+gender+".png")
		feet_tex = load(base + "feet/shoes/"+gender+"/black_shoes_"+gender+".png")
		legs_tex = load(base + "legs/pants/"+gender+"/white_pants_"+gender+".png")
		
	elif armor == 'plate':
		hands_tex = load(base + "hands/gloves/"+gender+"/metal_gloves_"+gender+".png")
		torso_tex = load(base + "torso/plate/chest_"+gender+".png")
		shoulders_tex = load(base + "torso/plate/arms_"+gender+".png")
		feet_tex = load(base + "feet/armor/"+gender+"/metal_boots_"+gender+".png")
		legs_tex = load(base + "legs/armor/"+gender+"/metal_pants_"+gender+".png")
	
	if head == 'hat':
		head_tex = load(base + "head/caps/"+gender+"/leather_cap_"+gender+".png")
	elif head == 'clothhood':
		head_tex = load(base + "head/hoods/"+gender+"/cloth_hood_"+gender+".png")
	elif head == 'chainhood':
		head_tex = load(base + "head/hoods/"+gender+"/chain_hood_"+gender+".png")
	elif head == 'chainhat':
		head_tex = load(base + "head/helms/"+gender+"/chainhat_"+gender+".png")
	elif head == 'helm':
		head_tex = load(base + "head/helms/"+gender+"/metal_helm_"+gender+".png")

	if weapon == 'bow':
		if body == 'skeleton':
			weapon_tex = load(base + "weapons/right hand/either/bow_skeleton.png")
		else:
			weapon_tex = load(base + "weapons/right hand/either/bow.png")
		back_tex = load(base + "behind_body/equipment/quiver.png")
		ammo_tex = load(base + "weapons/left hand/either/arrow.png")
	elif weapon == 'sword':
		weapon_tex = load(base + "weapons/right hand/"+gender+"/dagger_"+gender+".png")
	elif weapon == 'spear':
		weapon_tex = load(base + "weapons/right hand/"+gender+"/spear_"+gender+".png")
	elif weapon == 'wand':
		weapon_tex = load(base + "weapons/right hand/"+gender+"/woodwand_"+gender+".png")

	get_node("back").set_texture(back_tex)
	get_node("body").set_texture(body_tex)
	get_node("feet").set_texture(feet_tex)
	get_node("legs").set_texture(legs_tex)
	get_node("torso").set_texture(torso_tex)
	get_node("hands").set_texture(hands_tex)
	get_node("shoulders").set_texture(shoulders_tex)
	get_node("hair").set_texture(hair_tex)
	get_node("head").set_texture(head_tex)
	get_node("weapon").set_texture(weapon_tex)
	get_node("ammo").set_texture(ammo_tex)
	
	wait()

func set_healthbar(hp):
	var ratio = float(hp[0])/float(hp[1])
	var color = Color(255.0 * (1.0-ratio), 255.0 * ratio, 0.0)
	get_node("Title/HealthBar").set_scale(Vector2(ratio,1.0))
	get_node("Title/HealthBar").set_color(color)
	
func heal(hp):
	get_node("StatusInfo").set_text("+%s" % hp)
	get_node("StatusInfo").set("custom_colors/font_color", Color(0.0,255.0,0.0))
	flash_statusinfo()
	
func take_damage(hp):
	get_node("StatusInfo").set_text("-%s" % hp)
	get_node("StatusInfo").set("custom_colors/font_color", Color(255.0,0.0,0.0))
	flash_statusinfo()

func flash_statusinfo():
	get_node("StatusInfo").show()
	var start = Vector2(-16, -16)
	var end = start + Vector2(0, -32)
	get_node("StatusInfoTween").interpolate_property(get_node("StatusInfo"), 'rect/pos', start, end, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	get_node("StatusInfoTween").start()
	
func go(dir, start, end):
	
	var s = Vector2(start[0], start[1]) * 32
	var e = Vector2(end[0], end[1]) * 32
	direction = dir
	
	get_node("Tween").interpolate_property(get_node("."),'transform/pos', get_pos(), e, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	get_node("Tween").start()

	get_node("body/AnimationPlayer").play("walk_" + direction)
	get_node("torso/AnimationPlayer").play("walk_" + direction)
	get_node("feet/AnimationPlayer").play("walk_" + direction)
	get_node("legs/AnimationPlayer").play("walk_" + direction)
	get_node("hands/AnimationPlayer").play("walk_" + direction)
	get_node("shoulders/AnimationPlayer").play("walk_" + direction)
	get_node("hair/AnimationPlayer").play("walk_" + direction)
	get_node("head/AnimationPlayer").play("walk_" + direction)
	get_node("weapon/AnimationPlayer").play("walk_" + direction)
	get_node("ammo/AnimationPlayer").play("walk_" + direction)

func wait():
	get_node("body/AnimationPlayer").play("wait_" + direction)
	get_node("torso/AnimationPlayer").play("wait_" + direction)
	get_node("feet/AnimationPlayer").play("wait_" + direction)
	get_node("legs/AnimationPlayer").play("wait_" + direction)
	get_node("hands/AnimationPlayer").play("wait_" + direction)
	get_node("shoulders/AnimationPlayer").play("wait_" + direction)
	get_node("hair/AnimationPlayer").play("wait_" + direction)
	get_node("head/AnimationPlayer").play("wait_" + direction)
	get_node("weapon/AnimationPlayer").play("wait_" + direction)
	get_node("ammo/AnimationPlayer").play("wait_" + direction)
	
func slash():
	get_node("body/AnimationPlayer").play("slash_" + direction)
	get_node("torso/AnimationPlayer").play("slash_" + direction)
	get_node("feet/AnimationPlayer").play("slash_" + direction)
	get_node("legs/AnimationPlayer").play("slash_" + direction)
	get_node("hands/AnimationPlayer").play("slash_" + direction)
	get_node("shoulders/AnimationPlayer").play("slash_" + direction)
	get_node("hair/AnimationPlayer").play("slash_" + direction)
	get_node("head/AnimationPlayer").play("slash_" + direction)
	get_node("weapon/AnimationPlayer").play("slash_" + direction)
	get_node("ammo/AnimationPlayer").play("slash_" + direction)

func set_is_target(is_target):
	if is_target:
		get_node("Title").show()
	else:
		get_node("Title").hide()
	

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)

func _process(delta):
	
	tempElapsed = tempElapsed + delta
	
func _on_Tween_tween_complete( object, key ):
	wait()


func _on_Area2D_input_event( viewport, event, shape_idx ):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_RIGHT && !Input.is_mouse_button_pressed(BUTTON_RIGHT):
			
			emit_signal('targeted', get_name())

func _on_StatusInfoTween_tween_complete( object, key ):
	get_node("StatusInfo").hide()

