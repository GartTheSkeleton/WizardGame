extends CharacterBody3D

#import references
@onready var animated_sprite_2d = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var ray_cast_3d = $Camera3D/RayCast3D
@onready var shoot_sound = $ShootSound
@onready var health_bar = $CanvasLayer/UI/Label
@onready var camera = $Camera3D

#call variables
const SPEED = 6.0
const MOUSE_SENS = 0.5
const gravity = 0.7

var truespeed = SPEED
var can_shoot = true
var dead = false
var running = false
var stamina = 200
var maxstamina = 200
var tired = false

var hurt = false
var hurt_timer = 0

var curr_spell = 0
var spells = ["Magic Missile","Hexing Beam"]
var idle_timer = 0
var idle_length = 160
var idle = true
var last_spell = 0
var spell

var maxhp = 100
var hp = 100
var mana = 100
var shield = 0

var jumpstr = 14

var dir = Vector3(0,0,0)


#preloading the spell objects
var arcane_missile = preload("res://missile.tscn")


func _ready():
	#turn on captured mouse mode
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#This triggers a function when the Hand Sprites finish playing an animation
	animated_sprite_2d.animation_finished.connect(shoot_anim_done) 
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
	
	#check if we're idling after a spell for animation purposes
	if idle == false:
		if idle_timer > 0:
			idle_timer -= 1
		else:
			idle = true
			animated_sprite_2d.play("idle")
	
	#check for weapon switching
	if Input.is_action_just_pressed("scroll_down"):
		if curr_spell == 0:
			curr_spell = spells.size() - 1
		else:
			curr_spell -= 1
	if Input.is_action_just_pressed("scroll_up"):
		if curr_spell == spells.size() - 1:
			curr_spell = 0
		else:
			curr_spell += 1
	if Input.is_action_just_pressed("press_1"):
		if curr_spell != 0:
			curr_spell = 0
	if Input.is_action_just_pressed("press_2"):
		if curr_spell != 1:
			curr_spell = 1

	#Check quite/restart inputs
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
		
	#Sprint logic
	if Input.is_action_pressed("sprint") and tired == false:
		stamina -= 1
		if stamina <= 0:
			tired = true
		else:
			truespeed = SPEED + 6
	else: if stamina < maxstamina and tired == false:
		stamina += 1
	
	if tired == true:
		if stamina < maxstamina:
			stamina += 1
		else:
			tired = false
	
	

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


func restart():
	get_tree().reload_current_scene()

func shoot():
	if !can_shoot:
		return
	can_shoot = false
	idle = false
	match curr_spell: #switch through the spells for the current one
		0:
			animated_sprite_2d.play("missile cast")
			last_spell = curr_spell
			
			arcane_shot()
			
			#if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("is_enemy"):
			#	target_enemy = ray_cast_3d.get_collider()
			#else:
			#	target_enemy = -1
		1:
			animated_sprite_2d.play("hex cast")
			last_spell = curr_spell
			
			burst_shot()
			
			

	idle_timer = idle_length #Set the timer for idle animations

func shoot_anim_done(): #logic that applies after the shoot animation finishes
	can_shoot = true
	
	match last_spell:
		0:
			animated_sprite_2d.play("missile idle")
		1:
			animated_sprite_2d.play("hex idle")
	#animated_sprite_2d.play("idle")

func kill():
	dead = true
	$CanvasLayer/DeathScreen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func arcane_shot(): #spawns an Arcane Shot
	await get_tree().create_timer(0.2).timeout
	spell = arcane_missile.instantiate()
	spell.type = 0
	spell.position = ray_cast_3d.global_position
	spell.transform.basis = ray_cast_3d.global_transform.basis
	get_parent().add_child(spell)

	
func spawn_missile(): #spawns an Arcane Missile
	await get_tree().create_timer(0.5).timeout
	spell = arcane_missile.instantiate()
	spell.type = 1
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

func update_ui(): #UI Logic
	health_bar.text = str(hp)
	
func is_player(): #Player identification method
	print("I'm the player!")
