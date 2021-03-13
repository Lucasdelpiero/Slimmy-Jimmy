extends StaticBody2D

onready var collision = $Area2D/CollisionPolygon2D

func _on_Area2D_area_entered(area):
	collision.call_deferred("set", "disabled" , true)
