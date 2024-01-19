extends Missile

var lifespan = 100


@onready var area = $Area3D
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var sprite1 = $AnimatedSprite3D
@onready var sprite2 = $AnimatedSprite3D2

# Called when the node enters the scene tree for the first time.
func _ready():
	damage = player.spell_damage
	sprite1.frame = 0
	sprite2.frame = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	lifespan -= 1
	#global_position.y += .04
	scale += Vector3(.05,.05,.05)
	if lifespan <= 0:
		queue_free()
	
	
	
	if area.has_overlapping_bodies():
		var collisions = area.get_overlapping_bodies()
		for i in len(collisions):
			if collisions[i].has_method("is_enemy") and collisions[i].blasttimer == 0:
				print("Hit an enemy")
				collisions[i].hp -= damage
				collisions[i].hurt = true
				collisions[i].hurt_timer = 10
				collisions[i].dir = collisions[i].global_position - global_position
				collisions[i].dir.y = 0.0
				collisions[i].blasttimer = 30
				if collisions[i].hp <= 0:
					collisions[i].kill()


func _physics_process(delta):
	position += transform.basis * Vector3(0,0,-2) * delta
