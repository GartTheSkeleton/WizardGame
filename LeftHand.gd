extends AnimatedSprite2D

var state = "idle"

var parent_variable

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")


func _ready():
	animation_finished.connect(anim_done)
	
	match player.curr_offhand:
		0:
			play("healidle")
		1:
			play("shieldidle")
		2:
			play("forceidle")
		3:
			play("shieldidle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	print(player.curr_offhand)
	
	match state:
		"idle":
			match player.curr_offhand:
				0:
					if player.can_cast == true:
						play("healidle")
				1:
					if player.can_cast == true:
						play("shieldidle")
				2:
					if player.can_cast == true:
						play("forceidle")
				3:
					if player.can_cast == true:
						play("shieldidle")
		"cast":
			pass
		"cooldown":
			match player.curr_offhand:
				0:
					if player.can_cast == true:
						play("healidle")
						state = "idle"
				1:
					if player.can_cast == true:
						play("shieldidle")
						state = "idle"
				2:
					if player.can_cast == true:
						play("forceidle")
						state = "idle"
				3:
					if player.can_cast == true:
						play("shieldidle")
						state = "idle"

func anim_done():
	if state == "cast":
		play("oncooldown")
		state = "cooldown"
