extends Node2D

@export var default_blink = 0

func _ready() -> void:
	if (default_blink):
		start_blinking()

func start_blinking():
	$AvatarHighlightBlinkTimer.start()

func stop_blinking():
	$AvatarHighlightBlinkTimer.stop()
	$AvatarHighlight.visible = 0

func _on_avatar_highlight_blink_timer_timeout() -> void:
	$AvatarHighlight.visible = !$"AvatarHighlight".visible
