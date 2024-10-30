extends Area2D

@export var player: CharacterBody2D
var dano: int = 1

func take_damage(knowback):
	player.is_hit = true
	var tween: = get_tree().create_tween()
	tween.tween_property(player, "global_position:x", global_position.x + knowback, 0.15 )
	player.Health -= dano
	player._set_death()
