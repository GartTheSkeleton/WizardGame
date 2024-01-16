extends Node3D

var open = false
var locked = false

@onready var my_sprite = $Doorsprite
@onready var my_body = $Doorsprite/StaticBody3D/Sprite3D
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dist_to_player = global_position.distance_to(player.global_position)
	
	if dist_to_player < 4:
		open = true
	else:
		open = false

	if open == true:
		my_sprite.play("open")
		my_body.disabled = true
	else:
		my_sprite.play("closed")
		my_body.disabled = false
