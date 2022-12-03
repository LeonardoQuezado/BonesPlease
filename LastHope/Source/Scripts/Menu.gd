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
	# Toca a animação de "TV Static".
	$Background/Animation/AnimationPlayer.play("change_to_game")
	# Espera a animação terminar.
	yield($Background/Animation/AnimationPlayer, "animation_finished")
	# Troca para a cena do jogo principal.
	self.get_tree().change_scene("res://Source/Scenes/Game.tscn")

# Muda a cena atual para a tela de opções.
func _on_OptionsButton_pressed():
	# Toca a animação de "TV Static".
	$Background/Animation/AnimationPlayer.play("change_to_options")
	# Espera a animação terminar.
	yield($Background/Animation/AnimationPlayer, "animation_finished")
	self._change_options_screens(true)
	
# Exibe um pop-up de confirmação.
func _on_QuitButton_pressed():
	# Toca a animação de "TV Static".
	$Background/Animation/AnimationPlayer.play("change_to_exit")
	# Espera a animação terminar.
	yield($Background/Animation/AnimationPlayer, "animation_finished")
	self._change_exit_screens(true)

# Fecha o jogo.
func _on_YesButton_pressed():
	get_tree().quit()

# Volta para o menu principal.
func _on_NoButton_pressed():
	# Toca a animação de "TV Static".
	$Background/Animation/AnimationPlayer.play("change_to_menu")
	# Espera a animação terminar.
	yield($Background/Animation/AnimationPlayer, "animation_finished")
	self._change_exit_screens(false)

# Acionado quando a "checkbox" de FullScreen for pressionada.
func _on_FullScreenCheckBox_pressed():
	OS.window_fullscreen = not OS.window_fullscreen

# Acionado quando o texto de FullScreen for pressionado.
func _on_FullScreenText_pressed():
	OS.window_fullscreen = not OS.window_fullscreen
	var check_box = $Texts/OptionsTexts/OptionsHorizontalContainer/OptionsVerticalContainerLeft/FullScreenCheckBoxHorizontalContaier/FullScreenCheckBox
	check_box.pressed = not check_box.pressed

# Acionado quando a "checkbox" de Bordeless for pressionada.
func _on_BordelessCheckBox_pressed():
	OS.window_borderless = not OS.window_borderless

# Acinado quando o texto do Bordeless for pressinado.
func _on_BordelessText_pressed():
	OS.window_borderless = not OS.window_borderless
	var check_box =	$Texts/OptionsTexts/OptionsHorizontalContainer/OptionsVerticalContainerLeft/BordelessCheckBoxHorizontalContainer/BordelessCheckBox
	check_box.pressed = not check_box.pressed

# Acionado quando a "checkbox" de Vsync for pressionada.
func _on_VsyncCheckBox_pressed():
	OS.set_use_vsync(not OS.is_vsync_enabled())

# Acinado quando o texto do Vsync for pressionado.
func _on_VsyncText_pressed():
	OS.set_use_vsync(not OS.is_vsync_enabled())
	var check_box = $Texts/OptionsTexts/OptionsHorizontalContainer/OptionsVerticalContainerRight/VsyncCheckBoxHorizontalContainer/VsyncCheckBox
	check_box.pressed = not check_box.pressed

# Acionado quando o texto do FXAA for pressionado.
func _on_FXAAText_pressed():
	ProjectSettings.set_setting("rendering/quality/filters/use_fxaa", not ProjectSettings.get_setting("rendering/quality/filters/use_fxaa"))
	var check_box = $Texts/OptionsTexts/OptionsHorizontalContainer/OptionsVerticalContainerRight/FXAACheckBoxHorizontalContainer/FXAACheckBox
	check_box.pressed = not check_box.pressed

# Acionado quando a "checkbox" do FXAA for pressionada.
func _on_FXAACheckBox_pressed():
	ProjectSettings.set_setting("rendering/quality/filters/use_fxaa", not ProjectSettings.get_setting("rendering/quality/filters/use_fxaa"))

# Volta para o Menu principal.
func _on_BackButton_pressed():
	# Toca a animação de "TV Static".
	$Background/Animation/AnimationPlayer.play("change_to_menu")
	# Espera a animação terminar.
	yield($Background/Animation/AnimationPlayer, "animation_finished")
	self._change_options_screens(false)

# Acionado quando o slider responsável pelo volume do jogo é alterado.
func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value)

# Botão super secreto.
func _on_SuperSecretButton_pressed():
	get_tree().quit()
	
# Desativa o som de "TVStatic" se estiver tocando (bug).
func _physics_process(delta):
	if $Background/Animation/RateVerticalContainer/TVStatic.playing:
		$Background/Animation/RateVerticalContainer/TVStatic.stop()
