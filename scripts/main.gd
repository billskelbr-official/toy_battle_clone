extends Node2D

@export var game_scene: PackedScene

var ref_tube
var myname

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	ref_tube = $TubeClient

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		ref_tube.leave_session()
		get_tree().quit()

func _on_host_button_pressed() -> void:
	disable_buttons()
	set_myname()
	ref_tube.create_session()
	$"MainMenu/HostIDLabel".text = "Session ID: [" + ref_tube.session_id + "]"
	multiplayer.peer_connected.connect(_on_peer_connected)
	
func _on_join_button_pressed() -> void:
	disable_buttons()
	set_myname()
	hide_mainmenu()
	var g = game_scene.instantiate()
	add_child(g)
	
	ref_tube.join_session($"MainMenu/JoinIDInput".text)


func _on_peer_connected(_peerid):
	hide_mainmenu()
	var g = game_scene.instantiate()
	add_child(g)
	g.setup_host()
	if (g.ongoing_game):
		$Game.restore_client_gamestate()
	else:
		$Game.rpc("setup_client")

func disable_buttons():
	$MainMenu/HostButton.disabled = 1
	$MainMenu/JoinButton.disabled = 1

func hide_mainmenu():
	$MainMenu.visible = 0

func _on_tube_client_session_left() -> void:
	return_to_mainmenu()
	$MsgBox.show_msg("Disconnected")

func _on_tube_client_error_raised(code: TubeClient.SessionError, message: String) -> void:
	if (
		code != TubeClient.SessionError.CREATE_SESSION_FAILED
		and code != TubeClient.SessionError.JOIN_SESSION_FAILED
	):
		return
	return_to_mainmenu()
	$MsgBox.show_msg("(" + str(code) + ") " + message)

func return_to_mainmenu():
	if (get_node_or_null("Game")):
		$Game.visible = 0
		$Game.queue_free()
	$MainMenu.visible = 1
	$MainMenu/HostButton.disabled = 0
	$MainMenu/JoinButton.disabled = 0

func set_myname():
	myname = $MainMenu/NameInput.text
	if (myname == "Session ID: [------]"):
		myname = "Player"
