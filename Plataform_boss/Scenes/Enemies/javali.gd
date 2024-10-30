extends Area2D

@export var anim: AnimatedSprite2D
@export var collision: CollisionShape2D
@export var delay_damage: Timer
var direction: Vector2 = Vector2.LEFT
var speed: float = 40.0
var speed_run: float = 80.0
var health: int = 6
var dano: int = 2
var player
var player_dis
var is_damaged: bool = false
enum States {IDLE, WALK, RUN, HIT}
var CurrentState = States.IDLE

var knowback_force: float = 40.0
var knowback_dir: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(health)
	player = get_tree().get_first_node_in_group("Player")
	if player != null:
		player_dis = int(global_position.distance_to(player.global_position))
	flip()
	set_states()
	aply_states(delta)
	
func flip():
	anim.flip_h = false if direction.x < 0 else true
	
func set_states():
	if global_position.x <= 2700:
		direction = Vector2.RIGHT
	elif global_position.x >= 3000:
		direction = Vector2.LEFT
	if player_dis <= 100:
		CurrentState = States.WALK
	if player_dis <= 50:
		CurrentState = States.RUN
	if is_damaged:
		CurrentState = States.HIT
	
func aply_states(delta):
	match CurrentState:
		States.IDLE:
			set_idle()
		States.WALK:
			set_walk(delta)
		States.RUN:
			set_run(delta)
		States.HIT:
			set_hit()
			
func set_idle():
	anim.play("Idle")
	
func set_walk(delta):
	anim.play("Walk")
	translate(direction * speed * delta)
	
func set_run(delta):
	anim.play("Run")
	translate(direction * speed_run * delta)
	
func set_hit():
	anim.play("Hit")
	await anim.animation_finished
	is_damaged = false
	CurrentState = States.IDLE
	
func damage(knowback):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", position.x + knowback, 0.15 )
	is_damaged = true
	collision.set_deferred("disabled", true)
	delay_damage.start()
	health -= dano
	await delay_damage.timeout
	collision.set_deferred("disabled", false)
	death()
	
func knowback(knowback):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:x", global_position.x + knowback, 0.15 )
	
func death():
	if health <= 0:
		call_deferred("queue_free")
	


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		knowback_dir = 1 if (area.global_position.x - global_position.x) >0 else -1
		knowback_force *= knowback_dir
		area.take_damage(knowback_force)
