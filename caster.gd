extends Enemy


#preloading the spell objects
var arcane_missile = preload("res://missile.tscn")

@onready var Head = $Head

const turn_speed = 2

var spell
var cooldown = 30

func  _ready():
	super()
	type = 1
	range = 35
	aggro_radius = 20
	move_speed = 3


func _physics_process(delta):
	super(delta)
	
	
	#print(result)

func attack_player():
	super()
	
	if ai_state == "attacking":
		if cooldown <= 0:
			Head.look_at(player.global_transform.origin, Vector3.UP)
			var bullet_dir = player.global_position - global_position
			spell = arcane_missile.instantiate()
			spell.type = 2
			spell.position = Vector3(position.x,position.y+1,position.z)
			spell.transform.basis = Head.transform.basis
			get_parent().add_child(spell)
			ai_state = "idle"
			cooldown = 65
		else:
			cooldown -= 1
		
		
	
