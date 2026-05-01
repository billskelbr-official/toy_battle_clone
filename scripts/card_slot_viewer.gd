extends Node2D

const CARDSCENE_PATH = "res://scenes/card.tscn"
const CARD_HEIGHT = 270
const CARD_WIDTH = 180

var inuse = 0
var cardcpys = []
var screen_ctr_x
var screen_ctr_y

func _ready() -> void:
	screen_ctr_x = get_viewport().size.x/2
	screen_ctr_y = get_viewport().size.y/2

func show_cards(cards):
	# do nothing if another slot is already being viewed
	if (inuse):
		return
	inuse = 1
	$"Area2D/CollisionShape2D".disabled = 0
	for i in range(cards.size()):
		var c = cards[i]
		var cpy = preload(CARDSCENE_PATH).instantiate().init(c.team, c.id)
		cardcpys.append(cpy)
		add_child(cpy)
		cpy.rotation = 0
		cpy.visible = 1
		cpy.position = get_cardpos(i, cards.size())
		cpy.get_node("Area2D/CollisionShape2D").disabled = 1
		cpy.get_node("AnimationPlayer").play("cardflip")
	visible = 1

func get_cardpos(ind, num_cards):
	var x
	var y
	ind %= 8
	var rowsz
	if (num_cards > 8):
		rowsz = 8
	else:
		rowsz = num_cards
	var totwidth = (rowsz-1) * CARD_WIDTH
	@warning_ignore("integer_division")
	x = screen_ctr_x + ind*CARD_WIDTH - totwidth/2
	# if there is only one row, use the centre
	if (num_cards / 8 == 0):
		y = screen_ctr_y
	elif (num_cards / 8 == 1):
		@warning_ignore("integer_division")
		y = screen_ctr_y - CARD_HEIGHT/2 + (CARD_HEIGHT)*(ind / 8)
	else:
		@warning_ignore("integer_division")
		y = screen_ctr_y - 3*CARD_HEIGHT/2 + (CARD_HEIGHT)*(ind / 8)
	return Vector2(x, y)

func _on_area_2d_mouse_exited() -> void:
	inuse = 0
	$"Area2D/CollisionShape2D".disabled = 1
	visible = 0
	for c in cardcpys:
		c.queue_free()
	cardcpys = []

# this is for the cards which will become our child
func connect_card_signals(_dummy):
	pass
