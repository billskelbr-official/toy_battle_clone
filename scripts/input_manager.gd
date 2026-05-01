extends Node2D

signal lmb_click
signal lmb_release

const COLMASK_CARD = 1
const COLMASK_CARDSLOT = 2
const COLMASK_DECK = 4
const COLMASK_CARDSLOTVIEW = 16 # unused

var ref_battlemgr
var ref_board
var ref_cardmgr
var ref_deck

func _ready() -> void:
	ref_board = $"../Board"
	ref_cardmgr = $"../CardManager"
	ref_deck = $"../Deck"
	ref_battlemgr = $"../BattleManager"

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if (event.is_pressed()):
			emit_signal("lmb_click")
			get_mousepos_colmask()
		else:
			emit_signal("lmb_release")

func get_mousepos_colmask():
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	var res = space_state.intersect_point(params)
	if (res.size() == 0):
		return null
	match res[0].collider.collision_mask:
		COLMASK_CARD:
			ref_cardmgr.drag_start(res[0].collider.get_parent())
		COLMASK_CARDSLOT:
			ref_board.get_node("CardSlotManager").on_slot_clicked(res[0].collider.get_parent())
		COLMASK_DECK:
			ref_deck.draw_card_click()
