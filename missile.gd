extends Node3D

var SPEED = 40
var type = 0
var dead = false
var range
var timer
var target_type

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
			target_type = "Enemy"
		2:
			SPEED = 20
			range = 50
			target_type = "Player"
	
	timer = range
	
func _physics_process(delta):
	if timer <= 0:
		animated_sprite.play("pop")
		dead = true
	timer -= 1
	
	if !dead:
		if ray.is_colliding():
			
			if ray.get_collider().is_in_group(target_type):
				animated_sprite.play("pop")
				dead = true
				
				if ray.get_collider().has_method("kill"):
					if ray.get_collider().hp > 0:
						ray.get_collider().hp -= 1
						ray.get_collider().hurt = true
						ray.get_collider().hurt_timer = 10
						ray.get_collider().dir = ray.get_collider().global_position - global_position
						ray.get_collider().dir.y = 0.0
					else:
						ray.get_collider().kill()
			else:
				animated_sprite.play("pop")
				dead = true

		else:
			position += transform.basis * Vector3(0,0,-SPEED) * delta
		
func anim_end():
	if dead:
		queue_free()
