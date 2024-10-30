extends CharacterBase

var knowback_dir: int = 0
var knowback_force: int = 30
@onready var plataforma: AnimatableBody2D = $"../Plataform"

var respawn_pos: Vector2 = Vector2(16,0)

func _process(delta: float) -> void:
	_aply_states(delta)
	_set_inputs()
	
func _aply_states(delta):
	move_and_slide()
	match CurrentState:
		States.IDLE:
			_set_idle(delta)
		States.RUN:
			_set_run(delta)
		States.JUMP:
			_set_jump(delta)
		States.FALL:
			_set_fall(delta)
		States.ATTACK:
			_set_attack()
		States.DEFENSE:
			_set_defense()
		States.HIT:
			_set_hit()
		States.DEATH:
			_set_dead()	
			
			
func _set_inputs():
	if CurrentState != States.ATTACK and CurrentState != States.DEFENSE:
		direction = Input.get_axis("ui_left", "ui_right")
	is_jumping = Input.is_action_just_pressed("ui_select") and is_on_floor()
	is_attack = Input.is_action_just_pressed("Attack")
	is_defense = Input.is_action_pressed("defense")
			
			
func _set_idle(delta):
	_set_animations("Idle")
	_aply_gravity(delta)
	if direction:
		_enter_state(States.RUN)
	if is_jumping:
		_enter_state(States.JUMP)
	if is_attack:
		_enter_state(States.ATTACK)
	if is_defense:
		_enter_state(States.DEFENSE)
	if is_hit:
		_enter_state(States.HIT)
	if is_dead:
		_enter_state(States.DEATH)	
	
func _set_run(delta):
	_set_animations("Run")
	_aply_gravity(delta)
	#_aply_moviment()
	_flip()
	if !direction:
		_enter_state(States.IDLE)
	if is_jumping:
		_enter_state(States.JUMP)
	if not is_on_floor():
		_enter_state(States.FALL)
	if is_hit:
		_enter_state(States.HIT)
	if is_dead:
		_enter_state(States.DEATH)	
	
func _set_jump(delta):
	_flip()
	_set_animations("Jump")
	_aply_gravity(delta)
	_aply_jump()
	if velocity.y > 0:
		_enter_state(States.FALL)
	
func _set_fall(delta):
	_set_animations("Fall")
	_aply_gravity(delta)
	if is_on_floor():
		_enter_state(States.IDLE)
	
func _set_attack():
	_set_animations("Attack")
	if is_on_floor():
		await Anim.animation_finished
		_enter_state(States.IDLE)
		
func _set_defense():
	set_area_defence()
	hurt_collision.set_deferred("disabled", true)
	_set_animations("Defense")
	if is_on_floor() and !is_defense:
		hurt_collision.set_deferred("disabled", false)
		set_defence_disabled()
		_enter_state(States.IDLE)

func _set_hit():
	_set_animations("Hit")
	if is_on_floor():
		await Anim.animation_finished
		_enter_state(States.IDLE)
		is_hit = false

func _set_dead():
	hurt_collision.set_deferred("disabled", true)
	_set_animations("Death")
	await Anim.animation_finished
	time_death.start()
	await time_death.timeout
	call_deferred("queue_free")

func _on_area_attack_entered(area: Area2D) -> void:
	
	if area.is_in_group("Enemy"):
		knowback_dir = 1 if (area.global_position.x - global_position.x) > 0 else -1
		knowback_force *= knowback_dir
		area.damage(knowback_force)


func _on_area_defense_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		knowback_dir = 1 if (area.global_position.x - global_position.x) > 0 else -1
		knowback_force *= knowback_dir
		area.knowback(knowback_force)


func _on_area_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		knowback_dir = 1 if (body.global_position.x - global_position.x) > 0 else -1
		knowback_force *= knowback_dir
		body.damage(knowback_force)

func Respawn():
	global_position = respawn_pos


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("plataformas"):
		self.reparent(plataforma)
 
