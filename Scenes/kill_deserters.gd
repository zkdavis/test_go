extends Node2D

var warning_radius : float = 500.0
var death_radius : float = 1000.0
var has_entered_warning_zone : bool = false
var has_entered_death_zone : bool = false
var sound_player_alarm_generic = AudioStreamPlayer.new()
const WARNING_FLASH_SECONDS = 2
const ALARM_SECONDS = 3.7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("Alien").reset_alien(2*death_radius)
	get_node("BannerTimer").set_one_shot(true)
	get_node("AlarmTimer").set_one_shot(true)
	sound_player_alarm_generic.stream = preload("res://Scenes/Alarm_generic.mp3")
	add_child(sound_player_alarm_generic)

func adjust_radii(warning_ : float, death_ : float) -> void:
	warning_radius = clamp(warning_, 0, INF)
	death_radius = clamp(death_, warning_radius, INF)
	get_node("Alien").reset_alien(2*death_radius)

func store_ship_position_and_process(pos : Vector2) -> void:
	get_node("Alien").store_ship_position(pos)
	var radius = pos.length()
	if !has_entered_warning_zone and (radius > warning_radius):
		has_entered_warning_zone = true
		flash_warning()
		get_node("BannerTimer").start(WARNING_FLASH_SECONDS)
		get_node("AlarmTimer").start(ALARM_SECONDS)
	elif !has_entered_death_zone and (radius > death_radius):
		has_entered_death_zone = true
		get_node("Alien").activate_ship()

func flash_warning() -> void:
	get_parent().get_node("Ship_Scene/CanvasLayer/DangerWarning").turn_on()
	sound_player_alarm_generic.play()
	
func remove_warning() -> void:
	get_parent().get_node("Ship_Scene/CanvasLayer/DangerWarning").turn_off()

func stop_alarm() -> void:
	sound_player_alarm_generic.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func _on_banner_timer_timeout() -> void:
	remove_warning()

func _on_alarm_timer_timeout() -> void:
	stop_alarm()
