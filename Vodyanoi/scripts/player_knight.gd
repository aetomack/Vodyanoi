extends CharacterBody2D

var SPEED = 50
var prev_direction := Vector2(1, 0)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_cone: Area2D = $DamageCone
var current_attack: bool
var health = 100
var health_max = 100
var taking_damage = false


func _ready():
	current_attack = false
	sprite.animation_finished.connect(on_animation_finished)

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	GameVariables.playerDamageZone = damage_cone
	
	if(!current_attack):
		velocity = direction * SPEED
		move_and_slide()
	
		if direction.length() > 0:
			prev_direction = direction.normalized()  # Normalize direction
			default_walk_animate(prev_direction)
		else:
			idle_animate(prev_direction)
			
		if Input.is_action_just_pressed("Attack"):
			current_attack = true
			attack_animate(prev_direction)

func toggle_damage_collisions():
	var damage_zone_collision = damage_cone.get_node("DamageArea")
	var wait_time = 0.8
	damage_zone_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_zone_collision.disabled = true

func default_walk_animate(direction: Vector2):
	if (current_attack):
		return; # to prevent default
	var angle = direction.angle()
	sprite.play(get_animation_name(angle, "walk_"))
	
func idle_animate(direction: Vector2):
	if (current_attack):
		return; #to prevent idle from overwriting 
	var angle = direction.angle()
	sprite.play(get_animation_name(angle, "idle_"))

func attack_animate(direction:Vector2):
	var angle = direction.angle()
	damage_cone.rotation = angle
	sprite.play(get_animation_name(angle, "attack_"))
	toggle_damage_collisions()
	
func death(direction: Vector2):
	return
	
func on_animation_finished():
	# Need to reset attack state
	if sprite.animation.begins_with("attack_"):
		current_attack = false

func get_animation_name(angle: float, prefix: String) -> String:
	# Convert angle to degrees
	var deg = rad_to_deg(angle)
	
	# Normalize the angle for consistency
	if deg < 0:
		deg += 360
	
# Define precise direction ranges
	if deg >= 15 and deg < 45:
		return prefix + "see"  # South-East-East
	elif deg >= 45 and deg < 75:
		return prefix + "sse"  # South-South-East
	elif deg >= 75 and deg < 105:
		return prefix + "s"  # South
	elif deg >= 105 and deg < 135:
		return prefix + "sww"  # South-West-West
	elif deg >= 135 and deg < 165:
		return prefix + "sw"  # South-West
	elif deg >= 165 and deg < 195:
		return prefix + "w"  # West
	elif deg >= 195 and deg < 225:
		return prefix + "nw"  # North-West
	elif deg >= 225 and deg < 255:
		return prefix + "nnw"  # North-North-West
	elif deg >= 255 and deg < 275:
		return prefix + "n"  # North
	elif deg >= 275 and deg < 295:
		return prefix + "nne"  # North-North-East
	elif deg >= 295 and deg < 315:
		return prefix + "ne"  # North-East
	elif deg >= 315 and deg < 345:
		return prefix + "nee"  # North-East-East
	else:
		return prefix + "e"  # Default to East
