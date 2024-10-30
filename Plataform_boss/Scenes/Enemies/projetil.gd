extends Area2D
@export var Sprite: Sprite2D
@export_category("Speed")
@export var speed: float = 120.0
var direction: int = 1

var knowback_force: float = 40.0
var knowback_dir: int = 0

func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta
	#Sprite.flip_h = true if direction < 0 else false
	scale.x = -1 if direction < 0 else 1
	
func set_direction(dir):
	direction = dir	


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		call_deferred("queue_free")
		knowback_dir = 1 if (area.global_position.x - global_position.x) >0 else -1
		knowback_force *= knowback_dir
		area.take_damage(knowback_force)
