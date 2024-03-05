extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var handheld: Node3D
var thirdPersonCamera: Camera3D
var firstPersonCamera: Camera3D
var mouse_sensitivity: int = 100
var max_pitch: float = 90
var min_pitch: float = -90
var inThirdPerson: bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")





#Handles aim look with the mouse.
func aim_look(event: InputEventMouseMotion)-> void:
	var viewport_transform: Transform2D = get_tree().root.get_final_transform()
	var motion: Vector2 = event.xformed_by(viewport_transform).relative
	var degrees_per_unit: float = 0.001
	
	motion *= mouse_sensitivity
	motion *= degrees_per_unit
	
	add_yaw(motion.x)
	add_pitch(motion.y)
	clamp_pitch()

#Rotates the character around the local Y axis by a given amount (In degrees) to achieve yaw.
func add_yaw(amount)->void:
	if is_zero_approx(amount):
		return
	
	rotate_object_local(Vector3.DOWN, deg_to_rad(amount))
	orthonormalize()

#Rotates the head around the local x axis by a given amount (In degrees) to achieve pitch.
func add_pitch(amount)->void:
	if is_zero_approx(amount):
		return
	
	firstPersonCamera.rotate_object_local(Vector3.LEFT, deg_to_rad(amount))
	firstPersonCamera.orthonormalize()

#Clamps the pitch between min_pitch and max_pitch.
func clamp_pitch()->void:
	if firstPersonCamera.rotation.x > deg_to_rad(min_pitch) and firstPersonCamera.rotation.x < deg_to_rad(max_pitch):
		return
	
	firstPersonCamera.rotation.x = clamp(firstPersonCamera.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	firstPersonCamera.orthonormalize()

func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if (Input.is_action_just_pressed("player_jump") || (Input.is_action_just_pressed("player_up") && inThirdPerson)) && is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir
	if inThirdPerson:
		input_dir = Input.get_vector("player_left", "player_right", "player_right", "player_right")
	else:
		input_dir = Input.get_vector("player_left", "player_right", "player_up", "player_back")
		
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	#var holding_left = Input.is_action_pressed("player_left")
	#var holding_right = Input.is_action_pressed("player_right")
	#
	#if holding_left and !holding_right:
		#velocity.x = -SPEED
	#elif holding_right and !holding_left:
		#velocity.x = SPEED
	#else:
		#velocity.x = 0

	move_and_slide()

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED && !inThirdPerson:
			if event.button_index == 1:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				return
		
		if inThirdPerson:
			#thirdPersonCamera.current = false
			#firstPersonCamera.current = true
			print("Mouse Click/Unclick at: ", event.position)
			return
	
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			return
			
		if event.is_action_pressed("player_perspective"):
			inThirdPerson = !inThirdPerson
			thirdPersonCamera.current = inThirdPerson
			firstPersonCamera.current = !inThirdPerson
			if inThirdPerson:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return
	
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED && !inThirdPerson:
			aim_look(event)
			return
		
		if inThirdPerson:
			var playerPos = thirdPersonCamera.unproject_position(position)
			var mousePos = event.position
			mousePos -= playerPos
			handheld.rotation.z = -Vector2(0, 0).angle_to_point(mousePos) - PI / 2
			return

	# Print the size of the viewport.
	#print("Viewport Resolution is: ", get_viewport().get_visible_rect().size)

func _ready():
	handheld = get_node("Handheld")
	thirdPersonCamera = get_node("ThirdPersonCamera")
	firstPersonCamera = get_node("FirstPersonCamera")
