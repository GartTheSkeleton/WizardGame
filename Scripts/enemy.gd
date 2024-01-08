extends CharacterBody3D

class_name Enemy

@onready var animated_sprite_3d = $AnimatedSprite3D

@export var move_speed = 3
@export var attack_range = 2.0

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var player_ray = $WatchPlayer
@onready var ray_cast = $RayCast3D
@onready var navmesh: NavigationAgent3D = $NavigationAgent3D

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
var type = 0
var aggro_radius = 1.5
var attacked = false
var adjusttimer = 12

var my_cooldown = 10
var cooldown = my_cooldown

func _ready():
	animated_sprite_3d.animation_finished.connect(anim_done) 
	
	player_ray.set_target_position(player.global_position)
	
	dir = Vector3(0,0,0)
	
	dir.y = 0.0
	dir = dir.normalized()
	velocity = dir * 1
	
func _process(delta):
	
#	print(player_ray.get_collider())
#	print(player_ray.is_colliding())
	print("ACTIVE:" + str(active))

func _physics_process(delta):
	if dead:
		return
	if player == null:
		return
	
	var distanceToPlayer = getDistanceToPlayer()
	
	player_ray.set_target_position(player.global_position)
	
	if player_ray.is_colliding() == false:
		print("Not colliding")
		if distanceToPlayer <= range:
			print("IN RANGE")
			if active == false:
				active = true
				print("I HAVE ACTIVATED")
	else:
		print("Colliding")

	
	navmesh.target_position = player.global_position
	
	if hurt == true:
		print("I, AN ENEMY, HAVE BEEN HURT")
		animated_sprite_3d.play("hurt")
		dir = dir.normalized()
		velocity = dir * move_speed
		move_and_slide()
		hurt_timer -= 1
		if hurt_timer <= 0:
			hurt = false
	else: if active == true:
		
#		dir = player.global_position - global_position
#
#		dir.y = 0.0
#		dir = dir.normalized()
#
#		velocity = dir * move_speed
		
		var direction = Vector3()
		
		direction = navmesh.get_next_path_position() - global_position
		direction = direction.normalized()
		
		velocity = direction * move_speed
		
	else:
		velocity = Vector3(0,0,0)
	
	if ai_state == "chasing":
		move_and_slide()
	attack_player()

func attack_player():
	
	match ai_state:
		"idle":
			if attacked == true:
				attacked = false
			if active == true:
				ai_state = "chasing"

		"chasing":
			var dist_to_player = global_position.distance_to(player.global_position)
			
			if dist_to_player < aggro_radius:
				ai_state = "attacking"
				

		"attacking":
			var dist_to_player = global_position.distance_to(player.global_position)
			if cooldown <= 0:
				animated_sprite_3d.play("attacking")
			else:
				cooldown -= 1


func kill():
	dead = true
	animated_sprite_3d.play("death")
	$CollisionShape3D.disabled = true

func anim_done():
	if !dead:
		animated_sprite_3d.play("idle")
		ai_state = "idle"
		cooldown = my_cooldown

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

