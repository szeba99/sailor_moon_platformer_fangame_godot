extends HSlider

var bus_idx = AudioServer.get_bus_index("SFX")

func _ready() -> void:
	#set bus_idx
	bus_idx = AudioServer.get_bus_index("SFX")
	#update slider
	value = AudioServer.get_bus_volume_linear(bus_idx)

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(bus_idx,value)
