extends Node2D

@export var num_coins = 0
@export var border_names = []

var ref_battlemgr
var borders = []
var available = 1

func _ready() -> void:
	ref_battlemgr = $"../../../BattleManager"
	if (!num_coins):
		return
	$Sprite2D.texture = load("res://assets/textures/coins/coin" + str(num_coins) + ".png")
	for s in border_names:
		borders.append(get_node("../../CardSlotManager/CardSlot" + s))

# returns 0 if no one captured it and the capturer otherwise
func check_capture():
	if (!available):
		return
		
	var capturer
	if (!borders[0].cards.size()):
		if (borders[0].hq):
			capturer = borders[0].hq
		else:
			return
	else:
		capturer = borders[0].cards[0].team
	
	for i in range(1, borders.size()):
		if (borders[i].hq == ref_battlemgr.whoami):
			continue
		if (!borders[i].cards.size() || borders[i].cards[0].team != capturer):
			return 
	# capturer has captured the area
	$"..".capture_money(capturer, self)
