extends Node2D

var current_wave: int = 0
@export var skeleton_scene: PackedScene

var starting_nodes: int
var current_nodes: int
var wave_spawn_ended: bool = false

@onready var spawn_points = $SpawnPoints.get_children()  # Assuming all spawn points are inside a Node2D named "SpawnPoints"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameVariables.current_wave = current_wave
	starting_nodes = get_child_count()
	current_nodes = get_child_count()
	position_to_next_wave()

func position_to_next_wave():
	if current_nodes == starting_nodes:
		if current_wave != 0:
			GameVariables.moving_to_next_wave = true
		current_wave += 1
		GameVariables.current_wave = current_wave
		prepare_spawn("skeletons", 4, 4)

func prepare_spawn(type: String, multiplier: int, mob_spawns: int):
	var mob_amount = current_wave * multiplier
	var mob_wait_time: float = 2.0
	var mob_spawn_rounds: int = mob_amount / mob_spawns
	print(mob_spawn_rounds)
	await spawn_type(type, mob_spawn_rounds, mob_wait_time)

func spawn_type(type: String, mob_spawn_rounds: int, mob_wait_time: float):
	if type == "skeletons":
		wave_spawn_ended = false
		for _i in range(mob_spawn_rounds):
			for spawn_point in spawn_points:
				var skeleton = skeleton_scene.instantiate()
				skeleton.global_position = spawn_point.global_position
				add_child(skeleton)
			await get_tree().create_timer(mob_wait_time).timeout
		wave_spawn_ended = true
