# combat_participant.gd
class_name CombatParticipant
extends RefCounted

var display_name: String
var is_player: bool

var row: CharacterInstance.PartyRow
var active_statuses: Array[StatusInstance] = []
var turn_count: int = 0

var determination: int
var courage: int
var passion: int
var spirit: int
var adaptability: int
var max_ep: int
var max_sp: int
var current_ep: int
var current_sp: int

var gauge: float = 0.0
var source_character: CharacterInstance   # rempli si is_player
var source_enemy: EnemyData               # rempli si !is_player
var behavior: EnemyBehavior                # rempli si !is_player
var is_boss: bool                         # rempli si !is_player

var world_position: Vector2 = Vector2.ZERO

static func from_character(character: CharacterInstance) -> CombatParticipant:
	var p := CombatParticipant.new()
	p.display_name = character.character_name
	p.is_player = true
	p.row = character.row
	p.determination = character.determination
	p.courage = character.courage
	p.passion = character.passion
	p.spirit = character.spirit
	p.adaptability = character.adaptability
	p.max_ep = character.max_ep
	p.max_sp = character.max_sp
	p.current_ep = character.current_ep
	p.current_sp = character.current_sp
	p.source_character = character
	return p


static func from_enemy(member: EncounterMember) -> CombatParticipant:
	var enemy := member.enemy
	var p := CombatParticipant.new()
	p.display_name = enemy.enemy_name
	p.is_player = false
	p.row = member.row
	p.determination = enemy.determination
	p.courage = enemy.courage
	p.passion = enemy.passion
	p.spirit = enemy.spirit
	p.adaptability = enemy.adaptability
	p.max_ep = enemy.max_ep
	p.max_sp = enemy.max_sp
	p.current_ep = enemy.max_ep
	p.current_sp = enemy.max_sp
	p.source_enemy = enemy
	p.behavior = enemy.behavior
	p.is_boss = enemy.is_boss
	return p


func is_alive() -> bool:
	return current_ep > 0 and current_sp > 0

# Recuperer la valeur d'une stats en appliquant les divers status
func get_stat(stat_name: String) -> float:
	var base: float = get(stat_name)  # Object.get natif : lit le champ par son nom texte
	var flat := 0.0
	var percent := 0.0

	for instance in active_statuses:
		for modifier in instance.status.stat_modifiers:
			if modifier.stat_name == stat_name:
				flat += modifier.flat_amount * instance.stacks
				percent += modifier.percent_amount * instance.stacks

	return (base + flat) * (1.0 + percent)
	

# Appliquer un statuts ou augmente la durée d'un statut en cours
func apply_status(status: StatusEffect, duration_turns: int = -1) -> void:
	var actual_duration := duration_turns if duration_turns >= 0 else status.duration_turns
			
	# appliquer de nouveaux tours sur le status en cours
	for instance in active_statuses:
		if instance.status == status:
			instance.remaining_turns += status.duration_turns
			return

	var new_instance := StatusInstance.new(status)
	new_instance.remaining_turns = actual_duration
	active_statuses.append(new_instance)

# Applique les effets des statuts en cours (par type de trigger)
func trigger_statuses(trigger: StatusEffect.TriggerType, context: Dictionary) -> void:
	for instance in active_statuses.duplicate():
		if instance.status.trigger == trigger:
			for effect in instance.status.trigger_effects:
				effect.execute(context)


func tick_turn_end() -> void:
	for instance in active_statuses.duplicate():
		if instance.status.duration_type == StatusEffect.DurationType.TURNS:
			instance.remaining_turns -= 1
			if instance.remaining_turns <= 0:
				active_statuses.erase(instance)


# Recuperer l'animationSet en fonction de la source
func get_animation_set() -> CombatAnimationSet:
	if is_player:
		return source_character.character_class.combat_animations
	return source_enemy.combat_animations


func get_idle_frames() -> SpriteFrames:
	if is_player:
		return source_character.character_class.idle_sprite_frame
	return source_enemy.idle_sprite_frame

# Permet de modifier la precision
func get_accuracy_multiplier() -> float:
	var multiplier := 1.0
	for instance in active_statuses:
		for modifier in instance.status.stat_modifiers:
			if modifier.stat_name == "accuracy_multiplier":
				multiplier *= (1.0 + modifier.percent_amount)
	return multiplier


func get_damage_taken_multiplier() -> float:
	var multiplier := 1.0
	for instance in active_statuses:
		for modifier in instance.status.stat_modifiers:
			if modifier.stat_name == "damage_taken_multiplier":
				multiplier *= (1.0 + modifier.percent_amount)
	return multiplier
	

func get_status_resist_multiplier() -> float:
	var multiplier := 1.0
	for instance in active_statuses:
		for modifier in instance.status.stat_modifiers:
			if modifier.stat_name == "status_apply_multiplier":
				multiplier *= (1.0 + modifier.percent_amount)
	return multiplier
	

func remove_cancellable_statuses() -> int:
	var removed_count := 0
	for instance in active_statuses.duplicate():
		if instance.status.is_cancellable:
			active_statuses.erase(instance)
			removed_count += 1
	return removed_count
