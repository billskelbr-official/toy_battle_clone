extends Node2D

const COLMASK_CARD = 1
const COLMASK_CARDSLOT = 2
const CARD_HANDOFFSET = Vector2(0, 120)
const CARDSCENE_PATH = "res://scenes/card.tscn"

var ref_battlemgr
var screensize
var selected_card
var hover_flag

func _ready() -> void:
	$"../InputManager".connect("lmb_release", on_lmb_release)
	screensize = get_viewport_rect().size
	ref_battlemgr = $"../BattleManager"

func _process(_delta: float) -> void:
	if (selected_card):
		var target_pos = get_global_mouse_position()
		target_pos =                                  \
			Vector2(                                  \
				clamp(target_pos.x, 0, screensize.x), \
				clamp(target_pos.y, 0, screensize.y)  \
			)
		selected_card.position = target_pos

## signal handlers
func connect_card_signals(card):
	card.connect("hoveron", on_card_hoveron)
	card.connect("hoveroff", on_card_hoveroff)

func on_card_hoveron(card):
	if (hover_flag):
		return
	hover_flag = 1
	card.z_index = 2
	$"../PlayerHand".animate_card_to_pos(card, card.handpos - CARD_HANDOFFSET);

func on_card_hoveroff(card):
	if (selected_card or card.inslot):
		return
	hover_flag = 0
	card.z_index = 1 
	$"../PlayerHand".return_card_to_hand(card)
	# check if we hovered off this card onto another one
	var new_hover = get_mousepos_card()
	if (new_hover):
		on_card_hoveron(new_hover)

func on_lmb_release():
	if (!selected_card):
		return
	drag_stop()

## other funcs
func get_mousepos_card():
	var res = get_mousepos_collision(COLMASK_CARD)
	if (!res):
		return null
	var max_zindex_card = res[0].collider.get_parent()
	for i in range(1, res.size()):
		var c = res[i].collider.get_parent()
		if (c.z_index > max_zindex_card.z_index):
			max_zindex_card = c
	return max_zindex_card

func get_mousepos_cardslot():
	var res = get_mousepos_collision(COLMASK_CARDSLOT)
	if (!res):
		return null
	return res[0].collider.get_parent()

func get_mousepos_collision(mask):
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = mask
	var res = space_state.intersect_point(params)
	if (res.size() == 0):
		return null
	return res

func drag_start(card):
	if (!card):
		return
	selected_card = card

func drag_stop():
	if (!selected_card):
		return
	var cardslot = get_mousepos_cardslot()
	if (cardslot and cardslot.can_add_card(selected_card)):
		selected_card.get_node("Area2D/CollisionShape2D").disabled = 1
		rpc("peer_play_card", $"../PlayerHand".hand.find(selected_card), selected_card.id, cardslot.get_path())
		$"../PlayerHand".remove_card_from_hand(selected_card)
		cardslot.add_card(selected_card)
		if (cardslot.hq == 3-ref_battlemgr.whoami):
			ref_battlemgr.win()
			ref_battlemgr.rpc("lose")
			selected_card = null
			return
		$"../Board/CardSlotManager".handle_card_ability(cardslot, selected_card)
	else:
		$"../PlayerHand".return_card_to_hand(selected_card)
	selected_card = null

@rpc("any_peer")
func peer_play_card(ind, cardid, slotpath):
	var slot = get_node(slotpath)
	var oppcard = $"../Opponent/Hand".hand[ind]
	var tween = get_tree().create_tween()
	tween.tween_property(oppcard, "position", slot.position, 0.1)
	var cardscene = preload(CARDSCENE_PATH)
	var c = cardscene.instantiate().init(3-ref_battlemgr.whoami, cardid)
	$"../CardManager".add_child(c)
	c.get_node("Area2D/CollisionShape2D").disabled = 1
	c.name = "card"
	c.position = oppcard.position
	slot.add_card(c)
	# flip opponent's card
	c.rotation += PI
	$"../Opponent/Hand".remove_card_from_hand(oppcard)
	oppcard.visible = 0
	oppcard.queue_free()
	c.get_node("AnimationPlayer").play("cardflip")

func discard(card):
	var tween = get_tree().create_tween()
	var discardslot
	if (card.team == ref_battlemgr.whoami):
		discardslot = $"../Discard"
	else:
		discardslot = $"../Opponent/Discard"
	tween.tween_property(card, "position", discardslot.position, 0.1)
	tween.tween_property(card, "rotation", 0, 0.1)
	discardslot.add_card(card)
	card.get_node("Area2D/CollisionArea2D").disabled = 1
