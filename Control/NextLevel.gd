extends Area2D

export(Resource) var next_level

onready var sprite = $Sprite
export var distance = 3.2
var angle = 0
var time = 1
export var speed = 5


func _process(delta):
	angle += speed
	sprite.position.y += sin(deg2rad(angle)) * distance


func _on_NextLevel_body_entered(body):
	get_tree().change_scene_to(next_level)
