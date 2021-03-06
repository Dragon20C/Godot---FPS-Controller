extends KinematicBody

export(Resource) var footstep1
export(Resource) var footstep2
export(Resource) var footstep3
onready var footsteps = [footstep1,footstep2,footstep3]
var mouse_sensitivity = 0.1
var walk_speed = 20
var accel = 15
var speed = walk_speed
var sprint_speed = walk_speed * 2
var sneak_speed = walk_speed * 0.5
var crouch_speed = walk_speed * 0.3
var jump_force = 15
var velocity = Vector3()
var final_velocity = Vector3()
var gravity_vec = Vector3()
var gravity = 0.98
var max_terminal_velocity : float = 54
var jump_vel : float
var on_floor = false
var focus = true
var crouched = false
var cant_uncrouch = false
var sprinting = false
var ladder_mode = true
onready var camera = $Camera
onready var footstep_timer = $FootstepTimer
onready var roof_ray = $RayCasts/RoofRay
onready var roof_ray1 = $RayCasts/RoofRay1
onready var roof_ray2 = $RayCasts/RoofRay2
onready var roof_ray3 = $RayCasts/RoofRay3
onready var roof_ray4 = $RayCasts/RoofRay4


func _ready():
	randomize()
	
func _process(delta):
	
	$CrossHair.position = Vector2(1600/2,900/2)
	if Input.is_action_just_pressed("mouse_focus"):
		focus = !focus
	if focus:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
#Head rotation
func _input(event):
	if event is InputEventMouseMotion and focus:
		rotate_y(deg2rad(-event.relative.x*mouse_sensitivity))
		camera.rotate_x(deg2rad(-event.relative.y*mouse_sensitivity))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x,-89,89)


func _physics_process(delta):
		
	velocity = Vector3()
	if Input.is_action_pressed("forward") and focus:
		velocity -= transform.basis.z
	if Input.is_action_pressed("backward") and focus:
		velocity += transform.basis.z
	if Input.is_action_pressed("left") and focus:
		velocity -= transform.basis.x
	if Input.is_action_pressed("right") and focus:
		velocity += transform.basis.x
	if Input.is_action_pressed("sprint") and focus and !crouched and is_on_floor():
		camera.fov = lerp(camera.fov, 100, 8 * delta)
		speed = sprint_speed
		sprinting = true
	else:
		camera.fov = lerp(camera.fov, 90, 8 * delta)
		speed = walk_speed
		sprinting = false
		
	velocity = velocity.normalized()
	
	if is_on_floor():
		jump_vel = -0.01
		gravity_vec = -get_floor_normal() * 1.5
		on_floor = true
	else:
		if on_floor:
			gravity_vec = Vector3.ZERO
			on_floor = false
		else:
			jump_vel = clamp(jump_vel - gravity, -max_terminal_velocity, max_terminal_velocity)
		
	if Input.is_action_pressed("jump") and is_on_floor():
		jump_vel = jump_force
		
	velocity = lerp(velocity,velocity * speed, accel * delta)
	velocity.y = jump_vel
	
	move_and_slide(velocity, Vector3.UP)
	
