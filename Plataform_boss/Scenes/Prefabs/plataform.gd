extends AnimatableBody2D

var speed: float = 300
#var dir: int = -1
var motion: Vector2 = Vector2.ZERO
var inicial_pos: float = 8110.0
var final_pos: float = 6334.0
var on_plataform: bool = false

enum move_pos {LEFT, RIGHT}
var dir = move_pos.LEFT
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#var tween_effect = get_tree().create_tween().set_loops().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	#tween_effect.tween_property(self, "position:x", 6334, 10)
	#tween_effect.tween_interval(2)
	#tween_effect.tween_property(self, "position:x", 8110, 10)
	
func _physics_process(delta: float) -> void:
	
	match dir:
		move_pos.LEFT:
			position.x = move_toward(position.x, final_pos, 2)
			if position.x == final_pos:
				await get_tree().create_timer(1).timeout
				dir = move_pos.RIGHT
		move_pos.RIGHT:
			position.x = move_toward(position.x, inicial_pos, 2)
			if position.x == inicial_pos:
				#await get_tree().create_timer(1).timeout
				dir = move_pos.LEFT
				
