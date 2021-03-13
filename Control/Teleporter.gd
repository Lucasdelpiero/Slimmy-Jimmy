extends Area2D

onready var target = $Target

func _on_Teleporter_body_entered(body):
	body.global_position.y = target.global_position.y
	body.velocity.y = 0.0
