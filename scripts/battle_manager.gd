extends Node

const STARTTURN_DRAWCARD = 2

var ref_deck
var ref_board
var myturn = 0
var whoami = 1 # 1 for blue, 2 for red
var game_end = 0
var myname
var oppname

var mymoney
var oppmoney

func _ready() -> void:
	ref_deck = $"../Deck"
	ref_board = $"../Board"

func end_turn():
	end_turn_internal()
	$"../Opponent/PlayerInfo".start_blinking()
	rpc("start_turn")
	
func end_turn_internal():
	$"../PlayerInfo".stop_blinking()
	ref_deck.deck_disabled = 1
	ref_board.get_node("CardSlotManager").slots_disabled = 1
	myturn = 0

func capture_money(player, amt):
	update_money(player, amt)
	if (mymoney >= 7):
		rpc("lose")
		win()

# this is called locally normally, only called remotely for client to recover from lost connection
@rpc
func update_money(player, amt):
	if (player == whoami):
		mymoney += amt
		$"../PlayerInfo/CoinCountLabel".text = "[font_size=20]" + str(mymoney) + "[/font_size]"
	else:
		oppmoney += amt
		$"../Opponent/PlayerInfo/CoinCountLabel".text = "[font_size=20]" + str(oppmoney) + "[/font_size]"

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
	game_end = 1
	end_turn_internal()
	$"../MsgBox".show_msg("You win!")

@rpc("any_peer")
func lose():
	game_end = 1
	end_turn_internal()
	$"../MsgBox".show_msg("You lose!")

@rpc("any_peer")
func set_oppname(name_):
	oppname = name_
	$"../Opponent/PlayerInfo/PlayerNameLabel".text = "[font_size=20]"+name_+"[/font_size]"

func set_myname(name_):
	myname = name_
	$"../PlayerInfo/PlayerNameLabel".text = "[font_size=20]" + name_ + "[/font_size]"
