extends Node2D

var ref_battlemgr

func _ready() -> void:
	ref_battlemgr = $"../../BattleManager"

func check_capture():
	for a in get_children():
		a.check_capture()

func capture_money(player, area):
	capture_money_internal(player, area.get_path())
	rpc("capture_money_internal", player, area.get_path())

@rpc("any_peer")
func capture_money_internal(player, areapath):
	var area = get_node(areapath)
	ref_battlemgr.capture_money(player, area.num_coins)
	area.visible = 0
	area.available = 0
