extends CharacterBody2D

@export var enemy_resource: Enemy
@export var target: CharacterBody2D

func _ready():
	$AnimatedSprite2D.play("walk")

func _physics_process(delta):
	# Move towards target
	if target:
		velocity = (target.position - position).normalized() * enemy_resource.speed
	else:
		velocity.x = move_toward(velocity.x, 0, enemy_resource.speed)
		velocity.y = move_toward(velocity.y, 0, enemy_resource.speed)

	$AnimatedSprite2D.flip_h = velocity.x < 0

	move_and_slide()
