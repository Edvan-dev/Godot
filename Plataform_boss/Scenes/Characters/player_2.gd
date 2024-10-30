extends CharacterBody2D

@onready var defense_delay: Timer = $defense_delay
@onready var collision: CollisionShape2D = $area_attack/Collision
@onready var area_attack: Area2D = $area_attack
@onready var damage_time: Timer = $Damage_time
@onready var hurt_box_collision: CollisionShape2D = $Hurt_box/Collision


const SPEED = 150.0
const JUMP_VELOCITY = -400.0
@export var sprite: Sprite2D
@export var Anim: AnimationPlayer
var Health: int = 5
var dano: int = 1
var is_death: bool = false
var direction: float = 0.0
var jumping: bool = false
var is_attacking: bool = false
var knowback_force: float = 40.0
var knowback_dir: int = 0
var is_hit:bool= false
var respawn_pos: Vector2 = Vector2(16,0)

enum States {IDLE, RUN, JUMP, FALL, FALLGROUND, ATTACK, DEFENSE}
var CurrentState = States.IDLE

func _physics_process(delta: float) -> void:
	print(Health)
	SetInputs()
	# Flipar o sprite
	Flip()
	# Aplicar gravidade
	AplyGravity(delta)
	move_and_slide()
	#Aplicar estado
	set_animations()
	#AplyState()
			
func AplyGravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
func Flip():
	if direction > 0:
		sprite.flip_h = false
		area_attack.position.x = 19 
	elif direction < 0:
		sprite.flip_h = true
		area_attack.position.x = -19 
		
		
func SetInputs():
	direction = Input.get_axis("ui_left", "ui_right")
	# Horizontal movement and gravity.
	if not is_attacking:
		velocity.x = direction * SPEED
	#velocity.y += base_gravity * delta

	# Jumping.
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("ui_select")
	if is_jumping:
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("Attack") and !direction:
		is_attacking = true
	#if is_attacking:
		#Anim.play("Attack")
	#if direction:
		#CurrentState = States.RUN
	#if !direction and is_on_floor():
		#CurrentState = States.IDLE
	#if Input.is_action_just_pressed("defense") and is_on_floor() and !direction:
		#defense_delay.start()
		#CurrentState = States.DEFENSE
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#jumping = true
		#CurrentState = States.JUMP
	#if velocity.y > 0:
		#CurrentState = States.FALL
	
func AplyState():
	
	
	match CurrentState:
		
		States.IDLE:
			set_idle()
			
		States.RUN:
			set_run()
			
		States.JUMP:
			set_jump()
			
		States.FALL:
			set_fall()
			
		States.FALLGROUND:
			pass
			
		States.ATTACK:
			set_attack()
			
		States.DEFENSE:
			set_defense()
	
func set_animations():
	if is_death:
		velocity = Vector2.ZERO
		Anim.play("Death")
		await Anim.animation_finished
		is_death = false
		self.call_deferred("queue_free")
	else:
		if is_hit:
			Anim.play("Hit")
			await Anim.animation_finished
			is_hit = false
		else:
			if is_attacking:
				Anim.play("Attack")
				await Anim.animation_finished
				is_attacking = false
			else:
				if not is_on_floor():
					if velocity.y < 0:
						Anim.play("Jump")
					else:
						Anim.play("Fall")
				elif direction != 0.0:
					Anim.play("Run") 
					
				else:
					Anim.play("Idle")
			
			
func set_idle():
	Anim.play("Idle")
	velocity.x = move_toward(velocity.x, 0, SPEED)
	
func set_run():
	if is_on_floor():
		Anim.play("Run")
	velocity.x = direction * SPEED
	
func set_jump():
	Anim.play("Jump")
	velocity.y = JUMP_VELOCITY
	jumping = false

func set_fall():
	Anim.play("Fall")
	
func set_fallground():
	pass
	
func set_attack():
	Anim.play("Attack")
	await Anim.animation_finished
	if is_on_floor():
		CurrentState = States.IDLE
		
func set_area_attack():
	collision.set_deferred("disabled", false)
func set_disabled_attack():
	collision.set_deferred("disabled", true)
	
	
func set_defense():
	Anim.play("Defense")
	await defense_delay.timeout
	Anim.play("Defense")
	CurrentState = States.IDLE
	
func Respawn():
	global_position = respawn_pos
	
func _on_area_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		knowback_dir = 1 if (area.global_position.x - global_position.x) >0 else -1
		knowback_force *= knowback_dir
		area.damage(knowback_force)

func take_damage(knowback):
	var tween: Tween = get_tree().create_tween() as Tween
	tween.tween_property(self, "position:x", position.x + knowback, 0.15 )
	
func death():
	if Health <= 0:
		is_death = true
		hurt_box_collision.set_deferred("disabled", true)
		
		
func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		Health -= dano
		is_hit = true
		hurt_box_collision.set_deferred("disabled", true)
		damage_time.start()
		await damage_time.timeout
		hurt_box_collision.set_deferred("disabled", false)
		death()
		
