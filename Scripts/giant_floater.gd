extends Enemy

var arcane_missile = preload("res://missile.tscn")

@onready var Head = $Head

var spell

func  _ready():
	super()
	type = 1
	aggro_radius = 50
	move_speed = 4
	range = 80
	hp = 25
	my_cooldown = 65


func _physics_process(delta):
	super(delta)

func attack_player():
	super()
	
	if ai_state == "attacking":
		if attacked == false:	
			if cooldown <= 0:
				Head.look_at(player.global_transform.origin, Vector3.UP)
				var bullet_dir = player.global_position - global_position
				spell = arcane_missile.instantiate()
				spell.type = 2
				spell.position = Vector3(Head.global_position.x,Head.global_position.y,Head.global_position.z)
				spell.transform.basis = Head.transform.basis
				get_parent().add_child(spell)
				cooldown = my_cooldown
				attacked = true
				ai_state = "idle"
