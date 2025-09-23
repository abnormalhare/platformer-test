extends CharacterBody2D

enum AccelState {
	NONE,
	START,
	RUN_START,
	CHANGE,
	STOP,
	MOVE,
	END
}

var accelx_timer: int = 0;
var accelx_state: AccelState = AccelState.NONE;
var prev_dirx: float = 0.0;

var is_moving_right: bool;
var is_moving_left: bool;
var just_moved_right: bool;
var just_moved_left: bool;
var just_rel_right: bool;
var just_rel_left: bool;

func process_x(delta):
	var dirx: float = 0.0;
	var ax: float = 0.0;
	
	is_moving_right  = Input.is_action_pressed("move_right");
	is_moving_left   = Input.is_action_pressed("move_left");
	just_moved_right = Input.is_action_just_pressed("move_right");
	just_moved_left  = Input.is_action_just_pressed("move_left");
	just_rel_right   = Input.is_action_just_released("move_right");
	just_rel_left    = Input.is_action_just_released("move_left");
	
	if just_moved_right and not is_moving_left or is_moving_right and just_rel_left:
		accelx_state = AccelState.START;
	if is_moving_right and not is_moving_left:
		if velocity.x >= 600.0:
			if accelx_state == AccelState.START:
				accelx_state = AccelState.MOVE;
		dirx += 1.0;
	
	if just_moved_left and not is_moving_right or is_moving_left and just_rel_right:
		accelx_state = AccelState.START;
	if is_moving_left and not is_moving_right:
		if velocity.x <= -600.0:
			if accelx_state == AccelState.START:
				accelx_state = AccelState.MOVE;
		dirx += -1.0;
	
	var none_x_keys: bool = (not is_moving_right and not is_moving_left);
	var both_x_keys: bool = (is_moving_left and is_moving_right);
	if none_x_keys or both_x_keys:
		dirx = -1.0 if velocity.x >= 0 else 1.0;
		if none_x_keys and (just_rel_right or just_rel_left) or both_x_keys and (just_moved_right or just_moved_left):
			accelx_state = AccelState.STOP;
			prev_dirx = dirx;
		
		if (prev_dirx != dirx):
			velocity.x = 0;
			accelx_state = AccelState.END;

	match accelx_state:
		AccelState.NONE:      ax = 0.0
		AccelState.START:     ax = 20.0
		AccelState.RUN_START: ax = 50.0
		AccelState.CHANGE:    ax = 10.0
		AccelState.STOP:      ax = 20.0
		AccelState.MOVE:      ax = 0.0;
		AccelState.END:       ax = 0.0; velocity.x = 0;
	
	if is_moving_left or is_moving_right:
		prev_dirx = dirx;
		
	return ax * dirx;

const TERMINAL_VELOCITY: float = 2000.0;

func process_y(delta):
	var ay: float = 0.0;
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			ay = -1200.0;
	else:
		if velocity.y < TERMINAL_VELOCITY:
			ay = 30.0;
	return ay;

func _process(delta):
	is_moving_right  = Input.is_action_pressed("move_right");
	is_moving_left   = Input.is_action_pressed("move_left");
	just_moved_right = Input.is_action_just_pressed("move_right");
	just_moved_left  = Input.is_action_just_pressed("move_left");
	just_rel_right   = Input.is_action_just_released("move_right");
	just_rel_left    = Input.is_action_just_released("move_left");
	
	velocity.x += process_x(delta);
	velocity.y += process_y(delta);
	
	velocity.x = 0 if accelx_state == AccelState.END else velocity.x;
	
	print(velocity)
	
	move_and_slide();
