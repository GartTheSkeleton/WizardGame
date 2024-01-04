extends CharacterBody3D

class_name Enemy

@onready var animated_sprite_3d = $AnimatedSprite3D

@export var move_speed = 3
@export var attack_range = 2.0

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var ray_cast = $RayCast3D

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

var my_cooldown = 10
var cooldown = my_cooldown

func _ready():
	animated_sprite_3d.animation_finished.connect(anim_done) 
	
	dir = Vector3(0,0,0)
	
	dir.y = 0.0
	dir = dir.normalized()
	velocity = dir * 1
	
#func _process(delta):
#
#	pass

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
		animated_sprite_3d.play("hurt")
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

