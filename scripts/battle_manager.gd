extends Node

const STARTTURN_DRAWCARD = 2

var ref_deck
var ref_board
var myturn = 0
var whoami = 1 # 1 for blue, 2 for red
var game_end = 0
var myname
var oppname

var mymoney = 0
var oppmoney = 0

func _ready() -> void:
	ref_deck = $"../Deck"
	ref_board = $"../Board"

func end_turn():
	end_turn_internal()
	$"../Opponent/PlayerInfo".start_blinking()
	rpc("start_turn")
	
func end_turn_internal():
	$"../PlayerInfo".stop_blinking()
	$"../Opponent/PlayerInfo".stop_blinking()
	ref_deck.deck_disabled = 1
	ref_board.get_node("CardSlotManager").slots_disabled = 1
	myturn = 0

func capture_money(player, amt):
	update_money(player, amt)
	if (mymoney >= $"../Board".win_money):
		rpc("lose")
		win()

# this is called locally normally, only called remotely for client to recover from lost connection
@rpc
func update_money(player, amt):
	if (player == whoami):
		mymoney += amt
		$"../PlayerInfo/CoinCountLabel".text = str(mymoney) + " / " + str($"../Board".win_money)
	else:
		oppmoney += amt
		$"../Opponent/PlayerInfo/CoinCountLabel".text = str(oppmoney) + " / " + str($"../Board".win_money)

@rpc("any_peer")
func start_turn():
	if (game_end):
		return
	$"../PlayerInfo".start_blinking()
	$"../Opponent/PlayerInfo".stop_blinking()
	ref_deck.deck_disabled = 0
	ref_board.get_node("CardSlotManager").slots_disabled = 0
	myturn = 1

@rpc("any_peer")
func set_whoami(identity):
	whoami = identity
	$"../PlayerInfo/AvatarImage".texture = load("res://assets/textures/avatars/"+str(whoami)+".png")
	$"../Opponent/PlayerInfo/AvatarImage".texture = load("res://assets/textures/avatars/"+str(3-whoami)+".png")
	$"../Deck/DeckImage".texture = load("res://assets/textures/card/back_"+str(whoami)+".png")
	$"../Opponent/Deck/DeckImage".texture = load("res://assets/textures/card/back_"+str(3-whoami)+".png")
	# flip all card slots by 180 degrees for player 2 so they face the right way
	if (whoami == 2):
		for cs in $"../Board/CardSlotManager".get_children():
			cs.rotation += PI

@rpc("any_peer")
func win():
	game_end_cleanup()
	$"../MsgBox".show_msg("You win!")
	$"../PlayerInfo".set_hat("hat_win")
	$"../Opponent/PlayerInfo".set_hat("hat_lose")

@rpc("any_peer")
func lose():
	game_end_cleanup()
	$"../MsgBox".show_msg("You lose!")
	$"../PlayerInfo".set_hat("hat_lose")
	$"../Opponent/PlayerInfo".set_hat("hat_win")

@rpc("any_peer")
func opp_surrender():
	win()
	# give opp a flag
	$"../Opponent/PlayerInfo".set_hat("hat_surrender")	

func surrender():
	lose()
	# show a flag
	$"../PlayerInfo".set_hat("hat_surrender")
	rpc("opp_surrender")

@rpc("any_peer")
func set_oppname(name_):
	oppname = name_
	$"../Opponent/PlayerInfo/PlayerNameLabel".text = name_

func game_end_cleanup():
	game_end = 1
	end_turn_internal()
	$"../Buttons/SurrenderButton".disabled = 1
	if (multiplayer.get_unique_id() == 1):
		$"../Buttons/LeaveButton".disabled = 0

func set_myname(name_):
	myname = name_
	$"../PlayerInfo/PlayerNameLabel".text = name_
