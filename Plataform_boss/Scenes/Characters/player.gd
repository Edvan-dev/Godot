extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const AIR_FRICTION = 0.5
@export var AnimP: AnimationPlayer
enum States {IDLE,WALK,JUMP,FALL,ATTACK}
var State = null
var direction: float = 0.0
var can_jump: bool = true
var can_attack: bool = true
var respawn_pos: = Vector2(16, 0)
@onready var AttackColl: CollisionShape2D = $Area_attack/Collision
@onready var sprite_2d: Sprite2D = $Sprite2D
var in_air: bool = false

signal jumping

func _ready() -> void:
	connect('jumping',is_jumping)


func _process(delta: float) -> void:
	StatesTransitions()
	
	
func _physics_process(delta: float) -> void:
	Statesfunction()
	AplyGravity(delta)
	move_and_slide()
	
func AplyGravity(delta):
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		#velocity.x = 0.0
		
func Respawn():
	global_position = respawn_pos
	
func AplyAttack():
	AttackColl.set_deferred("disabled", false)

func stop_attack():
	AttackColl.set_deferred("disabled", true)

func Flip(dir:float) -> void:

	if dir > 0.0:
		sprite_2d.flip_h = false
		AttackColl.position.x = 19
	elif dir < 0.0:
		sprite_2d.flip_h = true
		AttackColl.position.x = -19
		
func StatesTransitions() -> void:
	
	direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0.0 and is_on_floor():
		#Anim.flip_h = false if direction > 0 else  true
		Flip(direction)
		State = States.WALK
		
	elif direction == 0.0 and is_on_floor() and !in_air:
		in_air = false# and State != States.ATTACK and State != States.JUMP :
		State = States.IDLE
		
	if Input.is_action_just_pressed("Jumper") and can_jump and is_on_floor():
		in_air = true
		emit_signal("jumping")
		#AnimP.play("Jump")
		#can_jump = false
		#can_jump = true    
		#velocity.y = JUMP_VELOCITY 
		#State = States.JUMP
		 
	if Input.is_action_just_pressed("Attack") and can_attack and State != States.WALK:
		State = States.ATTACK
		
	CheckStates()	
	
	#if is_on_floor():# and State != States.IDLE: 
		#can_jump = true
		#print("PODE PULAR:",can_jump)
		
	#if velocity.y > 0 and State != States.ATTACK:
		#State = States.FALL
		
func CheckStates() -> void:
	if is_on_floor() and States.ATTACK:
		await AnimP.animation_finished
		AttackColl.set_deferred("disabled", true)
		State = States.IDLE
	#if !is_on_floor() and States.ATTACK:
		#await AnimP.animation_finished
		#AttackColl.set_deferred("disabled", true)
		#State = States.FALL
	#if is_on_floor() and !State.Idle: 
		#can_jump = true	
		#print("PODE PULAR:",can_jump)
 		
func Statesfunction() -> void:
	match State:
		
		States.IDLE:
			AnimP.play("Idle")
			AttackColl.set_deferred("disabled", true)
			velocity.x = move_toward(velocity.x, 0, SPEED)
			 
		States.WALK:
			#velocity.x = 0.0
			if is_on_floor():
				AnimP.play("Run")
			velocity.x = lerp(velocity.x,direction * SPEED, AIR_FRICTION)
			
		States.ATTACK:
			AnimP.play("Jump")
			can_attack = false
			can_attack = true
				
		States.JUMP:
			AnimP.play("Jump")
			can_jump = false
			can_jump = true
			velocity.y = JUMP_VELOCITY 
			#await AnimP.animation_finished
			#State = States.FALL
			#AnimP.play("Jump")
			#velocity.y = JUMP_VELOCITY
			##can_jump = false
			#can_jump = false
			
			#velocity.y = JUMP_VELOCITY
			#if can_jump:
				#AnimP.play("Jump")
				#velocity.y = JUMP_VELOCITY 
				#await AnimP.animation_finished
				#State = States.FALL
				#can_jump = false
			
			
		States.FALL:
			AnimP.play("Fall")
func is_jumping():
	AnimP.play("Jump")
	velocity.y = JUMP_VELOCITY
