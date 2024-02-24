extends Node3D

@export var type = 0

@onready var mysprite = $Sprite3D

var texture1 = load("res://Assets/Images/stairrail1.png")
var texture2 = load("res://Assets/Images/stairrail2.png")
var texture3 = load("res://Assets/Images/stairrail3.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match type:
		0: # Middle Sprite
			if mysprite.texture != texture2:
				mysprite.set_texture(texture2)
		1:
			if mysprite.texture != texture1:
				mysprite.set_texture(texture1)
		2:
			if mysprite.texture != texture3:
				mysprite.set_texture(texture3)
