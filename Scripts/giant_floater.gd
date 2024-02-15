extends Enemy

var arcane_missile = preload("res://missile.tscn")

@onready var Head = $Head
@onready var Mouth = $Head/Mouth
@onready var LeftLow = $Head/LeftLow
@onready var LeftMid = $Head/LeftMid
@onready var LeftHigh = $Head/LeftHigh
@onready var RightLow = $Head/RightLow
@onready var RightMid = $Head/RightMid
@onready var RightHigh = $Head/RightHigh


var spell

func  _ready():
	super()
	hurt_time = 30
	type = 1
	aggro_radius = 50
	move_speed = 4
	range = 80
	hp = 25
	my_cooldown = 70


func _physics_process(delta):
	super(delta)

func attack_player():
	super()
	
	if ai_state == "attacking":
		#look_at(player.global_position)
		#print(global_rotation)
		if attacked == false:	
			if cooldown <= 0:
				cooldown = my_cooldown
				attacked = true
				ai_state = "idle"
				
				spawn_missile(LeftMid)
				spawn_missile(RightMid)
				await get_tree().create_timer(0.4).timeout
				spawn_missile(LeftHigh)
				spawn_missile(RightHigh)
				fire_blast()
				await get_tree().create_timer(0.4).timeout
				spawn_missile(LeftLow)
				spawn_missile(RightLow)
				
				

func spawn_missile(hand):
	Head.look_at(player.global_transform.origin, Vector3.UP)

	hand.look_at(player.global_position, Vector3.UP)
	hand.look_at(player.global_position, Vector3.UP)
	animated_sprite_3d.play("attacking")
	var bullet_dir = player.global_position - global_position
	spell = arcane_missile.instantiate()
	spell.type = 2
	spell.position = Vector3(hand.global_position.x,hand.global_position.y,hand.global_position.z)
	spell.transform.basis = hand.global_transform.basis
	get_parent().add_child(spell)

func fire_blast():
	spawn_missile(Mouth)
	await get_tree().create_timer(0.05).timeout
	spawn_missile(Mouth)
	await get_tree().create_timer(0.05).timeout
	spawn_missile(Mouth)
	await get_tree().create_timer(0.05).timeout
	spawn_missile(Mouth)
	await get_tree().create_timer(0.05).timeout
	spawn_missile(Mouth)
	await get_tree().create_timer(0.05).timeout
	spawn_missile(Mouth)
