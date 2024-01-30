extends AnimatedSprite2D

var state = "idle"

var parent_variable

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match player.curr_offhand:
		0:
			play("healidle")
		1:
			play("shieldidle")
		2:
			play("forceidle")
		3:
			play("shieldcast")
		
