extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var handheld: Node3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var holding_left = Input.is_action_pressed("player_left")
	var holding_right = Input.is_action_pressed("player_right")
	
	if holding_left and !holding_right:
		velocity.x = -SPEED
	elif holding_right and !holding_left:
		velocity.x = SPEED
	else:
		velocity.x = 0

	move_and_slide()

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		pass
		#print("Mouse Click/Unclick at: ", event.position)
	elif event is InputEventMouseMotion:
		var playerPos = $Camera3D.unproject_position(position)
		var mousePos = event.position
		var viewportSize = get_viewport().get_visible_rect().size
		mousePos -= playerPos
		
		handheld.rotation.z = -Vector2(0, 0).angle_to_point(mousePos) - PI / 2
		print("Mouse Motion at: ", event.position)
		print("pos at: ", $Camera3D.unproject_position(position))

	# Print the size of the viewport.
	#print("Viewport Resolution is: ", get_viewport().get_visible_rect().size)

func _ready():
	handheld = get_node("Handheld")
