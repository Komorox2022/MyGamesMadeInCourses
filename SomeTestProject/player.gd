extends RigidBody3D

@export var health_points: int = 100
@export var players_velocity: float = 500.0
@export var players_rotation_velocity: float = 250.0
@export var players_jump_velocity: float = 1000.0
@export var players_max_health: int = 1000
@export var players_min_health_loss: int = 1


@onready var lost_audio: AudioStreamPlayer = $LostAudio
@onready var hit_audio: AudioStreamPlayer = $HitAudio
@onready var hit_health_audio: AudioStreamPlayer = $HitHealthAudio
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("MoveForward"):
		apply_force(basis.x * delta * players_velocity)
	if Input.is_action_pressed("MoveBackward"):
		apply_force(-basis.x * delta * players_velocity)
	if Input.is_action_pressed("TurnLeft"):
		apply_torque(Vector3(0.0, 1.0, 0.0) * delta * players_rotation_velocity)
	if Input.is_action_pressed("TurnRight"):
		apply_torque(Vector3(0.0, -1.0, 0.0) * delta * players_rotation_velocity)
	
	if Input.is_action_just_pressed("Jump"):
		apply_force(Vector3(0.0, 1.0, 0.0)* delta * players_jump_velocity)
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("Sprint"):
		players_velocity *= 1.5
	if Input.is_action_just_released("Sprint"):
		players_velocity = 1000
	
	
func _on_body_entered(body: Node) -> void:
	if "HealthBox" in body.get_groups():
		print("Giving health!")
		success_particles.emitting = true
		health_points += body.healing_factor
		hit_health_audio.play()
		check_and_show_health()
		
	if "DamageBox" in body.get_groups():
		print("dealing damage!")
		explosion_particles.emitting = true
		health_points -= body.damage_factor
		hit_audio.play()
		check_and_show_health()


func lost_sequence() -> void:
	print("You lost!")
	lost_audio.play()
	set_process(false)
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)
	
func check_and_show_health() -> void:
	if health_points < players_min_health_loss:
		lost_sequence()	
	health_points = clamp(health_points, 0, players_max_health)
	print(health_points)
