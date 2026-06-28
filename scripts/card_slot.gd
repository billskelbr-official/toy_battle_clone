extends Node2D

const CARDSLOT_PREFIX = "../CardSlot"

@export var hq: int = 0
# hq = 0: base
# hq = 1: blue hq
# hq = 2: red hq
# hq = -1: blue discard pile
# hq = -2: red discard pile
@export var neighbour_paths: Array

var ref_battlemgr
var ref_msgbox
var ref_deck
var cards = []
var team
var id
var neighbours

# this is for cardslots used as discard piles because cardslot_init() is not called
func _ready() -> void:
	if (hq < 0):
		$CardSlotImage.texture = load("res://assets/textures/cardslots/discard.png")

# MUST be called for all non-discard cardslots (replaced _ready() function to allow setting exported
# vars in code). call this for ALL slots after ALL slots have been added to the board.
func cardslot_init() -> void:
	# these references are only needed by real cardslots (i.e. not the discard pile)
	if (hq >= 0):
		ref_battlemgr = $"../../../BattleManager"
		ref_msgbox = $"../../../MsgBox"
		ref_deck = $"../../../Deck"
	match (hq):
		# do nothing for 0, defaults to base.
		1:
			$"CardSlotImage".texture = load("res://assets/textures/cardslots/hq_blue.png")
		2:
			$"CardSlotImage".texture = load("res://assets/textures/cardslots/hq_red.png")
		-1, -2:
			$CardSlotImage.texture = load("res://assets/textures/cardslots/discard.png")
	neighbours = []
	for i in range(neighbour_paths.size()):
		neighbours.insert(0, get_node(CARDSLOT_PREFIX + neighbour_paths[i]))

func can_add_card(card) -> int:
	var visited = []
	var todo = []
	
	# discard piles have different parents, this is to avoid a crash
	if (hq < 0):
		return 0
	
	if ($"..".slots_disabled):
		ref_msgbox.show_msg("It is not your turn")
		return 0
	
	if (hq < 0):
		return 0
	
	if (card.team == hq):
		ref_msgbox.show_msg("Cannot play card on own HQ")
		return 0
	
	if (card.id != GAME_DB.CARDID_MONKEY):
		var hq_connected = 0
		todo = [self]
		while (todo.size()):
			var cur = todo[0]
			todo.erase(cur)
			visited.insert(0, cur)
			for i in range(cur.neighbours.size()):
				var nb = cur.neighbours[i]
				if (nb.hq == ref_battlemgr.whoami):
					hq_connected = 1
					break
				if (
					(nb.cards.size() and nb.cards[0].team == ref_battlemgr.whoami)
					and !(nb in visited || nb in todo)
				):
					todo.insert(0, nb)
		if (!hq_connected):
			ref_msgbox.show_msg("Base not connected to own HQ")
			return 0

	if (
		card.id != GAME_DB.CARDID_DUCK 
		and cards.size()
		and cards[0].team != ref_battlemgr.whoami
		and cards[0].power >= card.power
	):
		ref_msgbox.show_msg("Insufficient power")
		return 0
	return 1

func add_card(card):
	# make sure the newest card shows on top
	if (cards.size() > 0):
		cards[0].visible = 0
	card.get_node("Area2D/CollisionShape2D").disabled = 1
	card.z_index = -18
	card.rotation = rotation
	card.position = position
	card.scale = scale
	card.inslot = 1
	cards.insert(0, card)

func remove_card():
	if (!cards.size()):
		return
	cards[0].visible = 0
	cards.erase(cards[0])
	if (cards.size()):
		cards[0].visible = 1
