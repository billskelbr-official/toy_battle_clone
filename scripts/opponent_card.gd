extends Node2D

var handpos
var inslot = 0
var team
var id

# !!! always call init after instantiating
func init(team_, id_):
	team = team_
	id = id_
	scale = Vector2(0.7, 0.7)
	var db = load("res://scripts/card_db.gd")
	var drawn = db.CARDS[id]
	var imgpath = "res://assets/textures/card/units/" + drawn[1].to_lower() + ".png"
	get_node("CardFront/CardImageUnit").texture = load(imgpath)
	get_node("CardImageBack").texture = load("res://assets/textures/card/back_"+str(3-team)+".png")
	get_node("CardFront/CardImageBase").texture = load("res://assets/textures/card/base_"+str(3-team)+".png")
	get_node("CardFront/PowerLabel").text = str(drawn[0])
	get_node("CardFront/NameLabel").text = str(drawn[1])
	get_node("CardFront/AbilityLabel").text = str(drawn[2])
	return self
