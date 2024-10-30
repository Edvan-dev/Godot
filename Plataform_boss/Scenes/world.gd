extends Node2D

@export_category("Dialogs Nodes")
@export_group("Nodes")
@export var TextBox: RichTextLabel
@export var CollorBox: ColorRect
@export var dialog_control: Control
@export var player: CharacterBody2D
@export var camera: Camera2D
@export var dialog_area: CollisionShape2D

@export_category("Level References")
@export_group("Nodes")
@export var player_position: Marker2D
@export var attack_points: Array [Marker2D] = []


var speed: float = 50.0
var speed_zero: Vector2 = Vector2.ZERO
var player_pos: Vector2 = Vector2.ZERO

var tween: Tween
@export_category("Diálogos")
@export_group("Texts")
@export var texts: Array [String] = []

var change: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func change_text():
	TextBox.text = texts[1]	
	
func dialog():
	TextBox.text = texts[0]
	tween = get_tree().create_tween()
	tween.tween_property(CollorBox,"scale", Vector2.ONE,0.8).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_interval(0.8)
	tween.tween_property(TextBox,"visible_ratio", 1, 2)
	tween.tween_interval(2)
	tween.tween_property(TextBox,"visible_ratio", 0, 0.5)
	tween.tween_callback(change_text)
	tween.tween_property(TextBox,"visible_ratio", 1, 3)
	tween.tween_interval(0.6)
	tween.tween_property(TextBox,"visible_ratio", 0, 0.5)
	tween.tween_property(CollorBox,"scale", Vector2.ZERO,1).set_trans(Tween.TRANS_ELASTIC)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if player != null:
		player_position.global_position = player.global_position
		camera.look_at(player.global_position)
		#player_pos = player.global_position
		#camera.offset = player_pos
	else:
		#camera.look_at(player.global_position)
		camera.offset = Vector2(player_position.global_position.x, 0)


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.Respawn()


func _on_dialog_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#dialog_area.set_deferred("disabled", true)
		dialog()


func _on_dialog_area_body_exited(body: Node2D) -> void:
	pass
	#if body.is_in_group("Player"):
		#await get_tree().create_timer(3).timeout
		#dialog_area.set_deferred("disabled", false)
