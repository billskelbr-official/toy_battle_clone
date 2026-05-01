extends Node2D

signal hoveron
signal hoveroff

var handpos
var inslot = 0
var team
var id
var power

# !!! always call init after instantiating
func init(team_, id_):
	team = team_
	id = id_
	scale = Vector2(0.7, 0.7)
	var db = load("res://scripts/card_db.gd")
	var drawn = db.CARDS[id]
	power = drawn[0]
	var imgpath = "res://assets/textures/card/units/" + drawn[1].to_lower() + ".png"
	get_node("CardImageBack").texture = load("res://assets/textures/card/back_"+str(team)+".png")
	get_node("CardFront/CardImageBase").texture = load("res://assets/textures/card/base_"+str(team)+".png")
	get_node("CardFront/CardImageUnit").texture = load(imgpath)
	get_node("CardFront/PowerLabel").text = "[font_size=30]" + str(drawn[0]) + "[/font_size]"
	get_node("CardFront/NameLabel").text = "[font_size=24]" + str(drawn[1]) + "[/font_size]"
	get_node("CardFront/AbilityLabel").text = "[font_size=14]" + str(drawn[2]) + "[/font_size]"
	return self

func _ready() -> void:
	get_parent().connect_card_signals(self)

func _process(_delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hoveron", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoveroff", self)
