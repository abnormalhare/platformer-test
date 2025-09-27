extends Node

func reset():
	$Player.position = $StartPos.position;
	$Player.reset();

func _ready():
	reset();

func _process(delta):
	$Camera2D.offset = $Player.position;
	
	if Input.is_action_just_pressed("reset"):
		reset();
	
	for death_zone in $DeathZones.get_children():
		if type_string(typeof(death_zone)) != "Area2D":
			continue;

func _on_zone_001_body_entered(body):
	reset();
