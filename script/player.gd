extends KinematicBody

export var speed : int = 25
export var acceleration : float = 10.0
export var jump_force : float = 20
export var gravity : float = -32

export var mouse_sensitive = 0.05

var direction : Vector3 = Vector3()
onready var left_ray : RayCast = $left
onready var right_ray : RayCast = $right

puppet var velocity : Vector3 = Vector3()
puppet var jump_vector : Vector3 = Vector3()
puppet var pos : Vector3 = Vector3()

func _ready():
	if is_network_master():
		$head/Camera.make_current()
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x*mouse_sensitive))
		$head.rotate_x(deg2rad(-event.relative.y * mouse_sensitive))
		$head.rotation.x = clamp($head.rotation.x,deg2rad(-70),deg2rad(70))

func _physics_process(delta):
	if is_network_master():
		get_input()
		movement(delta)
	else:
		set_pos()

func set_pos():
	move_and_slide(velocity)
	move_and_slide(jump_vector)
	transform.origin = pos

func get_input():
	direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_back"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	direction = direction.normalized()
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_vector.y = jump_force

func movement(delta):
	
	if left_ray.is_colliding() and !is_on_floor() and (Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back")):
		print("left colliding")
		gravity = -8
		speed = 35
	elif right_ray.is_colliding() and !is_on_floor() and (Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back")):
		print("right colliding")
		gravity = -8
		speed = 35
	else:
		gravity = -32
		speed = 25
	if !is_on_floor():
		jump_vector.y += gravity * delta
	velocity = velocity.linear_interpolate(direction*speed,acceleration*delta)
	velocity = move_and_slide_with_snap(velocity,Vector3.DOWN,Vector3.UP)
	rset_unreliable("velocity",velocity)
	rset_unreliable("jump_vector",jump_vector)
	rset("pos",transform.origin)
	move_and_slide(jump_vector,Vector3.UP)
