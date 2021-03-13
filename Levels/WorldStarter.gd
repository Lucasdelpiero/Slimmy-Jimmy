extends Node2D

var Options = preload("res://Control/OptionsLayer.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var options = Options.instance()
	add_child(options)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
