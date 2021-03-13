extends KinematicBody2D

const UP = Vector2(0.0, -1.0)
export var max_speed = 600
export var float_speed = 400
export var float_accel = 2150
export var acceleration = 50
export var jump_velocity = 600
var can_jump = true
var falling = false
export var GRAVITY = 100
export var FRICTION = 1000
const TERMINAL_VELOCITY = 900
var velocity : Vector2 = Vector2.ZERO
var input_x = 0
var STATE = NORMAL

var Corpse = preload("res://Player/PlayerDead.tscn")
var Spawner = preload("res://Player/Spawner.tscn")
var Splash = preload("res://Player/Splash.tscn")
var sprite_normal = preload("res://Player/slime.png")
var sprite_gas = preload("res://Player/slime_gas.png")
var spawner_position 
var spawner

onready var sprite = $Position2D/Sprite
onready var position2D = $Position2D
onready var spriteSmashed = $SpriteSmashed
onready var collisionN = $CollisionNormal
onready var collisionS = $CollisionSmashed
onready var rayFloorL = $RayFloorL
onready var rayFloorR = $RayFloorR
onready var rayFloorC = $RayFloorR
onready var coyoteTimer = $CotoyeTimer
onready var gasTimer = $GasTimer
onready var tween = $Tween
onready var smoke = $Smoke/Particles2D
onready var remote = $RemoteTransform2D

var scale_normal = Vector2(1.0, 1.0)
var scale_jumping = Vector2(0.8, 1.25)
var scale_landing = Vector2(1.25, 0.75)
var scale_smashed = Vector2(1.0, 0.35)
var scale_smashed_moving = Vector2(0.8, 0.5)
var current_animation = scale_normal
var target_anim = scale_normal
var animation_time = 0.2

enum {
	NORMAL,
	GAS,
	SMASHED,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree().create_timer(0.1),"timeout")
	spawner = Spawner.instance()
	get_tree().get_root().add_child(spawner)
	spawner.global_position = global_position
	spawner_position = global_position
	remote.remote_path = "../../Camera2D"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	input_x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x += input_x * acceleration
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	if rayFloorL.is_colliding() or rayFloorR.is_colliding() or rayFloorC.is_colliding():
		if STATE == NORMAL:
			if falling  :
				tween.interpolate_property(position2D, "scale", scale_normal, scale_landing, 0.2,Tween.TRANS_ELASTIC,Tween.EASE_OUT)
				tween.start()
				if velocity.x != 0.0 :
					target_anim = scale_jumping
					tween.interpolate_property(position2D, "scale", scale_landing,target_anim, 0.3,Tween.TRANS_BACK,Tween.EASE_OUT, 0.1)
					tween.start()
				else:
					target_anim = scale_normal
					tween.interpolate_property(position2D, "scale", scale_landing,target_anim, 0.4,Tween.TRANS_ELASTIC,Tween.EASE_OUT, 0.1)
					tween.start()
		can_jump = true

	if not rayFloorL.is_colliding() and not rayFloorR.is_colliding() and not rayFloorC.is_colliding():
		if coyoteTimer.is_stopped():
			coyoteTimer.start()
	
	match STATE:
		NORMAL:
			jump()
			if Input.is_action_just_released("ui_up") and velocity.y < 0:
				velocity.y = velocity.y / 2
			velocity.y += GRAVITY
			if velocity.x != 0.0 and not falling:
				move_animation()
			sprite.texture = sprite_normal
		SMASHED:
			jump()
			if Input.is_action_just_released("ui_up") and velocity.y < 0:
				velocity.y = velocity.y / 2
			velocity.y += GRAVITY
			if velocity.x != 0.0 and not tween.is_active():
				tween.interpolate_property(position2D, "scale", scale_smashed, scale_smashed_moving, animation_time,Tween.TRANS_BACK,Tween.EASE_OUT)
				tween.start()
				tween.interpolate_property(position2D, "scale", scale_smashed_moving, scale_smashed, animation_time,Tween.TRANS_BACK,Tween.EASE_OUT, animation_time)
				tween.start()
		GAS:
			position2D.scale = Vector2(1.0, 1.0)
			velocity.y = move_toward(velocity.y, -float_speed, float_accel * delta)
			sprite.texture = sprite_gas
			
	velocity.y = clamp(velocity.y, -jump_velocity, TERMINAL_VELOCITY)
	
	set_current_animation()
	
	velocity = move_and_slide(velocity)
	
	if velocity.y > 0.0:
		falling = true
	else:
		falling = false

func jump():
	if Input.is_action_just_pressed("ui_up") and can_jump:
		velocity.y = -jump_velocity
		can_jump = false
		tween.remove_all()
		$AudioJump.play()
		if STATE == NORMAL:
			position2D.scale = Vector2(1.0, 1.0)
			tween.interpolate_property(position2D, "scale", scale_normal, scale_jumping, 0.2,Tween.TRANS_BACK,Tween.EASE_OUT)
			tween.start()
			tween.interpolate_property(position2D, "scale", scale_jumping, scale_normal, 0.4, Tween.TRANS_BACK,Tween.EASE_OUT,0.2)
			tween.start()

func move_animation():
	if not tween.is_active():
		var delay = 0.0
		if current_animation != scale_jumping:
			tween.interpolate_property(position2D, "scale", current_animation, scale_jumping, animation_time,Tween.TRANS_CUBIC,Tween.EASE_OUT)
			tween.start()
			delay = animation_time
		tween.interpolate_property(position2D, "scale", scale_jumping,scale_normal, animation_time,Tween.TRANS_CUBIC,Tween.EASE_OUT, delay)
		tween.start()

func set_current_animation():
	current_animation = position2D.scale

func smashed():
	STATE = SMASHED
	tween.remove_all()
	gasTimer.stop()
	tween.interpolate_property(position2D, "scale", scale_normal, scale_smashed, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	collisionN.call_deferred("set", "disabled" , true)
	collisionS.call_deferred("set", "disabled" , false)
	splash_particles(global_position)

func splash_particles(position):
	var splash = Splash.instance()
	get_tree().get_root().add_child(splash)
	splash.global_position = position

func normal():
	collisionN.call_deferred("set", "disabled" , false)
	collisionS.call_deferred("set", "disabled" , true)

func spike(area):
	STATE = NORMAL
	normal()
	tween.remove_all()
	tween.interpolate_property(position2D, "scale", scale_normal, scale_normal, 0.1,Tween.TRANS_BACK,Tween.EASE_OUT)
	tween.start()
	var corpse = Corpse.instance()
	get_tree().get_root().add_child(corpse)
	corpse.global_position = area.global_position
	splash_particles(area.global_position)
	restart()

func fire():
	STATE = GAS
	smoke.emitting = true
	$AudioGas.play()
	gasTimer.start()
	normal()
	tween.interpolate_property(position2D, "scale", scale_normal, scale_normal, 0.1,Tween.TRANS_BACK,Tween.EASE_OUT)
	tween.start()

func _on_HurtBox_area_entered(area):
	if area.is_in_group("smasher"):
		if STATE == NORMAL:
			smashed()
	if area.is_in_group("spike"):
		spike(area)
	if area.is_in_group("fire"):
		fire()
	if area.is_in_group("checkpoint"):
		spawner.global_position = area.global_position

func restart():
	global_position = spawner.global_position

func _on_CotoyeTimer_timeout():
	can_jump = false

func _on_GasTimer_timeout():
	STATE = NORMAL
	tween.interpolate_property(position2D, "scale", scale_normal, scale_normal, 0.1,Tween.TRANS_BACK,Tween.EASE_OUT)
	tween.start()
	smoke.emitting = false


func _on_StepsTimer_timeout():
	$AudioSteps/StepsTimer.start()
	if velocity.x != 0.0 and velocity.y == 0:
		$AudioSteps.play()
