extends Node2D

const HAND_COUNT = 8
const CARDSCENE_PATH = "res://scenes/card.tscn"
const STARTCARDS = [3, 4]
const ROUNDCARDS = 2

var ref_carddb
var ref_battlemgr
var deck = []
var deck_disabled = 1

func _ready() -> void:
	ref_battlemgr = $"../BattleManager"

func get_shuffled_deck():
	var ret = []
	ref_carddb = preload("res://scripts/card_db.gd")
	for i in range(ref_carddb.CARDS.size()):
		for j in range(ref_carddb.CARDS[i][3]):
			ret.append(i)
	ret.shuffle()
	ret.erase(ret[0])
	ret.erase(ret[0])
	return ret

func shuffle_deck():
	deck = get_shuffled_deck().duplicate()

func set_client_deck():
	var client_deck = get_shuffled_deck()
	$"../Opponent/Deck".deck = client_deck
	rpc("set_client_deck_rpc", client_deck, deck)

@rpc("authority")
func set_client_deck_rpc(clientdeck, hostdeck):
	deck = clientdeck
	$"../Opponent/Deck".deck = hostdeck

# draws a single card
func draw_card():
	if ($"../PlayerHand".hand.size() == HAND_COUNT):
		$"../MsgBox".show_msg("Hand full, cannot draw card")
		return
	
	if (deck.size() == 0):
		$"../MsgBox".show_msg("Deck empty, cannot draw card")
		return
	
	var drawn = deck[0]
	deck.erase(drawn)
	$RichTextLabel.text = "[font_size=48]" + str(deck.size()) + "[/font_size]"
	if (deck.size() == 0):
		$Area2D/CollisionShape2D.disabled = 1
		$DeckImage.visible = 0
		$RichTextLabel.visible = 0
		
	var cardscene = preload(CARDSCENE_PATH)
	var c = cardscene.instantiate().init(ref_battlemgr.whoami, drawn)
	$"../CardManager".add_child(c)
	c.position = position
	c.name = "card"
	$"../PlayerHand".add_card_to_hand(c)
	c.get_node("AnimationPlayer").play("cardflip")

# draws card on current side and display on opponent's side
func draw_card_mpwrapper():
	draw_card()
	rpc("draw_opp_card")

@rpc("any_peer")
func draw_opp_card():
	$"../Opponent/Deck".draw_card()

# when the card deck is clicked to draw cards
func draw_card_click():
	if (deck_disabled):
		$"../MsgBox".show_msg("Cannot draw cards now")
		return
		
	if ($"../PlayerHand".hand.size() == HAND_COUNT):
		$"../MsgBox".show_msg("Hand full, cannot draw card")
		return
	draw_card_mpwrapper()
	draw_card_mpwrapper()
	ref_battlemgr.end_turn()

# at start
@rpc("any_peer")
func draw_initial_hand():
	var num = STARTCARDS[ref_battlemgr.whoami - 1]
	for i in range(num):
		draw_card_mpwrapper()
