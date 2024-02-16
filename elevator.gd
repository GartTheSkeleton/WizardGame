extends Node3D

@export var height = 12
@export var width = 2

@export var state = 0

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
	
	if dist_to_player <= 2.1:
		state = 1
	else:
		state = 0
		
	if state == 1:
		print("REEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE")
		if global_position.y < origin_y + height:
			global_position.y += .75
		else:
			global_position.y = origin_y + height
	
	if state == 0:
		if global_position.y > origin_y:
			global_position.y -= .5
		else:
			global_position.y = origin_y

