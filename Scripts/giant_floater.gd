extends Enemy

func  _ready():
	super()
	type = 1
	aggro_radius = 6
	move_speed = 4
	range = 80
	hp = 25


func _physics_process(delta):
	super(delta)
