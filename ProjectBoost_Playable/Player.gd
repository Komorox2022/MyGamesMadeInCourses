extends RigidBody3D

@export var thrust: float = 1000.0
@export var torque_thrust: float = 100.0

@export var between_level_duration: float = 2.5

@onready var explosion_audio: AudioStreamPlayer = $Explosion_audio
@onready var success_audio: AudioStreamPlayer = $Success_audio
@onready var rocket_audio: AudioStreamPlayer3D = $Rocket_audio

@onready var booster_middle_particles: GPUParticles3D = $BoosterMiddleParticles
@onready var booster_left_particles: GPUParticles3D = $BoosterLeftParticles
@onready var booster_right_particles: GPUParticles3D = $BoosterRightParticles

@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles


var is_transitioning: bool = false

func _process(delta: float) -> void:
	handle_some_input(delta)

func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "FloorGroup" in body.get_groups():
			crash_func()
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		if "Hazardous" in body.get_groups():
			crash_func()

func complete_level(level_param: String) -> void:
	print("Nice!")
	success_particles.emitting = true
	success_audio.play()
	is_transitioning = true
	set_process(false)
	var tween = create_tween()
	tween.tween_interval(between_level_duration)
	tween.tween_callback(get_tree().change_scene_to_file.bind(level_param))
	
func crash_func() -> void:
	print("you crashed!")
	explosion_particles.emitting = true
	explosion_audio.play()
	is_transitioning = true
	set_process(false)
	var tween = create_tween()
	tween.tween_interval(between_level_duration)
	tween.tween_callback(get_tree().reload_current_scene)
	
func handle_some_input(deltaParam: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * deltaParam * thrust)
		if rocket_audio.playing == false:
			rocket_audio.play()
		if booster_middle_particles.emitting == false:
			booster_middle_particles.emitting = true
	else:
		rocket_audio.stop()
		booster_middle_particles.emitting = false

	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * deltaParam))
		if booster_right_particles.emitting == false:
			booster_right_particles.emitting = true
	else:
		booster_right_particles.emitting = false
	
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -torque_thrust * deltaParam))
		if booster_left_particles.emitting == false:
			booster_left_particles.emitting = true
	else:
		booster_left_particles.emitting = false

	if Input.is_action_just_pressed("QuitAction"):
		get_tree().quit()
	if Input.is_action_just_pressed("ReloadScene"):
		print("reloading scene!")
		var tween = create_tween()
		tween.tween_interval(1.0)
		tween.tween_callback(get_tree().reload_current_scene)

