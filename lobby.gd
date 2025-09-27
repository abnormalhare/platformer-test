extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const IP_ADDRESS = "127.0.0.1";
const PORT := 26000;

var players := {};
var players_loaded := 0;
var player_info = {"name": "Name"}

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_server():
	var peer = ENetMultiplayerPeer.new();
	var err = peer.create_server(PORT, 2);
	if err:
		return err;
	
	multiplayer.multiplayer_peer = peer;
	
	players[1] = player_info;
	player_connected.emit(1, player_info)

func create_client():
	var peer = ENetMultiplayerPeer.new();
	var err = peer.create_client(IP_ADDRESS, PORT);
	if err:
		return err;
	multiplayer.multiplayer_peer = peer;

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new();
	players.clear();

@rpc("call_local", "reliable")
func load_game():
	get_tree().change_scene_to_file("res://world.tscn")

@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == 2:
			load_game();

func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id();
	players[new_player_id] = new_player_info;
	player_connected.emit(new_player_id, new_player_info);

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	remove_multiplayer_peer()

func _on_server_disconnected():
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()
