extends Node2D

var ref_battlemgr

const CARDSCENE_PATH = "res://scenes/card.tscn"

func _ready() -> void:
	ref_battlemgr = $"../BattleManager"

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
	
