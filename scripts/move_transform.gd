extends StaticBody3D

@export var move_speed : float
@export var ray_length: float
@export var ray_lenth_down : float
var is_selected : bool = false
var is_moving : bool = false
var going_down : bool = false
var is_dragging : bool = false
var mouse_start : Vector3 = Vector3()
var direction : Vector3 = Vector3()
var offset : Vector3 = Vector3()
var z_cord: float = 0


func _ready():
	#set_process_input(true)

func _on_input_event(camera, event, _pos, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = true
			mouse_start = global_position
			z_cord = global_position.distance_to(camera.global_position)

func _on_mouse_entered():
	is_selected = true

func _process(delta):
	if Input.is_action_just_released("LeftClick") and is_dragging:
		is_dragging = false
		is_moving = true
		direction = (get_mouse_as_world_point() - mouse_start).normalized()
		direction = get_x_or_z_direction()
		print("Move direction: ", direction)
		
	if is_moving:
		if going_down:
			global_position += move_speed * Vector3.DOWN * delta
		else:
			global_position += move_speed * direction * delta
	
	if direction == Vector3.ZERO:
		is_moving = false

func _physics_process(_delta):
	if is_moving:
		var raycast_result = ray_cast(global_position, direction, ray_length)
		if !raycast_result.is_empty():
			direction = Vector3.ZERO
		
		var raycast_down_result = ray_cast(global_position - direction * 0.5, Vector3.DOWN, ray_lenth_down)
		if !raycast_down_result.is_empty():
			if global_position.distance_to(raycast_down_result.position) >= 1:
				going_down = true
			else:
				going_down = false

func get_mouse_as_world_point() -> Vector3:
	var mouse_pos : Vector3 = get_viewport().get_camera_3d().project_position(get_viewport().get_mouse_position(), z_cord) 
	return mouse_pos
	
func get_x_or_z_direction() -> Vector3:
	direction = Vector3(round(direction.x), 0, round(direction.z))
	if direction.x != 0 and direction.z != 0:
		return Vector3.ZERO
	return direction

func ray_cast(start: Vector3, dir: Vector3, length:float) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var end : Vector3 = start + dir * length
	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	return result
