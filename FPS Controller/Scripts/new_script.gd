extends KinematicBody

export(Resource) var footstep1
export(Resource) var footstep2
export(Resource) var footstep3
onready var footsteps = [footstep1,footstep2,footstep3]
var mouse_sensitivity = 0.1
var walk_speed = 6
var speed = walk_speed
var sprint_speed = walk_speed * 2
var sneak_speed = walk_speed * 0.5
var crouch_speed = walk_speed * 0.3
var jump_force = 2.8 
var velocity = Vector3()
var final_velocity = Vector3()
var gravity_vec = Vector3()
var gravity = 9.8
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
	
	footsteps_controller()
	
	velocity = Vector3()
	if Input.is_action_pressed("forward") and focus:
		velocity -= transform.basis.z
	if Input.is_action_pressed("backward") and focus:
		velocity += transform.basis.z
	if Input.is_action_pressed("left") and focus:
		velocity -= transform.basis.x
	if Input.is_action_pressed("right") and focus:
		velocity += transform.basis.x
	if Input.is_action_pressed("sprint") and focus and !crouched:
		camera.fov = lerp(camera.fov, 100, 8 * delta)
		speed = sprint_speed
		sprinting = true
	else:
		camera.fov = lerp(camera.fov, 90, 8 * delta)
		speed = walk_speed
		sprinting = false
			
	velocity = velocity.normalized()
	if is_on_floor():
		gravity_vec = -get_floor_normal() * 1.5
		on_floor = true
	else:
		if on_floor:
			gravity_vec = Vector3.ZERO
			on_floor = false
		else:
			gravity_vec += Vector3.DOWN * gravity * delta
			
	if Input.is_action_pressed("jump") and is_on_floor() and !crouched:
		gravity_vec = Vector3.UP * jump_force
		on_floor = false
		
	if Input.is_action_just_pressed("crouch") and !cant_uncrouch:
		crouched = !crouched
	if crouched:
		roof_ray.enabled = true
		roof_ray1.enabled = true
		roof_ray2.enabled = true
		roof_ray3.enabled = true
		roof_ray4.enabled = true
	elif !crouched:
		roof_ray.enabled = false
		roof_ray1.enabled = false
		roof_ray2.enabled = false
		roof_ray3.enabled = false
		roof_ray4.enabled = false
	if roof_ray.is_colliding() or roof_ray1.is_colliding() or roof_ray2.is_colliding() or roof_ray3.is_colliding() or roof_ray4.is_colliding():
		cant_uncrouch = true
	else:
		cant_uncrouch = false
	
	if crouched:
		camera.transform.origin = lerp(camera.transform.origin,Vector3(0,1.516,-0.078),5 * delta)
		speed = crouch_speed
		$CollisionMesh.shape.height = lerp($CollisionMesh.shape.height,0.6, 5 * delta)
		$CollisionMesh.transform.origin = lerp($CollisionMesh.transform.origin,Vector3(0,1.029,0),5 * delta)
	elif Input.is_action_pressed("sneak"):
		speed = sneak_speed
	else:
		camera.transform.origin = lerp(camera.transform.origin,Vector3(0,3.516,-0.078), 5 * delta)
		speed = walk_speed
		$CollisionMesh.shape.height = lerp($CollisionMesh.shape.height,2, 5 * delta)
		$CollisionMesh.transform.origin = lerp($CollisionMesh.transform.origin,Vector3(0,1.99,0),5 * delta)
		
	final_velocity.z = velocity.z + gravity_vec.z
	final_velocity.x = velocity.x + gravity_vec.x
	final_velocity.y = gravity_vec.y
	move_and_slide(final_velocity * speed, Vector3.UP)
	

