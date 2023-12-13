extends CharacterBody2D

signal die
signal spawn

var health = 100
var enemies_colliding_with: Array[Node2D] = []
var flash_times = 0
var max_flash_times = 4

const SPEED = 100.0

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	var x_direction = Input.get_axis("move_left", "move_right")
	if x_direction:
		velocity.x = x_direction * SPEED
		
		# Flip sprite if facing left
		$AnimatedSprite2D.flip_h = x_direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var y_direction = Input.get_axis("move_up", "move_down")
	if y_direction:
		velocity.y = y_direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	var is_moving = x_direction or y_direction
	
	# Play walk animation if moving
	if is_moving:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.stop()

	if len(enemies_colliding_with) > 0:
		damage(enemies_colliding_with[0].enemy_resource.damage)
	
	if health <= 0:
		die.emit()

	move_and_slide()
	
	$EnemySpawnPath.position = position
	print($EnemySpawnPath/PathFollow2D.position)

func damage(dmg: int):
	if not $DamageCooldown.is_stopped():
		return
	
	health -= dmg
	$DamageCooldown.start()
	$FlashCooldown.start()
	print(health)

func begin_spawning_enemies():
	$EnemySpawnCooldown.start()

func stop_spawning_enemies():
	$EnemySpawnCooldown.stop()

func spawn_enemy():
	$EnemySpawnPath/PathFollow2D.progress_ratio = randf()
	
	spawn.emit($EnemySpawnPath/PathFollow2D.position)

func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	var body = area.get_parent()
	
	if body.is_in_group("enemies"):
		enemies_colliding_with.append(body)


func _on_area_2d_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	var body = area.get_parent()
	
	if body in enemies_colliding_with:
		enemies_colliding_with.erase(body)


func _on_flash_cooldown_timeout():
	$AnimatedSprite2D.modulate = Color.BLACK if flash_times % 2 == 0 else Color.WHITE
	flash_times += 1

	if flash_times > max_flash_times * 2:
		$AnimatedSprite2D.modulate = Color.WHITE
		
		flash_times = 0
		$FlashCooldown.stop()
