extends Node

@export var player: CharacterBody2D
@export var enemy_scene: PackedScene

func _ready():
	player.begin_spawning_enemies()
	
	player.die.connect(die)
	player.spawn.connect(spawn)

func die():
	get_tree().quit()

func spawn(position: Vector2):
	var enemy := enemy_scene.instantiate()
	enemy.target = player
	enemy.position = position
	
	get_parent().add_child(enemy)
