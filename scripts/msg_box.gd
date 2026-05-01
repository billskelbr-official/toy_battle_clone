extends Node2D

const frompos = Vector2(0, -200)
const topos = Vector2(0, 0)

var inuse = 0

func _ready() -> void:
	pass

func show_msg(msg):
	if (inuse):
		hide_msg()
	inuse = 1
	$RichTextLabel.text = "[font_size=36]" + msg + "[/font_size]"
	position = frompos
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", topos, 0.1)
	$Timer.start()

func hide_msg():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", frompos, 0.1)
	inuse = 0

func _on_timer_timeout() -> void:
	hide_msg()
