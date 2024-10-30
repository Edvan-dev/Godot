extends CharacterBody2D

@onready var pos_shot: Marker2D = $pos_shot
const SPEED = 80.0
const JUMP_VELOCITY = -400.0
var direction: float = 0.0
var player_dis
var player
var count_shoht = 0
var fall_attack: bool = false
var can_shot: bool = true
var rand_pos: bool = true
var indice: int = 0
#@export var timer: Timer
@onready var time_attack: Timer = $Time_attack as Timer

@export_category("Attack Variables")
@export_group("Nodes")
@export var Projetil: PackedScene
@export var laser: AnimatedSprite2D
@export var anim: AnimationPlayer
@export var sprite: Sprite2D
@export var Melee_attack: Area2D
@export var Melee_collision: CollisionShape2D
@export var area_laser: CollisionShape2D

@export_category("Fall Attack Positions")
@export_group("Nodes")
@export var attack_points: Array [Marker2D] = []

@export_category("Wave Move Variables")
@export_group("Nodes")
@export var frequency: float = 5.0
@export var amplitude: float = 100.0
@export var time: float = 0.0


var knowback_force: float = 40.0
var knowback_dir: int = 0

enum States {ACTIVE, IDLE, MOVE, LASER, SHOT,LEVITATION, MELEE, GRAVITY_ATTACK, FALL, STOP}
#var CurrentState = States.ACTIVE
var CurrentState = null

func _ready() -> void:
	pass
	#time_attack.start()
func _process(_delta: float) -> void:
	player = get_tree().get_first_node_in_group("Player")
	if player != null:
		player_dis = int(global_position.distance_to(player.global_position))
		direction = -1 if global_position.x > player.global_position.x  else 1
	if player_dis <= 50 and CurrentState == null:
		CurrentState = States.ACTIVE
	#print(CurrentState)
	#Set_States()

func _physics_process(delta: float) -> void:
	AplyState(delta)
	Flip()
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
		
		
func AplyState(delta):
	match CurrentState:
		States.ACTIVE:
			Activate()
		States.IDLE:
			Idle()
		States.MOVE:
			Move()
		States.LASER:
			Laser()
		States.SHOT:
			Shoting()
		States.MELEE:
			Melee()
		States.LEVITATION:
			Levitation(delta)
		States.GRAVITY_ATTACK:
			_rock_attack(delta)
		States.FALL:
			falling(delta)
		States.STOP:
			Stoped()
			
			
			
#FUNÇÔES DE SETADO=================================================
func Activate():
	#anim.play_backwards("Rock_attack") # animação ao contrario
	anim.play("Rock_attack")
	await anim.animation_finished
	time_attack.start()
	CurrentState = States.IDLE
	
func Idle():
	anim.play("Idle")
	await time_attack.timeout
	randomize()
	CurrentState = randi_range(2,5)
	#CurrentState = States.LEVITATION
	#CurrentState = States.SHOT
	#if direction:
		#CurrentState = States.MOVE
	
func Move():
	anim.play("Blink")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if player_dis <= 40:
		Clear_shot()
		CurrentState = States.MELEE
	else:
		CurrentState = States.SHOT
		#randomize()
		#CurrentState = randi_range(4,5) 
	
func Stoped():
	rand_pos = true
	velocity = Vector2.ZERO
	if velocity.x == 0:
		CurrentState = States.GRAVITY_ATTACK
	
func Laser():
	
	anim.play("Laser_attack")
	await get_tree().create_timer(0.7).timeout
	area_laser.set_deferred("disabled", false)
	await laser.animation_finished
	area_laser.set_deferred("disabled", true)
	time_attack.start()
	#CurrentState = States.MOVE
	CurrentState = States.IDLE
	#if anim.animation_finished:
		#CurrentState = States.MOVE
	
func Melee():
	anim.play("Melee_attack")
	if player_dis > 40 and player_dis < 45:
		CurrentState = States.LASER

func Levitation(delta):
	if rand_pos:
		rand_pos = false
		randomize()
		indice = randi_range(0,2)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", 60.0, 0.8)
	tween.tween_interval(1.5)
	tween.tween_callback(move_air)
	
func move_air():
	position.x = move_toward(position.x, attack_points[indice].global_position.x, 1.5)
	
	if position.x <= attack_points[indice].global_position.x:
		CurrentState = States.STOP
		
func _rock_attack(delta):
	if !fall_attack:
		fall_attack = true
		anim.play_backwards("Rock_attack")
		await anim.animation_finished
		anim.stop()
	CurrentState = States.FALL
	
		
func falling(delta):
	fall_attack = false
	velocity += get_gravity() * delta		
	move_and_slide()
	if is_on_floor():
		CurrentState = States.ACTIVE
func Shoting():
	if can_shot:
		can_shot = false
		anim.play("Shot_attack")
		await get_tree().create_timer(2).timeout
		can_shot = true
	if count_shoht >= 3:
		CurrentState = States.MOVE
	#if player_dis < 150 and player_dis > 75:
		#CurrentState = States.MOVE
		
	
		
		
#FUNÇÕES AUXILIARES==================================================	

func damage(knowback):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", position.x + knowback, 0.15 )

func Clear_shot():
	count_shoht = 0
func Shot():
	count_shoht += 1
	print(count_shoht)
	var main = get_tree().current_scene
	var shot = Projetil.instantiate()
	main.call_deferred("add_child", shot)
	shot.global_position = pos_shot.global_position
	
	if direction > 0:
		shot.set_direction(direction)
	elif direction < 0:
		shot.set_direction(direction)
	
func Flip():
	sprite.flip_h = true if direction < 0 else false
	laser.flip_h = true if direction < 0 else false
	laser.position.x =-185 if direction < 0 else 185
	pos_shot.position.x = -32 if direction < 0 else 32
	Melee_attack.position.x =-29 if direction < 0 else 29
	
func _aply_attack():
	Melee_collision.set_deferred("disabled", false)
	await get_tree().create_timer(0.5).timeout
	Melee_collision.set_deferred("disabled", true)
	
	
func laser_shot() -> void:
	laser.play("default")
	#if laser.animation_finished:
func wave_move(delta):
	time += frequency * delta
	var wave = cos(time) * amplitude
	velocity.y += wave * delta		

		
func Set_States():
	Flip()
	
	#if count_shoht >= 3:
		#CurrentState = States.MOVE
		
	

func _on_area_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		knowback_dir = 1 if (area.global_position.x - global_position.x) >0 else -1
		knowback_force *= knowback_dir
		area.take_damage(knowback_force)
