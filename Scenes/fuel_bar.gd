extends ProgressBar

const MAX_FUEL = 100
var fuel = MAX_FUEL

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.max_value = MAX_FUEL
	refresh_state()

func refresh_state() -> void:
	set_fuel_label()
	set_fuel_bar()

func set_fuel_label() -> void:
	$FuelLabel.text = "Fuel: %s" % fuel

func set_fuel_bar() -> void:
	self.value = fuel

func reduce() -> void:
	fuel -= 1
	if fuel <= 0:
		fuel = 0
	refresh_state()
	
func out_of_fuel() -> bool:
	return fuel == 0
