extends Node2D

var ref_battlemgr
var ref_deck
var ongoing_game = 0

func _ready() -> void:
	ref_battlemgr = $BattleManager
	ref_deck = $Deck

func setup_host():
	ref_battlemgr.set_whoami(randi_range(1, 2))
	var opp_ident = 3 - ref_battlemgr.whoami
	ref_battlemgr.rpc("set_whoami", opp_ident)
	ref_battlemgr.mymoney = 0
	ref_battlemgr.oppmoney = 0
	$"PlayerInfo/CoinCountLabel".text = "0"
	$"Opponent/PlayerInfo/CoinCountLabel".text = "0"
	ref_deck.shuffle_deck()
	ref_deck.set_client_deck()
	# draw_initial_hand also removes the opponent's cards from the deck on server side
	ref_deck.draw_initial_hand()
	ref_deck.rpc("draw_initial_hand")
	if (ref_battlemgr.whoami == 1):
		# get the other to end turn to make their opponent blink
		ref_battlemgr.start_turn()
	else:
		ref_battlemgr.rpc("start_turn")
	var myname = $"/root/Main".myname
	ref_battlemgr.set_myname(myname)
	ref_battlemgr.rpc("set_oppname", myname)
	$LoadingScreen.loadingscreen_hide()
	$LoadingScreen.rpc("loadingscreen_hide")

@rpc("any_peer")
func setup_client():
	ref_battlemgr.mymoney = 0
	ref_battlemgr.oppmoney = 0
	$"PlayerInfo/CoinCountLabel".text = "0"
	$"Opponent/PlayerInfo/CoinCountLabel".text = "0"
	var myname = $"/root/Main".myname
	ref_battlemgr.set_myname(myname)
	ref_battlemgr.rpc("set_oppname", myname)


func restore_client_gamestate():
	$Deck.rpc("set_client_deck", $"Opponent/Deck".deck)
	$PlayerHand.rpc("set_client_hand", $"Opponent/Hand".hand)
	var board_data = {
		"discard": [[], []],
		"money": [],
		"bases": [],
		"areas": []
	}
	for c in $"../Discard1".cards:
		board_data["discard"][0].append(0, c.id)
	for c in $"../Discard2".cards:
		board_data["discard"][1].append(c.id)
	if (ref_battlemgr.whoami == 1):
		board_data["money"] = [ref_battlemgr.mymoney, ref_battlemgr.oppmoney]
	else:
		board_data["money"] = [ref_battlemgr.oppmoney, ref_battlemgr.mymoney]
	for b in $Board/CardSlotManager.get_children():
		var cds = []
		for c in b.cards:
			cds.insert(0, [c.team, c.id])
		board_data["bases"].append(cds.duplicate())
	for a in $"Board/AreaManager".get_children():
		board_data["areas"].insert(0, a.available)
	$Board.rpc("set_client_board", board_data)
