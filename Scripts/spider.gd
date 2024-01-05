extends Enemy

func  _ready():
	super()
	type = 0
	aggro_radius = 2
	move_speed = 4


func _physics_process(delta):
	super(delta)

func attack_player():
	super()
	
	if ai_state == "attacking":
		if attacked == false:
			var eye_line = Vector3.UP * 1.5
			var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, player.global_position,3.5)
			var result = get_world_3d().direct_space_state.intersect_ray(query)
			attacked = true
			await get_tree().create_timer(0.3).timeout
			print(result)
			if result:
				if result.collider.has_method("is_player") and player.hurt == false:
					player.hp -= 5
					player.hurt = true
					player.hurt_timer = 12
					player.dir = player.global_position - global_position
					player.dir.y = 0.0

