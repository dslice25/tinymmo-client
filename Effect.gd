extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal effect_completed

# Animations
var animations = {}
var target = null

func _ready():
	animations['fire_lion'] = load('res://client_data/Extended LPC Magic Pack/magic_pack/sheets/firelion_down.png')
	animations['earth_spike'] = load('res://client_data/Extended LPC Magic Pack/magic_pack/sheets/earth_spike.png')
	animations['earth_spikes'] = load('res://client_data/Extended LPC Magic Pack/magic_pack/sheets/earth_spikes.png')
	animations['lightning_claw'] = load('res://client_data/Extended LPC Magic Pack/magic_pack/sheets/lightningclaw.png')
	animations['ice_spike'] = load('res://client_data/Extended LPC Magic Pack/magic_pack/sheets/ice_spike.png')
	animations['ice_spikes'] = load('res://client_data/Extended LPC Magic Pack/magic_pack/sheets/ice_spikes.png')
	animations['ice_tentacle'] = load('res://client_data/Extended LPC Magic Pack/magic_pack/sheets/icetacle.png')
	animations['snake_bite'] = load('res://client_data/Extended LPC Magic Pack/magic_pack/sheets/snakebite_side.png')
	animations['tornado'] = load('res://client_data/Extended LPC Magic Pack/magic_pack/sheets/tornado.png')
	animations['water_tentacle'] = load('res://client_data/Extended LPC Magic Pack/magic_pack/sheets/torrentacle.png')
	animations['turtle_shell'] = load('res://client_data/Extended LPC Magic Pack/magic_pack/sheets/turtleshell_front.png')
	animations['ice_shield'] = load('res://client_data/Extended LPC Magic Pack/magic_pack/sheets/iceshield.png')
	
	
	
	
func activate():
	get_node("Sprite/AnimationPlayer").play("activate")

func set_animation(name, set_target):
	get_node("Sprite").set_texture(animations[name])
	target = set_target
	
func _on_AnimationPlayer_finished():
	emit_signal('effect_completed', get_name(), target)
