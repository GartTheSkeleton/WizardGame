extends Node3D

@onready var sprite1 = $Sprite3D
@onready var sprite2 = $Sprite3D2
@onready var trigger = $Area3D
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

@export var type = 0
#1 = green
#2 = yellow
#3 = cyan
#4 = red
#5 = black

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite1.rotation_degrees.y += 1
	sprite2.rotation_degrees.y += 1
	
	if trigger.has_overlapping_bodies():
		print("colliding")
		var collisions = trigger.get_overlapping_bodies()
		for i in len(collisions):
			if collisions[i].has_method("is_player"):
				match type:
					1:
						collisions[i].has_green = true
						player.curr_spell = 1
						player.swap_weapon()
						queue_free()
					2:
						collisions[i].has_yellow = true
						player.curr_offhand = 1
						player.swap_offhand()
						queue_free()
					3:
						collisions[i].has_cyan = true
						player.curr_offhand = 2
						player.swap_offhand()
						queue_free()
					4:
						collisions[i].has_red = true
						player.curr_spell = 2
						player.swap_weapon()
						queue_free()
					5:
						collisions[i].has_black = true
						queue_free()
