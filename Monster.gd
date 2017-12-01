extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var action = 'wait'
var direction = 'south'
var tempElapsed = 0
var title = 'Noname'
var dest = null

signal targeted

func set_monster(set_title, x, y, source):
	
	title = set_title
	
	set_pos(Vector2(x * 32, y * 32))
	dest = Vector2(x * 32, y * 32)
	
	var texture = load('res://client_data/' + source)
	
	get_node("Sprite").set_texture(texture)
	get_node("Title").set_text(title)
	
func set_healthbar(hp):
	if hp[0] < 0:
		hp[0] = 0
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
	var start = Vector2(0,-16)
	var end = start + Vector2(0,-32)
	get_node("StatusInfoTween").interpolate_property(get_node("StatusInfo"), 'rect/pos', start, end, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("StatusInfoTween").start()
	
func go(dir, start, end):
	dest = Vector2(end[0] * 32, end[1] * 32)
	direction = dir
	
	get_node("Sprite/AnimationPlayer").play("go_" + direction)
	get_node("Tween").interpolate_property(get_node("."),'transform/pos', get_pos(), dest, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	
func wait():
	get_node("Sprite/AnimationPlayer").play("wait_" + direction)

func attack(hit):
	get_node("Sprite/AnimationPlayer").play("attack_" + direction)
	
func die():
	pass

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)

func _process(delta):
	
	tempElapsed = tempElapsed + delta


func set_is_target(is_target):
	if is_target:
		get_node("Title").show()
	else:
		get_node("Title").hide()


func _on_Tween_tween_complete( object, key ):
	wait()


func _on_Area2D_input_event( viewport, event, shape_idx ):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_RIGHT && !Input.is_mouse_button_pressed(BUTTON_RIGHT):
			emit_signal('targeted', get_name())

func _on_StatusInfoTween_tween_complete( object, key ):
	get_node("StatusInfo").hide()
