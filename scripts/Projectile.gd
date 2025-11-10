extends Area2D

# ==========================================
# PROJECTILE
# ==========================================
# Player's qi projectile

var direction = Vector2.RIGHT
var speed = 400.0
var damage = 10
var lifetime = 3.0

func _ready():
	# Auto-destroy after lifetime
	yield(get_tree().create_timer(lifetime), "timeout")
	queue_free()
	
	# Connect collision signal
	connect("body_entered", self, "_on_body_entered")

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	"""Handle collision with enemies or obstacles"""
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Destroy projectile on impact
	queue_free()
