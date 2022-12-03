extends Control

# Faz o carregamento prévio da cena do menu principal.
onready var menu_scene = preload("res://Source/Scenes/Menu.tscn")

# A variável pai desta cena.
export(PackedScene) var root_scene

# Reseta as animações.
func reset():
	$AnimationPlayer.play("RESET")

# Toca a animação do calendário. (Mostra o dia atual).
func play_calendar_animation():
	# Altera as informações da animação.
	$Calendar/DayInfo.text = "Dia %d" % self.root_scene.current_day
	
	# Toca a animação e espera a mesma terminar.
	$AnimationPlayer.play("CALENDAR_FADE")
	yield($AnimationPlayer, "animation_finished")

# Toca a animação de nova fase. (Mostra o dia).
func play_start_level_animation():
	# Altera as informações da animação.
	$LevelStart/Title.text = "Dia %d" % self.root_scene.current_day
	
	# Toca a animação e espera a mesma terminar.
	$AnimationPlayer.play("NEW_DAY_FADE")
	yield($AnimationPlayer, "animation_finished")
	
	# Permite que os sons sejam tocados.
	self.root_scene.can_clock_play_sound = true
	self.root_scene.can_play_hospital_sound = true
	self.root_scene.can_play_ambience_sound = true
	
	# Inicia o timer do "PatientTimer".
	self.root_scene.get_node("Interactables").start_patient_timer()

# Toca a animação do fim da fase. (Mostra os status do jogador).
func play_end_level_animation():
	# Para o timer do "PatientTimer".
	self.root_scene.get_node("Interactables").stop_patient_timer()
	
	# Altera as informações da animação.
	$LevelEnd/Title.text = "Dia %d terminou" % self.root_scene.current_day
	$LevelEnd/VerticalContainer/SubTitleSaves/SaveCount.text = "%d" % self.root_scene.saved_people_count
	$LevelEnd/VerticalContainer/SubTitleDeaths/DeathCount.text = "%d" % self.root_scene.dead_people_count
	$LevelEnd/VerticalContainer/SubTitleNoReply/NoReplyCount.text = "%d" % self.root_scene.no_reply_people_count
	
	# Toca a animação e espera a mesma terminar.
	$AnimationPlayer.play("END_DAY_FADE")
	yield($AnimationPlayer, "animation_finished")
	
	self.show_end_day_buttons()

# Toca a animação informando que um paciente não foi atendido.
func play_no_reply_animation():
	$AnimationPlayer.play("PATIENT_NO_REPLY")
	yield($AnimationPlayer, "animation_finished")
	
# Toca a animação informando que um paciente foi salvo
func play_saved_animation():
	$AnimationPlayer.play("PATIENT_SAVED")
	yield($AnimationPlayer, "animation_finished")
	
# Toca a animação informando que um paciente foi morto.
func play_dead_animation():
	$AnimationPlayer.play("PATIENT_DEAD")
	yield($AnimationPlayer, "animation_finished")

# Mostra os botões pós término de fase.
func show_end_day_buttons():
	# Toca a animação e espera a mesma terminar.
	$AnimationPlayer.play("BUTTONS_END_FADE")
	yield($AnimationPlayer, "animation_finished")

# Acionado quando o botão "Cochilar" for pressionado.
func _on_NextDay_pressed():
	# Esconde os botões.
	$LevelEnd/HBoxContainer.visible = false
	
	# Toca a animação e espera a mesma terminar.
	$AnimationPlayer.play("FADE")
	yield($AnimationPlayer, "animation_finished")
	
	# Começa um novo dia no jogo.
	self.root_scene.start_new_day()

# Acionado quando o botão "Voltar ao Menu" for pressionado.
func _on_GoBackToMenu_pressed():
	# Esconde os botões.
	$LevelEnd/HBoxContainer.visible = false
	
	# Toca a animação e espera a mesma terminar.
	$AnimationPlayer.play("FADE")
	yield($AnimationPlayer, "animation_finished")
	
	# Mostra o PopUp.
	$LevelEnd/Popup.visible = true

# Acionado quando o botão "Sim" de "Voltar ao Menu" for pressionado. 
func _on_Yes_pressed():
	# Esconde os botões.
	$LevelEnd/Popup.visible = false
	
	# Toca a animação e espera a mesma terminar.
	$AnimationPlayer.play("FADE")
	yield($AnimationPlayer, "animation_finished")
	
	# Volta para o Menu.
	self.menu_scene.instance()
	self.get_tree().change_scene_to(self.menu_scene)

# Acionado quando o botão "Não" de "Voltar ao Menu" for pressionado.
func _on_No_pressed():
	# Esconde os botões.
	$LevelEnd/Popup.visible = false
	
	# Toca a animação e espera a mesma terminar.
	$AnimationPlayer.play("FADE")
	yield($AnimationPlayer, "animation_finished")
	
	# Mostra os botões.
	$LevelEnd/HBoxContainer.visible = true
