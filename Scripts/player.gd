extends CharacterBody3D

const SPEED := 10.0
const MOUSE_SENS := 0.002

@onready var head: Node3D = $Head

var pitch := 0.0

var flashlight_on:bool = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Left/Right look (Yaw) rotates the body
		rotate_y(-event.relative.x * MOUSE_SENS)

		# Up/Down look (Pitch) rotates the head
		pitch -= event.relative.y * MOUSE_SENS
		pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))
		head.rotation.x = pitch

	# ESC to release mouse
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("toggle_flashlight"):
		print("Flashlight toggle")
		flashlight_on = !flashlight_on
		$Head/Flashlight/SpotLight3D.visible = flashlight_on

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movement input
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# IMPORTANT: use global basis so movement follows yaw rotation
	var direction := (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
