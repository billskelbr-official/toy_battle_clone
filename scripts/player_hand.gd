extends Node2D

const CARD_WIDTH = 180
const HAND_Y = 950
const HAND_OFFSET = Vector2(0, 120)
const CARDSCENE_PATH = "res://scenes/card.tscn"

var ref_battlemgr
var ref_cardmgr
var hand = []
var screen_ctr_x

func _ready() -> void:
	# screen_ctr_x = get_viewport().size.x/2
	screen_ctr_x = 960 #1920/2
	ref_battlemgr = $"../BattleManager"
	ref_cardmgr=$"../CardManager"

func add_card_to_hand(card):
	hand.insert(0, card)
	update_hand_cardpos()

func remove_card_from_hand(card):
	if (!(card in hand)):
		return
	hand.erase(card)
	update_hand_cardpos()

func return_card_to_hand(card):
	animate_card_to_pos(card, card.handpos)

func update_hand_cardpos():
	for i in range(hand.size()):
		var newpos = Vector2(get_cardpos(i), HAND_Y)
		var card = hand[i]
		card.handpos = newpos + HAND_OFFSET
		return_card_to_hand(card)

func get_cardpos(ind):
	var totwidth = (hand.size()-1) * CARD_WIDTH
	@warning_ignore("integer_division")
	return screen_ctr_x + ind*CARD_WIDTH - totwidth/2

func animate_card_to_pos(card, dest):
	card.get_node("Area2D/CollisionShape2D").disabled = 1
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", dest, 0.1)
	card.get_node("Area2D/CollisionShape2D").disabled = 0

@rpc("any_peer")
func discard_at_ind(ind):
	var discardslot = get_node("../Discard" + str(ref_battlemgr.whoami))
	var card = hand[ind]
	animate_card_to_pos(card, discardslot.position)
	discardslot.add_card(card)
	remove_card_from_hand(card)
	ref_cardmgr.rpc("peer_play_card", ind, card.id, discardslot.get_path())

@rpc("any_peer")
func set_client_hand(arr):
	for c in arr:
		add_card_to_hand(preload(CARDSCENE_PATH).instantiate().init(ref_battlemgr.whoami, c))
