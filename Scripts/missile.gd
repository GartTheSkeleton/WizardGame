extends Node3D

class_name Missile

var SPEED = 40
var type = 0
var dead = false
var range
var timer
var damage = 5
var target_type = ""
var ignore_type = ""

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var animated_sprite = $AnimatedSprite3D

func _ready():
	animated_sprite.animation_finished.connect(anim_end) 
	match type:
		0:
			SPEED = 90
			ray.target_position.z = -2
			range = 150
			target_type = "Enemy"
		1:
			SPEED = 40
			range = 60
			ray.target_position.z = -2
			target_type = "Enemy"
		2:
			SPEED = 20
			range = 500
			target_type = "player"
			ignore_type = "Enemy"
	
	timer = range
	
func _physics_process(delta):
	if timer <= 0:
		animated_sprite.play("pop")
		#print(damage)
		dead = true
	timer -= 1
	
	if !dead:
		if ray.is_colliding():
			
			if ray.get_collider().is_in_group(target_type):
				animated_sprite.play("pop")
				print(damage)
				dead = true
				
				if ray.get_collider().has_method("kill"):
					if ray.get_collider().hp > 0:
						ray.get_collider().hp -= damage
						ray.get_collider().hurt = true
						ray.get_collider().hurt_timer = 10
						ray.get_collider().dir = ray.get_collider().global_position - global_position
						ray.get_collider().dir.y = 0.0
						if ray.get_collider().hp <= 0:
							ray.get_collider().kill()
					else:
						ray.get_collider().kill()
			else:
				if ray.get_collider().is_in_group(ignore_type):
					position += transform.basis * Vector3(0,0,-SPEED) * delta
				else:
					animated_sprite.play("pop")
					dead = true

		else:
			position += transform.basis * Vector3(0,0,-SPEED) * delta
		
func anim_end():
	if dead:
		queue_free()
