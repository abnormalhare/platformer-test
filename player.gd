extends CharacterBody2D

enum AccelState {
	NONE,
	SPEED_UP,
	RUN_SPEED_UP,
	SLOW_DOWN,
	SLOW_DOWN_AIR,
	CHANGE,
	STOP,
	MOVE,
	END
}

var accelx_timer: int = 0;
var accelx_state: AccelState = AccelState.NONE;
var prev_dirx: float = 0.0;

var accelx: float = 0.0;
var accely: float = 0.0;

var is_moving_right: bool = false;
var is_moving_left: bool = false;
var just_moved_right: bool = false;
var just_moved_left: bool = false;
var just_rel_right: bool = false;
var just_rel_left: bool = false;

var to_jump: bool = false;

const MAX_XVEL := 600.0;

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
		accelx_state = AccelState.SPEED_UP;
	if is_moving_right and not is_moving_left:
		if velocity.x == MAX_XVEL:
			if accelx_state == AccelState.SPEED_UP:
				accelx_state = AccelState.MOVE;
		elif velocity.x > MAX_XVEL and is_on_floor():
			accelx_state = AccelState.SLOW_DOWN;
			dirx -= 1.0;
		elif velocity.x > MAX_XVEL:
			accelx_state = AccelState.SLOW_DOWN_AIR;
			dirx -= 1.0;
		else:
			accelx_state = AccelState.SPEED_UP;
			dirx += 1.0;

	if just_moved_left and not is_moving_right or is_moving_left and just_rel_right:
		accelx_state = AccelState.SPEED_UP;
	if is_moving_left and not is_moving_right:
		if velocity.x == -MAX_XVEL:
			if accelx_state == AccelState.SPEED_UP:
				accelx_state = AccelState.MOVE;
		elif velocity.x < -MAX_XVEL and is_on_floor():
			accelx_state = AccelState.SLOW_DOWN;
			dirx += 1.0;
		elif velocity.x < -MAX_XVEL:
			accelx_state = AccelState.SLOW_DOWN_AIR;
			dirx += 1.0;
		else:
			accelx_state = AccelState.SPEED_UP;
			dirx -= 1.0;

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
		AccelState.NONE:          ax = 0.0;
		AccelState.SPEED_UP:      ax = 20.0;
		AccelState.RUN_SPEED_UP:  ax = 50.0;
		AccelState.SLOW_DOWN:     ax = 5.0;
		AccelState.SLOW_DOWN_AIR: ax = 0.5;
		AccelState.CHANGE:        ax = 10.0;
		AccelState.STOP:          ax = 20.0;
		AccelState.MOVE:          ax = 0.0;
		AccelState.END:           ax = 0.0; velocity.x = 0;
	
	if is_moving_left or is_moving_right:
		prev_dirx = dirx;
	
	accelx = ax * dirx;

const TERMINAL_VELOCITY: float = 2000.0;

func process_y(delta):
	var ay: float = 0.0;

	if is_on_floor():
		
		if Input.is_action_just_pressed("jump") or to_jump == true:
			var did_imm_jump := to_jump;
			to_jump = false;

			ay = -1200.0;
			
			if did_imm_jump:
				var slope := get_last_slide_collision();
				var angle := slope.get_angle();
				
				if slope.get_normal().x > 0:
					accelx -= ay * sin(angle);
				else:
					accelx += ay * sin(angle);
				ay = ay * cos(angle);
	else:
		if Input.is_action_just_pressed("jump"):
			to_jump = true;
		if to_jump and Input.is_action_just_released("jump"):
			to_jump = false;
		if velocity.y < TERMINAL_VELOCITY:
			ay = 30.0;
	
	accely = ay;

func _process(delta):
	is_moving_right  = Input.is_action_pressed("move_right");
	is_moving_left   = Input.is_action_pressed("move_left");
	just_moved_right = Input.is_action_just_pressed("move_right");
	just_moved_left  = Input.is_action_just_pressed("move_left");
	just_rel_right   = Input.is_action_just_released("move_right");
	just_rel_left    = Input.is_action_just_released("move_left");
	
	process_x(delta);
	process_y(delta);
	velocity.x += accelx;
	velocity.y += accely;
	
	velocity.x = 0 if accelx_state == AccelState.END else velocity.x;
	
	print(velocity.x, ", ", velocity.y)
	
	move_and_slide();
