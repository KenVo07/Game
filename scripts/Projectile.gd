extends Area2D

# Projectile - Basic projectile for player attacks

export var speed = 400.0
export var damage = 10
export var lifetime = 5.0
export var pierce = false

var direction = Vector2.RIGHT
var traveled_distance = 0.0
var max_distance = 1000.0

onready var sprite = $Sprite
onready var lifetime_timer = $LifetimeTimer

func _ready():
	add_to_group("projectiles")
	
	connect("body_entered", self, "_on_body_entered")
	
	if lifetime_timer:
		lifetime_timer.wait_time = lifetime
		lifetime_timer.one_shot = true
		lifetime_timer.connect("timeout", self, "_on_lifetime_timeout")
		lifetime_timer.start()

func _physics_process(delta):
	var movement = direction * speed * delta
	position += movement
	traveled_distance += movement.length()
	
	if traveled_distance >= max_distance:
		queue_free()
	
	# Rotate to face direction
	rotation = direction.angle()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage, get_parent())
		
		if not pierce:
			queue_free()

func _on_lifetime_timeout():
	queue_free()

func set_properties(dir: Vector2, dmg: int, spd: float = 400.0):
	direction = dir.normalized()
	damage = dmg
	speed = spd
