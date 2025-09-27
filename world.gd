extends Node

func _ready():
	$Player.position = $StartPos.position;

func _process(delta):
	$Camera2D.offset = $Player.position;
