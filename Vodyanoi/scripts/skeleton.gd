extends CharacterBody2D

const speed = 30
var dir: Vector2
var is_skeleton_chase: bool
var prev_direction := Vector2(1, 0)
var player: CharacterBody2D
var current_attack: bool
@onready var player_knight: CharacterBody2D = $"../Player_Knight"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_cone: Area2D = $DamageCone

var health = 50
var health_max = 50

func _ready():
	is_skeleton_chase = true
	sprite.animation_finished.connect(on_animation_finished)

	
func _process(delta):
	move(delta)
	handle_animation()

func move(delta):
	if is_skeleton_chase:
		player = player_knight
		velocity = position.direction_to(player.position) * speed
	else:
		velocity = dir * speed 
	
	# Update prev_direction only if moving
	if velocity.length() > 0:
		prev_direction = velocity.normalized()

	move_and_slide()

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([1.0, 1.5, 2.0])
	if !is_skeleton_chase:
		dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])

func handle_animation():
	if current_attack:
		return  # Do not change the animation if attacking
	if velocity.length() > 0:
		default_walk_animate(prev_direction)

func choose(array):
	array.shuffle()
	return array.front()  

func default_walk_animate(direction: Vector2):
	var angle = direction.angle()
	sprite.play(get_animation_name(angle, "defwalk_"))

func idle_animate(direction: Vector2):
	var angle = direction.angle()
	sprite.play(get_animation_name(angle, "idle_"))

func attack_animate(direction:Vector2):
	var angle = direction.angle()
	damage_cone.rotation = angle
	sprite.play(get_animation_name(angle, "attack_"))
	toggle_damage_collisions()
	
func death_animate(direction: Vector2):
	var angle = direction.angle()
	sprite.play(get_animation_name(angle, "death_"))
	
func on_animation_finished():
	# Need to reset attack state
	if sprite.animation.begins_with("attack_"):
		current_attack = false


func 	toggle_damage_collisions(): 
	current_attack = true
	var damage_zone_collision = damage_cone.get_node("DamageArea")
	var wait_time = 0.8
	damage_zone_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_zone_collision.disabled = true
	
	
func get_animation_name(angle: float, prefix: String) -> String:
	var deg = rad_to_deg(angle)
	if deg < 0:
		deg += 360  # Normalize

	if deg >= 15 and deg < 45:
		return prefix + "see"  
	elif deg >= 45 and deg < 75:
		return prefix + "sse"
	elif deg >= 75 and deg < 105:
		return prefix + "s"
	elif deg >= 105 and deg < 135:
		return prefix + "sww"
	elif deg >= 135 and deg < 165:
		return prefix + "sw"
	elif deg >= 165 and deg < 195:
		return prefix + "w"
	elif deg >= 195 and deg < 225:
		return prefix + "nw"
	elif deg >= 225 and deg < 255:
		return prefix + "nnw" 
	elif deg >= 255 and deg < 275:
		return prefix + "n"
	elif deg >= 275 and deg < 295:
		return prefix + "nne"
	elif deg >= 295 and deg < 315:
		return prefix + "ne"
	elif deg >= 315 and deg < 345:
		return prefix + "nee"
	else:
		return prefix + "e"  


func _on_battlebox_area_entered(area: Area2D):
	if area == GameVariables.playerDamageZone:
		attack_animate(prev_direction)
		var damage = GameVariables.playerDamageAmount
		take_damage(25)
		current_attack = true  # Prevent other animations from overriding attack
		
func take_damage(damage):
	health-=damage
	if health <= 0:
		queue_free()
	
