extends AudioStreamPlayer

func play_sfx():
	# Csak simán elindítjuk. 
	# A Max Polyphony miatt a korábbiak tovább szólnak, 
	# az új pedig hozzáadódik.
	play()
