class_name CharacterBase
extends CharacterBody2D

enum States {IDLE, RUN, JUMP, FALL, ATTACK, DEFENSE, HIT, DEATH}
var CurrentState = States.IDLE

@export_category("Character Nodes")
@export_group("Player Nodes")
@export var Sprite: Sprite2D
@export var Anim: AnimationPlayer
@export var time_death: Timer
@export var hurt_box: Area2D


@export_category("Variables")
@export_group("Moviment Variables")
@export var speed: float
@export var jump_force: float

@export_category("Attack Nodes")
@export_group("Area Attack")
@export var collision: CollisionShape2D
@export var area_attack: Area2D

@export_category("Defese Nodes")
@export_group("Area Defence")
@export var area_defense: Area2D
@export var collision_defense: CollisionShape2D

@export_category("Health Variables")
@export_group("Health Damage")
@export var Health: int = 6
@export var dano: int = 1
@export var hurt_collision: CollisionShape2D



var direction: float = 0.0
var is_jumping: bool = false
var is_attack: bool = false
var is_defense: bool = false
var is_hit: bool = false
var is_dead: bool = false
var atual_state: bool = true


var animation: = ""

#func _process(delta: float) -> void:
	#pass
	
func _physics_process(_delta: float) -> void:
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, 15)
	#direction = Input.get_axis("ui_left", "ui_right")
	#is_jumping = Input.is_action_just_pressed("ui_select") and is_on_floor()
	#is_attack = Input.is_action_just_pressed("Attack")
	#is_defense = Input.is_action_pressed("defense")
	
		
	
func _aply_moviment():
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, 15)
	#if !is_defense:	
		#if direction:
			#velocity.x = direction * speed
		#else:
			#velocity.x = move_toward(velocity.x, 0, 15)
	
func _aply_jump():
	if atual_state:
		atual_state = false
		velocity.y = jump_force	
	
func _stop_moviment():
	velocity.x = move_toward(velocity.x, 0, 2.5)
	
func _aply_gravity(delta):
	velocity += get_gravity() * delta
	
func _flip():
	if direction > 0:
		Sprite.flip_h = false
		area_attack.position.x = 19 
		area_defense.position.x = 0
	elif direction < 0:
		Sprite.flip_h = true
		area_attack.position.x = -19
		area_defense.position.x = -1
		
	
func _set_animations(anim:String):
	if animation != anim:
		animation = anim
		Anim.play(animation)
		
func _enter_state(new_state):
	if CurrentState != new_state:
		CurrentState = new_state
		atual_state = true
		
func _set_death():
	if Health <= 0:
		is_dead = true
		
func set_area_attack():
	collision.set_deferred("disabled", false)
func set_disabled_attack():
	collision.set_deferred("disabled", true)
	
func set_area_defence():
	collision_defense.set_deferred("disabled", false)
	
func set_defence_disabled():
	collision_defense.set_deferred("disabled", true)
		
