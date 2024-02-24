extends Node3D

@export var height = 12
@export var width = 2

@export var state = 0

@export var elevatordirection = "uppies"

@export var spd = .5

var offset = 0

var origin_y  = 0

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var cube = $DaCube

# Called when the node enters the scene tree for the first time.
func _ready():
	origin_y = global_position.y



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dist_to_player = global_position.distance_to(player.global_position)
	
	match state:
		0: #Neutral State - Waiting for player
			if dist_to_player <= 2.5:
				state = 1
		1: #Moving to target position
			if elevatordirection == "uppies":
				if global_position.y < origin_y + height:
					global_position.y += spd
				else:
					global_position.y = origin_y + height
					state = 2
			else:
				if global_position.y > origin_y - height:
					global_position.y -= spd
					if dist_to_player < 4:
						player.global_position.y -= spd
				else:
					global_position.y = origin_y - height
					state = 2
		2: #Fully moved - Waiting for player to leave
			if dist_to_player >= 4.0:
				state = 3
		3: #Returning to neutral position
			if elevatordirection == "uppies":
				if global_position.y > origin_y:
					global_position.y -= spd
				else:
					global_position.y = origin_y
					state = 0
			else:
				if global_position.y < origin_y:
					global_position.y += spd
				else:
					global_position.y = origin_y
					state = 0
	
#	if dist_to_player <= 2.1 and global_position.y == origin_y:
#		state = 1
#	else:
#		if elevatordirection == "uppies":
#			if global_position.y == origin_y + height:
#				state = 0
#		else:
#			if global_position.y == origin_y - height:
#				state = 0
		

