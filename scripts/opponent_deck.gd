extends Node2D

const HAND_COUNT = 8
const CARDSCENE_PATH = "res://scenes/opponent_card.tscn"

var ref_battlemgr
var deck = []
# this is for the soldier ability. it disables the deck so only card can be played
var deck_disabled = 0

func _ready() -> void:
	ref_battlemgr = $"../../BattleManager"

# draws a single card
func draw_card():
	if ($"../Hand".hand.size() == HAND_COUNT):
		return
	
	if (deck.size() == 0):
		return
	
	var drawn = deck[0]
	deck.erase(drawn)
	$"RichTextLabel".text = str(deck.size())
	if (deck.size() == 0):
		$DeckImage.visible = 0
		$RichTextLabel.visible = 0
		
	var cardscene = preload(CARDSCENE_PATH)
	var c = cardscene.instantiate().init(ref_battlemgr.whoami, drawn)
	$"../CardManager".add_child(c)
	c.position = position + Vector2(0, -120)
	c.name = "card"
	$"../Hand".add_card_to_hand(c)
