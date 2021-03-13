extends Position2D

var player 

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree().create_timer(0.1),"timeout")
	player = get_tree().get_root().find_node("Player", true, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("restart"):
		if player != null:
			player.global_position = global_position
		else:
			queue_free()
