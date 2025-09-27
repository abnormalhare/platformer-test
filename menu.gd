extends Control

func _ready():
	Lobby.player_loaded.rpc_id(1);

func _on_create_pressed():
	Lobby.create_server();

func _on_join_pressed():
	Lobby.create_client();
