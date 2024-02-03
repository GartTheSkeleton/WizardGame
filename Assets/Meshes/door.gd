extends Node3D

var open = false
var locked = false

@onready var my_sprite = $Doorsprite
@onready var my_sprite2 = $Doorsprite2
@onready var my_body = $Doorsprite/StaticBody3D/Sprite3D
@onready var collisionshape = $Doorsprite/CollisionShape3D
@onready var lock_sprite1 = $Locksprite
@onready var lock_sprite2 = $Locksprite2
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")



@export var type = 0
#0 = none
#1 = green
#2 = yellow
#3 = cyan
#4 = red
#5 = black

# Called when the node enters the scene tree for the first time.
func _ready():
	lock_sprite1.animation_finished.connect(anim_done) 
	if type == 0:
		open = true
		lock_sprite1.visible = false
		lock_sprite2.visible = false
	else:
		match type:
			1:
				lock_sprite1.play("green_lock")
				lock_sprite2.play("green_lock")
			2:
				lock_sprite1.play("yellow_lock")
				lock_sprite2.play("yellow_lock")
			3:
				lock_sprite1.play("cyan_lock")
				lock_sprite2.play("cyan_lock")
			4:
				lock_sprite1.play("red_lock")
				lock_sprite2.play("red_lock")
			5:
				lock_sprite1.play("black_lock")
				lock_sprite2.play("black_lock")
		lock_sprite1.visible = true
		lock_sprite2.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dist_to_player = global_position.distance_to(player.global_position)
	
	if dist_to_player <= 4:
		if type == 0:
			open = true
			#lock_sprite1.visible = false
			#lock_sprite2.visible = false
		else:
			lock_sprite1.visible = true
			lock_sprite2.visible = true
			match type:
				1: #green
					if player.curr_spell == 1:
						#type = 0
						lock_sprite1.play("green_unlock")
						lock_sprite2.play("green_unlock")
				2: #yellow
					if player.curr_offhand == 1:
						#type = 0
						lock_sprite1.play("yellow_unlock")
						lock_sprite2.play("yellow_unlock")
				3: #cyan
					if player.curr_offhand == 2:
						#type = 0
						lock_sprite1.play("cyan_unlock")
						lock_sprite2.play("cyan_unlock")
				4: #red
					if player.curr_spell == 2:
						#type = 0
						lock_sprite1.play("red_unlock")
						lock_sprite2.play("red_unlock")
				5: #black
					if player.curr_offhand == 3:
						#type = 0
						lock_sprite1.play("black_unlock")
						lock_sprite2.play("black_unlock")
	else:
			open = false

		

	if open == true:
		my_sprite.play("open")
		my_sprite2.play("open")
		my_body.disabled = true
		collisionshape.position.y = -1000000
	else:
		my_sprite.play("closed")
		my_sprite2.play("closed")
		my_body.disabled = false
		collisionshape.position.y = 0

func anim_done():
	type = 0
	lock_sprite1.visible = false
	lock_sprite2.visible = false
