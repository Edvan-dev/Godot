extends CharacterBody2D
@onready var sprite_2d: Sprite2D = $Sprite2D
const SPEED = 150.0
const JUMP_VELOCITY = -300.0
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var AttackColl: CollisionShape2D = $Area_attack/Collision
var animation_state
var direction: Vector2 = Vector2.ZERO
var value: bool
var is_atack: bool
var jumping: bool = false
var is_fall: bool = false
var respawn_pos: Vector2 = Vector2(16,0)
@onready var anim_p: AnimationPlayer = $AnimP

@export_category("Jump Variables")
@export var JumpHigth: float
@export var JumpSpeed: float
@export var Gravity: float
@export var TimeToPick: float
@export var FallGravity: float

func _ready() -> void:
	animation_state = animation_tree.get("parameters/playback")
	JumpSpeed = -(JumpHigth * 2) / TimeToPick
	Gravity = (JumpHigth * 2) / pow(TimeToPick, 2)
	FallGravity = Gravity * 2

func _physics_process(delta: float) -> void:
	var is_flor = animation_tree.get("parameters/jump/conditions/is_on_flor")
	#print("ESTÁ NO CHAO:", is_flor)
	#print("ESTÁ PULANDO!!:", jumping)
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	#direction.y = velocity.y
	
	#animation_tree.set("parameters/jump/conditions/is_on_flor", is_on_floor())
	#if is_on_floor():
		#jumping = false
	animation_tree.set("parameters/jump/conditions/is_on_flor", is_on_floor())
	#else:
		#animation_tree.set("parameters/jump/conditions/is_on_flor", false)
			#
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#jumping = true
		animation_state.travel("jump")
		velocity.y = JumpSpeed
	if velocity.y > 0:
		is_fall = true
		velocity.y += FallGravity * delta	
	else:
		is_fall = false
		velocity.y += Gravity * delta	
		
	if Input.is_action_just_pressed("Attack"):
		animation_state.travel("attack")
	
	direction.x = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction.x * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	set_animations(is_fall)
	print(is_fall)
		
	Flip(direction.x)

	move_and_slide()
func set_animations(value: bool):
	animation_tree.set("parameters/motion/blend_position", direction)
	animation_tree.set("parameters/jump/conditions/is_fall", value)
	
func Flip(dir:float) -> void:

	if dir > 0.0:
		sprite_2d.flip_h = false
		AttackColl.position.x = 19
	elif dir < 0.0:
		sprite_2d.flip_h = true
		AttackColl.position.x = -19	
#func Flip():
	#if direction.x:
		#sprite_2d.flip_h = false if direction.x > 0 else true

func Respawn():
	global_position = respawn_pos

func JumpImpulse():
	velocity.y = JUMP_VELOCITY
		
func AplyAttack():
	AttackColl.set_deferred("disabled", false)

func stop_attack():
	AttackColl.set_deferred("disabled", true)
