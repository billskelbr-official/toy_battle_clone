extends Node2D

var ref_battlemgr
var ref_carddb
var ref_cardmgr
var ref_deck
var ref_hand
var slots_disabled = 1

# this is for handling the golem power
var golem_active = 0
var golem_slot

func _ready() -> void:
	ref_carddb = load("res://scripts/card_db.gd")
	ref_cardmgr = $"../../CardManager"
	ref_battlemgr = $"../../BattleManager"
	ref_deck = $"../../Deck"
	ref_hand = $"../../PlayerHand"

func handle_card_ability(slot, card):
	match (card.id):
		ref_carddb.CARDID_DUCK, ref_carddb.CARDID_DINOSAUR, ref_carddb.CARDID_MONKEY:
			pass
		ref_carddb.CARDID_SOLDIER:
			# if size is 1, soldier is the only card in the hand
			if (ref_hand.hand.size() > 0):
				ref_deck.deck_disabled = 1
				# captured area check for soldier to update immediately
				$"../AreaManager".check_capture()
				return
		ref_carddb.CARDID_SKELETON:
			ref_deck.draw_card_mpwrapper()
			ref_deck.draw_card_mpwrapper()
		ref_carddb.CARDID_UNICORN:
			ref_deck.draw_card_mpwrapper()
		ref_carddb.CARDID_ROBOT:
			var opphandsz = $"../../Opponent/Hand".hand.size()
			if (opphandsz):
				var ind = randi_range(0, opphandsz-1)
				ref_hand.rpc("discard_at_ind", ind)
#				$"../../Opponent/Hand".remove_card_from_hand($"../../Opponent/Hand".hand[ind])
#				$"../../PlayerHand".rpc("remove_card_at_ind", ind)
		ref_carddb.CARDID_GOLEM:
			for nb in slot.neighbours:
				if (nb.cards.size() && nb.cards[0].team != ref_battlemgr.whoami):
					golem_active = 1
					golem_slot = slot
					ref_deck.deck_disabled = 1
					slots_disabled = 1
					return
	# captured area check for all other units
	next_turn_after_ability()

func on_slot_clicked(slot):
	if (golem_active):
		handle_golem_ability(slot)
	else:
		show_cards_in_slot(slot)

func handle_golem_ability(slot):
	if (!golem_active):
		return
	if (
		slot in golem_slot.neighbours
		and slot.cards.size()
		and slot.cards[0].team != ref_battlemgr.whoami
	):
		discard_from_slot(slot.get_path())
		rpc("discard_from_slot", slot.get_path())
		golem_active = 0
	else:
		return
	next_turn_after_ability()
	
func next_turn_after_ability():
	$"../AreaManager".check_capture()
	ref_battlemgr.end_turn()

func show_cards_in_slot(slot):
	var viewer = $"../../CardSlotViewer"
	viewer.show_cards(slot.cards)

@rpc("any_peer")
func discard_from_slot(slotpath):
	var slot = get_node(slotpath)
	var card = slot.cards[0]
	slot.remove_card()
	card.visible = 1
	var dest = $"../../Discard1" if card.team == 1 else $"../../Discard2"
	$"../../PlayerHand".animate_card_to_pos(card, dest.position)
	dest.add_card(card)
