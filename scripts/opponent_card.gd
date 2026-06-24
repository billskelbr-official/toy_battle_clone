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
	var drawn = GAME_DB.CARDS[id]
	var imgpath = "res://assets/textures/card/units/" + drawn[GAME_DB.CARD_IND_NAME].to_lower() + ".png"
	get_node("CardFront/CardImageUnit").texture = load(imgpath)
	get_node("CardImageBack").texture = load("res://assets/textures/card/back_"+str(3-team)+".png")
	get_node("CardFront/CardImageBase").texture = load("res://assets/textures/card/base_"+str(3-team)+".png")
	get_node("CardFront/PowerLabel").text = str(drawn[GAME_DB.CARD_IND_POWER])
	get_node("CardFront/NameLabel").text = str(drawn[GAME_DB.CARD_IND_NAME])
	get_node("CardFront/AbilityLabel").text = str(drawn[GAME_DB.CARD_IND_ABILITYDESC])
	return self
