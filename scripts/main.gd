extends Node2D

@export var game_scene: PackedScene

var ref_tube
var myname
var mapid = -1
var hosting = 0
var mainmenu_on_disconnect = 1

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	ref_tube = $TubeClient
	$MainMenu/HostMenu/HostMenuButtons/MapSelect.get_popup().connect("id_pressed", _on_host_map_changed)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		ref_tube.leave_session()
		get_tree().quit()

func _on_host_menu_button_pressed() -> void:
	# open the host menu
	$"MainMenu/RootMenu".visible = 0
	$"MainMenu/DimPolygon".visible = 1
	$"MainMenu/HostMenu".visible = 1

func _on_host_map_changed(mapid_):
	$"MainMenu/HostMenu/HostMenuButtons/MapSelect".text = "Map: " + GAME_DB.BOARDS[mapid_][GAME_DB.BOARD_IND_NAME]
	mapid = mapid_

func _on_host_button_pressed():
	hosting = !hosting
	if (hosting):
		if (mapid == -1):
			hosting = 0
			$MsgBox.show_msg("No map selected")
			return
		$"MainMenu/HostMenu/HostMenuButtons/MainMenuButton".disabled = 1
		$"MainMenu/HostMenu/HostMenuButtons/HostButton".text = "Cancel"
		set_myname($"MainMenu/HostMenu/HostMenuButtons/NameInput".text)
		ref_tube.create_session()
		$"MainMenu/HostMenu/HostIDLabel".text = "Session ID: [" + ref_tube.session_id + "]"
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	else:
		# already hosting a game, so cancel
		mainmenu_on_disconnect = 0
		multiplayer.peer_connected.disconnect(_on_peer_connected)
		multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)
		ref_tube.leave_session()
		reset_host_menu()

func _on_join_menu_button_pressed():
	$"MainMenu/RootMenu".visible = 0
	$"MainMenu/DimPolygon".visible = 1
	$"MainMenu/JoinMenu".visible = 1

func _on_join_id_input_text_changed(new_text: String) -> void:
	var inputnode = $"MainMenu/JoinMenu/JoinMenuButtons/JoinIDInput" 
	var caretpos = inputnode.caret_column
	inputnode.text = new_text.to_upper()
	inputnode.caret_column = caretpos

func _on_join_button_pressed() -> void:
	var session_id = $"MainMenu/JoinMenu/JoinMenuButtons/JoinIDInput".text.to_upper()
	set_myname($"MainMenu/JoinMenu/JoinMenuButtons/NameInput".text)
	hide_mainmenu()
	var g = game_scene.instantiate()
	add_child(g)
	
	ref_tube.join_session(session_id)

func _on_main_menu_button_pressed():
	$"MainMenu/HostMenu".visible = 0
	$"MainMenu/JoinMenu".visible = 0
	$"MainMenu/DimPolygon".visible = 0
	$"MainMenu/RootMenu".visible = 1

func _on_peer_connected(_peerid):
	ref_tube.refuse_new_connections = 1
	hide_mainmenu()
	var g = game_scene.instantiate()
	add_child(g)
	g.setup_host(mapid)
	$Game.rpc("setup_client", mapid)
	# reset the host menu last because it will mess up the mapid needed for initialisation
	reset_host_menu()

func _on_peer_disconnected(_peerid):
	ref_tube.refuse_new_connections = 0
	# kill the server when the peer disconnects to avoid corruptions when reconnecting.
	# allowing disconnected players to reconnect is planned but not fully implemented yet.
	multiplayer.peer_connected.disconnect(_on_peer_connected)
	multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)
	ref_tube.leave_session()

func hide_mainmenu():
	$MainMenu.visible = 0
	$"MainMenu/RootMenu".visible = 1
	$"MainMenu/DimPolygon".visible = 0
	$"MainMenu/HostMenu".visible = 0
	$"MainMenu/JoinMenu".visible = 0

func _on_tube_client_session_left() -> void:
	if (!mainmenu_on_disconnect):
		mainmenu_on_disconnect = 1
		return
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
	$"MainMenu/HostMenu".visible = 0
	$"MainMenu/JoinMenu".visible = 0
	$"MainMenu/DimPolygon".visible = 0
	$"MainMenu/RootMenu".visible = 1
	$MainMenu.visible = 1

func set_myname(val):
	myname = val
	if (myname == ""):
		myname = "Player"
	else:
		# use the same name when joining or hosting again
		$"MainMenu/HostMenu/HostMenuButtons/NameInput".text = val
		$"MainMenu/JoinMenu/JoinMenuButtons/NameInput".text = val

func reset_host_menu():
		hosting = 0
		$"MainMenu/HostMenu/HostMenuButtons/HostButton".text = "Host Game"
		$"MainMenu/HostMenu/HostIDLabel".text = "Session ID: [------]"
		$"MainMenu/HostMenu/HostMenuButtons/MainMenuButton".disabled = 0
		$"MainMenu/HostMenu/HostMenuButtons/MapSelect".text = "Select map..."
		mapid = -1
