extends Node

# Faz o carregamento prévio da cena do menu principal.
onready var menu_scene = preload("res://Source/Scenes/Menu.tscn")

# Objeto responsável pelo controle do volume.
var master_bus = AudioServer.get_bus_index("Master")

# Toca a animação de "FADE" e espera ela terminar.
func play_fade_animation():
	$AnimationPlayer.play("FADE")
	yield($AnimationPlayer, "animation_finished")

# Toca o som de estática.
func play_static_sound():
	$Static.play()
	
# Para o som de estática.
func stop_static_sound():
	$Static.stop()

func _physics_process(delta):
	# Pausa o jogo (Esc Menu).
	if Input.is_action_just_pressed("pause"):
		if not self.get_tree().paused:
			self.play_fade_animation()
			self.play_static_sound()
			# Pausa o jogo.
			self.get_tree().paused = true
			# Mostra as opções quando o jogo estiver pausado.
			$Menu.visible = true
			$Options.visible = false
			$ExitPopup.visible = false
			# Altera a cor de fundo, destacando as opções.
			$Shaders.visible = true
			$BackgroundFocus.visible = true
			$BackgroundAjust.visible = true
			$MonitorFrame.visible = true
			# Larga o documento atual se houver.
			if self.get_parent().get_node(".").held_object != null:
				self.get_parent().get_node(".").held_object.drop()
				self.get_parent().get_node(".").held_object = null
		else:
			self.play_fade_animation()
			self.stop_static_sound()
			# Despausa o jogo.
			self.get_tree().paused = false
			# Esconde as opções quando o jogo estiver despausado.
			$Menu.visible = false
			$Options.visible = false
			$ExitPopup.visible = false
			# Altera a cor de fundo, destacando o jogo.
			$Shaders.visible = false
			$BackgroundFocus.visible = false
			$BackgroundAjust.visible = false
			$MonitorFrame.visible = false

# Despausa o jogo; Volta ao jogo.
func _on_Continue_pressed():
	if self.get_tree().paused:
		self.play_fade_animation()
		self.stop_static_sound()
		# Despausa o jogo.
		self.get_tree().paused = false
		# Esconde as opções quando o jogo estiver despausado.
		$Menu.visible = false
		$Options.visible = false
		$ExitPopup.visible = false
		# Altera a cor de fundo, destacando as opções.
		$Shaders.visible = false
		$BackgroundFocus.visible = false
		$BackgroundAjust.visible = false
		$MonitorFrame.visible = false

# Volta para o menu principal.
func _on_Exit_pressed():
	self.play_fade_animation()
	self.play_static_sound()
	$Menu.visible = false
	$Options.visible = false
	$ExitPopup.visible = true

# Botão de confirmação do popup "Sair", volta para o menu.
func _on_Yes_pressed():
	self.play_fade_animation()
	self.stop_static_sound()
	self.menu_scene.instance()
	print("TODO: Pause.gd Arrumar a troca de cena para a principal, menu ta estatico.")
	self.get_tree().change_scene_to(self.menu_scene)

# Botão de recusar do popup "Sair", volta para o menu de pausa.
func _on_No_pressed():
	self.play_fade_animation()
	self.play_static_sound()
	$ExitPopup.visible = false
	$Options.visible = false
	$Menu.visible = true

# Altera o volume conforme o slider.
func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value)

# Volta para o menu do jogo.
func _on_Back_pressed():
	self.play_fade_animation()
	self.play_static_sound()
	$ExitPopup.visible = false
	$Options.visible = false
	$Menu.visible = true

# Vai para as opções.
func _on_Options_pressed():
	self.play_fade_animation()
	self.play_static_sound()
	$ExitPopup.visible = false
	$Options.visible = true
	$Menu.visible = false
