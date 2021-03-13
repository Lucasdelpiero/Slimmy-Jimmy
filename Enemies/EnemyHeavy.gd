extends KinematicBody2D

const UP = Vector2(0, -1) 
export var max_speed = 600
export var acceleration = 50
export var jump_velocity = 600
var direction = -1
var can_jump = true
export var gravity = 100
export var FRICTION = 1000
export var animation_time = 0.2
var velocity : Vector2 = Vector2.ZERO

onready var rayCastL = $RayCastLeft
onready var rayCastR = $RayCastRight
onready var tween = $Tween
onready var legL = $Position2D/SpriteLegL
onready var legR = $Position2D/SpriteLegR
var initial_position = Vector2(0.0, 0.0)
var high_position = Vector2(0.0, -40.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not rayCastL.is_colliding() :
		direction = 1
	if not rayCastR.is_colliding() :
		direction = -1

	if velocity.x == 0.0:
		direction = -direction
	velocity.y += gravity
	velocity.x = direction * max_speed
	
	move_animation()
	
	velocity = move_and_slide(velocity, UP)
	pass

func move_animation():
	if not tween.is_active():
		tween.interpolate_property(legL, "position", initial_position, high_position, animation_time,Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.start()
		tween.interpolate_property(legR, "position", high_position, initial_position, animation_time,Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.start()
		
		tween.interpolate_property(legR, "position", initial_position, high_position, animation_time,Tween.TRANS_QUAD, Tween.EASE_OUT, animation_time)
		tween.start()
		tween.interpolate_property(legL, "position", high_position, initial_position, animation_time,Tween.TRANS_QUAD, Tween.EASE_OUT, animation_time)
		tween.start()
	pass


func _on_Timer_timeout():
	$AudioStreamPlayer/Timer.start()
	if $VisibilityNotifier2D.is_on_screen():
		$AudioStreamPlayer.play()
