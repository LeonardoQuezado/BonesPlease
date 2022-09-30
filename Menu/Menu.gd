extends Control

# Indica se o menu principal está ativo ou não.
export(bool) var is_menu_active

# Indica se a tela de sair está ativa ou não.
export(bool) var is_exit_active

# Objeto responsável pelo controle do volume.
var master_bus = AudioServer.get_bus_index("Master")

# Muda a visibilidade da tela atual e da tela de opções.
func _change_options_screens(is_current_visible):
	# Indica se o menu está ativo ou não.
	self.is_menu_active = not self.is_menu_active
	
	# Esconde os textos da tela principal.
	$Texts/MenuTexts.visible = not is_current_visible
	
	# Esconde/Mostra alguns shaders.
	$Shaders/VHSShaderControl.visible = not is_current_visible
	$Shaders/TVShaderControl.visible = not is_current_visible
	$Shaders/VHSStopShaderControl.visible = is_current_visible
	
	# Exibe a tela de opções.
	$Texts/OptionsTexts.visible = is_current_visible
	
# Muda a visibilidade da tela atual e da tela de sair.
func _change_exit_screens(is_current_visible):
	# Indica se o menu está ativo ou não.
	self.is_menu_active = not self.is_menu_active
	# Indica se a tela de sair está ativa ou não.
	self.is_exit_active = not self.is_exit_active
	
	# Esconde os textos da tela principal.
	$Texts/MenuTexts.visible = not is_current_visible
	
	# Exibe a tela de sair.
	$Texts/ExitTexts.visible = is_current_visible

# Muda a cena atual para a tela do jogo.
func _on_StartButton_pressed():
	print("TODO: Botao para ir ao jogo.")
	pass

# Muda a cena atual para a tela de opções.
func _on_OptionsButton_pressed():
	self._change_options_screens(true)
	
# Exibe um pop-up de confirmação.
func _on_QuitButton_pressed():
	self._change_exit_screens(true)

# Fecha o jogo.
func _on_YesButton_pressed():
	get_tree().quit()

# Volta para o menu principal.
func _on_NoButton_pressed():
	self._change_exit_screens(false)

# Acionado quando a "checkbox" de FullScreen for pressionada.
func _on_FullScreenCheckBox_pressed():
	OS.window_fullscreen = not OS.window_fullscreen

# Acionado quando o texto de FullScreen for pressionado.
func _on_FullScreenText_pressed():
	OS.window_fullscreen = not OS.window_fullscreen
	var check_box = $Texts/OptionsTexts/OptionsHorizontalContainer/OptionsVerticalContainer/FullScreenCheckBoxHorizontalContaier/FullScreenCheckBox
	check_box.pressed = not check_box.pressed

# Acionado quando a "checkbox" de Bordeless for pressionada.
func _on_BordelessCheckBox_pressed():
	OS.window_borderless = not OS.window_borderless

# Acinado quando o texto do Bordeless for pressinado.
func _on_BordelessText_pressed():
	OS.window_borderless = not OS.window_borderless
	var check_box =	$Texts/OptionsTexts/OptionsHorizontalContainer/OptionsVerticalContainer/BordelessCheckBoxHorizontalContainer/BordelessCheckBox
	check_box.pressed = not check_box.pressed

# Volta para o Menu principal.
func _on_BackButton_pressed():
	self._change_options_screens(false)

# Acionado quando o slider responsável pelo volume do jogo é alterado.
func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value)

# Botão super secreto.
func _on_SuperSecretButton_pressed():
	get_tree().quit()
