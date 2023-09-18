extends RigidBody3D

var is_dragging : bool = false
var mouse_start : Vector3 = Vector3()
var direction : Vector3 = Vector3()
var offset : Vector3 = Vector3()
var z_cord: float = 0
@export var move_speed : float

func _ready():
	set_process_input(true)

func _on_input_event(camera, event, _pos, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = true
			mouse_start = global_position
			z_cord = global_position.distance_to(camera.global_position)
			print("clicked")


func _process(delta):
	if Input.is_action_just_released("LeftClick") and is_dragging:
		is_dragging = false
		direction = (get_mouse_as_world_point() - mouse_start).normalized()
		direction = get_x_or_z_direction()
		print(direction)

func _physics_process(delta):
	move_and_collide(direction * 2 * delta)

func get_mouse_as_world_point() -> Vector3:
	var mouse_pos : Vector3 = get_viewport().get_camera_3d().project_position(get_viewport().get_mouse_position(), z_cord) 
	return mouse_pos
	
func get_x_or_z_direction() -> Vector3:
	direction = Vector3(round(direction.x), 0, round(direction.z))
	if direction.x != 0 and direction.z != 0:
		return Vector3.ZERO
	return direction
		
