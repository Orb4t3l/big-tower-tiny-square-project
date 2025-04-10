extends CharacterBody2D

@export var speed: float = 10.0  # Movement speed
@export var distance: float = 50.0  # Distance to move back and forth

var direction: int = 1  # 1 for right, -1 for left
var start_position: Vector2

func _ready():
	start_position = global_position

func _physics_process(delta):
	# Move in the current direction
	velocity.x = direction * speed
	move_and_slide()
	
	# Check if the character has moved the set distance
	if abs(global_position.x - start_position.x) >= distance:
		direction *= -1  # Reverse direction
