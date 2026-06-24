extends Node2D

var ref_battlemgr
var win_money

const CARDSCENE_PATH = "res://scenes/card.tscn"
const CARDSLOTSCENE_PATH = "res://scenes/card_slot.tscn"
const AREASCENE_PATH = "res://scenes/area.tscn"

func _ready() -> void:
	ref_battlemgr = $"../BattleManager"

func init_board(id):
	var board = GAME_DB.BOARDS[id]
	
	# update_money to set the amt of money to win in the text displays
	win_money = board[GAME_DB.BOARD_IND_MONEY]
	ref_battlemgr.update_money(1, 0)
	ref_battlemgr.update_money(2, 0)
	
	$"BoardBgImg".texture = load("res://assets/textures/boards/" + str(id) + ".png")
	
	var slots = board[GAME_DB.BOARD_IND_CARDSLOTS]
	var slotscene = preload(CARDSLOTSCENE_PATH)
	var added_slots = []
	for slot in slots:
		var s = slotscene.instantiate()
		s.rotation = PI/2
		s.name = "CardSlot" + slot[GAME_DB.BOARD_CARDSLOT_IND_NAME]
		s.hq = slot[GAME_DB.BOARD_CARDSLOT_IND_HQ]
		s.neighbour_paths = slot[GAME_DB.BOARD_CARDSLOT_IND_NEIGHBOURS]
		var targetpos = slot[GAME_DB.BOARD_CARDSLOT_IND_POSITION]
		s.position.x = targetpos[0]
		s.position.y = targetpos[1]
		added_slots.append(s)
		$CardSlotManager.add_child(s)
	for slot in added_slots:
		slot.cardslot_init()
	
	var areas = board[GAME_DB.BOARD_IND_AREAS]
	var areascene = preload(AREASCENE_PATH)
	for i in range(len(areas)):
		var area = areas[i]
		var a = areascene.instantiate()
		a.num_coins = area[GAME_DB.BOARD_AREA_IND_NUMCOINS]
		a.border_names = area[GAME_DB.BOARD_AREA_IND_BORDERS]
		var targetpos = area[GAME_DB.BOARD_AREA_IND_POSITION]
		a.position.x = targetpos[0]
		a.position.y = targetpos[1]
		a.name = "Area" + str(i)
		$AreaManager.add_child(a)
		a.area_init()

@rpc("authority")
func set_client_board(board_data):
	var cs = preload(CARDSCENE_PATH)

	for c in board_data["discard"][0]:
		$"../Discard1".add_card(cs.instantiate().init(c[0], c[1]))
	for c in board_data["discard"][1]:
		$"../Discard2".add_card(cs.instantiate().init(c[0], c[1]))
	
	if (ref_battlemgr.whoami == 1):
		ref_battlemgr.mymoney = board_data["money"][0]
		ref_battlemgr.oppmoney = board_data["money"][1]
	else:
		ref_battlemgr.mymoney = board_data["money"][1]
		ref_battlemgr.oppmoney = board_data["money"][0]

	for i in range($CardSlotManager.get_children().size()):
		for c in board_data["bases"][i]:
			var card = cs.instantiate().init(c[0], c[1])
			$CardSlotManager.get_children()[i].add_card(card)
	
	for i in range($AreaManager.get_children().size()):
		$AreaManager.get_children()[i].availble = board_data["areas"][i]
		$AreaManager.get_children()[i].visible = board_data["areas"][i]
	
