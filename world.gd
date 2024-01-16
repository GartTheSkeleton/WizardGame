extends Node3D

var level = preload("res://Castle01.tscn")

var level01

# Called when the node enters the scene tree for the first time.
func _ready():
	level01 = level.instantiate()
	add_child(level01)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
