extends Node3D

const SPEED = 40

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

func _ready():
	pass
	
func _physics_process(delta):
	position += transform.basis * Vector3(0,0,-SPEED) * delta
	
	if ray.is_colliding():
		
		if ray.get_collider().has_method("kill"):
			if ray.get_collider().hp > 0:
				ray.get_collider().hp -= 1
				ray.get_collider().hurt = true
				ray.get_collider().hurt_timer = 10
				ray.get_collider().dir = ray.get_collider().global_position - global_position
				ray.get_collider().dir.y = 0.0
			else:
				ray.get_collider().kill()
		
		print(ray.get_collider())
		
		print("OOPS I DIED UWU")
		
		queue_free()
