extends CharacterBody3D


@onready var animated_sprite_3d = $AnimatedSprite3D

@export var move_speed = 2.0
@export var attack_range = 2.0

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var dead = false
var range = 20
var active = false
var chasing = false
var hurt = false
var hurt_timer = 0
var hp = 1
var angle_to_player = 0
var sees_player = false
var dir
var ai_state = "idle"

func _ready():
	animated_sprite_3d.animation_finished.connect(anim_done) 
	
	dir = player.global_position - global_position
	
	dir.y = 0.0
	dir = dir.normalized()
	velocity = dir * move_speed

func _process(delta):
	
	pass

func _physics_process(delta):
	if dead:
		return
	if player == null:
		return
	
	var distanceToPlayer = getDistanceToPlayer()
	
	if distanceToPlayer <= range and !active:
		active = true
			
	if hurt == true:
		print("I, AN ENEMY, HAVE BEEN HURT")
		dir = dir.normalized()
		velocity = dir * move_speed
		move_and_slide()
		hurt_timer -= 1
		if hurt_timer <= 0:
			hurt = false
	else: if active == true:
		
		dir = player.global_position - global_position
	
		dir.y = 0.0
		dir = dir.normalized()
		
		velocity = dir * move_speed
		
		var player_pos_diff_x = position.x-player.position.x
		var player_pos_diff_z = position.z-player.position.z
		
	else:
		velocity = dir * move_speed * 0
	
	move_and_slide()
	attempt_to_kill_player()

func attempt_to_kill_player():
	
	match ai_state:
		"idle":
			if active == true:
				ai_state = "chasing"

		"chasing":
			var dist_to_player = global_position.distance_to(player.global_position)
			
			if dist_to_player <= 1.5:
				ai_state = "attacking"
				animated_sprite_3d.play("attacking")
				
		
		"attacking":
			var dist_to_player = global_position.distance_to(player.global_position)
			
			var eye_line = Vector3.UP * 1.5
			var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, player.global_position+eye_line,1)
			var result = get_world_3d().direct_space_state.intersect_ray(query)
			await get_tree().create_timer(0.3).timeout
			if result.is_empty() and player.hurt == false:
				if player.hp > 0:
					player.hp -= 5
					player.hurt = true
					player.hurt_timer = 12
					player.dir = player.global_position - global_position
					player.dir.y = 0.0
				else:
					player.kill()
			ai_state = "idle"
			

func kill():
	dead = true
	$DeathSound.play()
	animated_sprite_3d.play("deathdown")
	$CollisionShape3D.disabled = true

func anim_done():
	if !dead:
		animated_sprite_3d.play("idledown")

# Function to get the distance between the "Enemy" and "Player" nodes
func getDistanceToPlayer():
	# Check if the player node exists
	if player:
		# Get the global transform of both nodes
		var enemy_global_transform = global_transform
		var player_global_transform = player.global_transform

		# Get the distance between the two nodes
		var distance = enemy_global_transform.origin.distance_to(player_global_transform.origin)

		return distance
	else:
		# Return a default value or handle the case when the player node is not found
		return -1  # You can choose a suitable default value or handle the case accordingly

func is_enemy():
	print("I'ma enemy")
