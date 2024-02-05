extends CharacterBody3D

#import references
@onready var animated_sprite_2d = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var offhand_sprite = $CanvasLayer/GunBase/LeftHand
@onready var ray_cast_3d = $Camera3D/RayCast3D
@onready var shoot_sound = $ShootSound
@onready var health_bar = $CanvasLayer/UI/Label
@onready var extra_text = $CanvasLayer/UI/Label2
@onready var camera = $Camera3D
@onready var tutorial = $CanvasLayer/Label
@onready var blast_pos = $BlastNode

#call variables
const SPEED = 6.0
const MOUSE_SENS = 0.4
const gravity = 0.7

var truespeed = SPEED
var can_shoot = true
var can_cast = true
var dead = false
var running = false
var stamina = 200
var maxstamina = 200
var tired = false

var hurt = false
var hurt_timer = 0
var hurt_time = 10

var has_green = false
var has_red = false
var has_yellow = false
var has_cyan = false
var has_black = false

var curr_spell = 0
var spells = ["Magic Missile","Hexing Beam"]
var curr_offhand = 0
var offhands = ["Heal", "Shield", "Force"]
var idle_timer = 0
var idle_length = 160
var idle = true
var last_spell = 0
var spell
var maxspell = 0
var next_anim
var offhand
var maxoffhand = 2
var cooldown = 0

var cyan_cooldown = 85
var cyan_cooltime = 85

var magenta_cooldown = 85
var magenta_cooltime = 85

var yellow_cooldown = 85
var yellow_cooltime = 85

var black_cooldown = 85
var black_cooltime = 85

var maxhp = 100
var hp = 100
var maxmana = 100
var mana = 100
var manatimer = 0
var manatimerlength = 80

var spell_damage = 2

var blasting = false

var shield = 0

var jumpstr = 14

var dir = Vector3(0,0,0)
var headbob = 1
var headbobcounter = 8
var offset = 0

#preloading the spell objects
var arcane_missile = preload("res://missile.tscn")
var blast = preload("res://blast.tscn")

var tutorial_counter = 300

func _ready():
	#turn on captured mouse mode
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#This triggers a function when the Hand Sprites finish playing an animation
	animated_sprite_2d.animation_finished.connect(shoot_anim_done) 
	offhand_sprite.animation_finished.connect(cast_anim_done)
	#This lets the button on the deathscreen trigger a restart
	$CanvasLayer/DeathScreen/Panel/Button.button_up.connect(restart)

func _input(event):
	#Check if we're dead
	if dead:
		return
	if event is InputEventMouseMotion: #Tie mouse movement to rotation when we're alive
		rotation_degrees.y -= event.relative.x * MOUSE_SENS
		camera.rotation_degrees.x -= event.relative.y * MOUSE_SENS
		
		#Lock camera tilt
		if camera.rotation_degrees.x > 75:
			camera.rotation_degrees.x = 75
		else: if camera.rotation_degrees.x < -75:
			camera.rotation_degrees.x = -75

		
		#print(camera.transform)

func _process(delta):
	#update the UI at the start of the frame instead of the end because why not
	update_ui()
	
	#we need truespeed in order to sprint - this should get refactored
	truespeed = SPEED
	
#	if has_green == true:
#		maxspell = 1
#	if has_red == true:
#		maxspell = 2
#	if has_yellow == true:
#		maxoffhand = 1
#	if has_cyan == true:
#		maxoffhand = 2
#	if has_black == true:
#		maxoffhand = 3


	calc_cancast()


	if Input.is_action_just_pressed("switch_action"):
		if curr_offhand < maxoffhand:
			curr_offhand += 1
			swap_offhand()
		else:
			curr_offhand = 0
			swap_offhand()


	if Input.is_action_just_pressed("switch_weapon"):
		if curr_spell < maxspell:
			curr_spell += 1
			swap_weapon()
		else:
			curr_spell = 0
			swap_weapon()
			

	if Input.is_action_just_pressed("press_1"):
		if curr_spell != 0:
			curr_spell = 0
			swap_weapon()
	if Input.is_action_just_pressed("press_2") and has_green == true:
		if curr_spell != 1:
			curr_spell = 1
			swap_weapon()
	if Input.is_action_just_pressed("press_3"):
		if curr_spell != 2:
			curr_spell = 2
			swap_weapon()
			

	#Check quit and restart inputs
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()
	
	
	#check if we're dead
	if dead:
		return
	#check for shoot input
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	if Input.is_action_just_pressed("cast"):
		cast()
		
	#Sprint logic
	if blasting == false:
		if Input.is_action_pressed("sprint") and tired == false:
			stamina -= 1
			if stamina <= 0:
				tired = true
			else:
				truespeed = SPEED + 6
		else: if stamina < maxstamina and tired == false:
			stamina += 1
	else:
		truespeed = 4
		
	if tired == true:
		if stamina < maxstamina:
			stamina += 1
		else:
			tired = false
	
	if manatimer <= 0:
		if mana < maxmana:
			mana += .5
	else:
		manatimer -= 1
	

func _physics_process(delta):
	#check if we're dead
	if dead:
		return
	#check if we're hurt
	if hurt:
		print("I, THE PLAYER, HAVE BEEN HURT")
		print(hurt_timer)
		velocity = dir * SPEED
		move_and_slide()
		hurt_timer -= 1
		if hurt_timer <= 0:
			hurt = false
		return
		
	#Get movement inputs and some directional vector logic
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		dir = direction
		velocity.x = direction.x * truespeed
		velocity.z = direction.z * truespeed
	else:
		velocity.x = move_toward(velocity.x, 0, truespeed)
		velocity.z = move_toward(velocity.z, 0, truespeed)
	
	#apply gravity if we're not on the floor
	if !is_on_floor():
		velocity.y = velocity.y - gravity
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jumpstr
			print("Jumpies")
		
	#apply movements
	move_and_slide()
	
	
	if velocity.x != 0 or velocity.y != 0:
		
		headbobcounter -= 1
		
		if headbob == 1:
			camera.position.y += .03
		else:
			camera.position.y -= .03
	
		
		if headbobcounter <= 0:
			if headbob == 0:
				headbob = 1
			else:
				headbob = 0
			headbobcounter = 16


func restart():
	get_tree().reload_current_scene()

func cast():
	if !can_cast:
		return
	match curr_offhand:
		0:
			magenta_cooldown = 0
			offhand_sprite.play("healcast")
			print("CAST HEAL")
		1:
			yellow_cooldown = 0
			offhand_sprite.play("shieldcast")
			print("CAST SHIELD")
		2:
			cyan_cooldown = 0
			offhand_sprite.play("forcecast")
			print("CAST FORCE")
		3:
			black_cooldown = 0
			offhand_sprite.play("oncooldown")
			print("BUNGUS")
	offhand_sprite.state = "cast"


func shoot():
	if !can_shoot:
		return
	idle = false
	match curr_spell: #switch through the spells for the current one
		0:
			if mana >= 5:
				can_shoot = false
				mana -= 5
				animated_sprite_2d.play("missile cast")
				last_spell = curr_spell
				manatimer = manatimerlength
				arcane_shot()

		1:
			if mana >= 20:
				can_shoot = false
				mana -= 20
				animated_sprite_2d.play("hex cast")
				last_spell = curr_spell
				manatimer = manatimerlength
				burst_shot()
			
		2:
			if mana >= 35:
				can_shoot = false
				mana -= 35
				animated_sprite_2d.play("blast cast")
				last_spell = curr_spell
				manatimer = manatimerlength
				blast_shot()

	idle_timer = idle_length #Set the timer for idle animations

func shoot_anim_done(): #logic that applies after the shoot animation finishes
	can_shoot = true
	
	if blasting == true:
		blasting = false
	
	match curr_spell:
		0:
			animated_sprite_2d.play("missile idle")
		1:
			animated_sprite_2d.play("hex idle")
		2:
			animated_sprite_2d.play("blast idle")
			
func cast_anim_done():
	pass



func kill():
	dead = true
	$CanvasLayer/DeathScreen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func arcane_shot(): #spawns an Arcane Shot
	await get_tree().create_timer(0.2).timeout
	spell = arcane_missile.instantiate()
	spell.type = 0
	spell.damage = spell_damage
	spell.position = ray_cast_3d.global_position
	spell.transform.basis = ray_cast_3d.global_transform.basis
	get_parent().add_child(spell)

	
func spawn_missile(): #spawns an Burst Missile
	
	await get_tree().create_timer(0.5).timeout
	spell = arcane_missile.instantiate()
	spell.type = 1
	spell.damage = (spell_damage/2)
	spell.position = ray_cast_3d.global_position
	spell.transform.basis = ray_cast_3d.global_transform.basis
	get_parent().add_child(spell)

func burst_shot(): #Burst Shot of Arcane Missiles
	spawn_missile()
	await get_tree().create_timer(0.1).timeout
	spawn_missile()
	await get_tree().create_timer(0.1).timeout
	spawn_missile()
	await get_tree().create_timer(0.1).timeout
	spawn_missile()

func blast_shot():
	blasting = true
	
	
	spell = blast.instantiate()
	spell.damage = spell_damage
	spell.position = blast_pos.global_position
	spell.transform.basis = global_transform.basis
	get_parent().add_child(spell)


func swap_weapon():
	if can_shoot == true:
		match curr_spell:
			0:
				animated_sprite_2d.play("missile idle")
			1:
				animated_sprite_2d.play("hex idle")
			2:
				animated_sprite_2d.play("blast idle")

func swap_offhand():
	calc_cancast()
	if can_cast == true:
		match curr_offhand:
			0:
				offhand_sprite.play("healidle")
			1:
				offhand_sprite.play("shieldidle")
			2:
				offhand_sprite.play("forceidle")
			3:
				offhand_sprite.play("oncooldown")
	else:
		offhand_sprite.play("oncooldown")


func calc_cancast():
	if magenta_cooldown < magenta_cooltime:
		magenta_cooldown += 1
		if curr_offhand == 0:
			can_cast = false
	else:
		if curr_offhand == 0:
			can_cast = true
	if yellow_cooldown < yellow_cooltime:
		yellow_cooldown += 1
		if curr_offhand == 1:
			can_cast = false
	else:
		if curr_offhand == 1:
			can_cast = true
	if cyan_cooldown < cyan_cooltime:
		cyan_cooldown += 1
		if curr_offhand == 2:
			can_cast = false
	else:
		if curr_offhand == 2:
			can_cast = true
	if black_cooldown < black_cooltime:
		black_cooldown += 1
		if curr_offhand == 3:
			can_cast = false
	else:
		if curr_offhand == 3:
			can_cast = true

func update_ui(): #UI Logic
	var uitext = "HP: " + str(hp) + " MANA: " + str(floor(mana))
	var uitext2 = "Magenta: " + str(magenta_cooldown) + "Yellow: " + str(yellow_cooldown) + "Cyan: " + str(cyan_cooldown)
	health_bar.text = uitext
	extra_text.text = uitext2
	
	
	tutorial_counter -= 1
	if tutorial_counter <= 0:
		tutorial.visible = false
	
func is_player(): #Player identification method
	print("I'm the player!")
