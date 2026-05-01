extends Node2D

const CARD_WIDTH = 180
const HAND_Y = 130
const HAND_OFFSET = Vector2(0, -120)

var hand = []
var screen_ctr_x

func _ready() -> void:
	screen_ctr_x = get_viewport().size.x/2

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
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", dest, 0.1)
