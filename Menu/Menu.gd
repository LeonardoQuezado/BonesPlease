extends Control

# Muda a cena atual para a tela do jogo.
func _on_StartButton_pressed():
	get_tree().change_scene("res://CenaDoJogoAqui")

# Muda a cena atual para a tela de opções.
func _on_OptionsButton_pressed():
	var options_scene = load("res://Options.tscn").instance()
	get_tree().change_scene.add_child(options_scene)

# Exibe um pop-up de confirmação.
func _on_QuitButton_pressed():
	get_tree().quit()
