extends Label

var coins = 0

func _ready():
	update_text()

# Ezt a függvényt fogjuk hívni, ha nő a pontszám
func add_coin():
	coins += 1
	update_text()

func update_text():
	text = str(coins)
