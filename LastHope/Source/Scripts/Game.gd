extends Control

# Faz o carregamento prévio da cena do menu principal.
onready var menu_scene = preload("res://Source/Scenes/Menu.tscn")

# O cartão que está sendo segurado atualmente.
var held_object = null

# O nome do paciente atual.
var current_patient_name = null

# O tipo sanguíneo do paciente atual.
var current_blood_type = null

# As dimensões da resolução atual.
var width = 0
var height = 0

# Indica se o som do relógio pode ser tocado.
var can_clock_play_sound = false

# Indica se o som do hospital pode ser tocado.
var can_play_hospital_sound = false

# Indica se o som do ambiente pode ser tocado.
var can_play_ambience_sound = false

# Indica o nível da fase atual.
var current_day = 0

# As combinações dos sons ambientes.
var sounds

# A combinação de som escolhida.
var selected_sounds = null

# Os cartões/documentos do paciente.
var cards

# O randomizer.
var rng = RandomNumberGenerator.new()


func _ready():
	print("TODO: Game.gd Fazer uma animação ou coisa do tipo do cartão dando 'spawn'.")
	print("TODO: Game.gd Arrumar o tempo de cada fase.")

	# Registra os cartões.
	self.cards = [
		$Interactables/HeartRate, 
		$Interactables/ID, 
		$Interactables/Temperature, 
		$Interactables/Virus,
		$Interactables/Blood
	]

	# Toca a animação de novo dia.
	self.begin_new_day()

	# Ativa a função "clicked" em "_on_pickable_clicked" dos cartões.
	for node in get_tree().get_nodes_in_group("pickable"):
		node.connect("clicked", self, "_on_pickable_clicked")

# Seleciona novos efeitos sonoros de ambiente.
func _select_new_sounds():
	# Atualiza a seed do 'RNG'.
	self.rng.randomize()
	
	# Todas as possíveis combinações sonoras que forma uma ambietação.
	self.sounds = [
		[$Cars, $Rain, $Fan],
		[$Cars, $Rain],
		[$Rain, $Fan],
		[$Cars, $Fan],
		[$Fan],
		[$Rain],
		[$Cars]
	]

	# Escolhe uma combinação de um som ambietne qualquer.
	self.selected_sounds = self.sounds[self.rng.randi() % self.sounds.size()]

# Faz os sons ambientes tocarem indefinidamente.
func _repeat_ambience_sound():
	for sound in self.selected_sounds:
		if not sound.playing and self.can_play_ambience_sound:
			sound.play()

# Faz o som ambiente do hospital tocar indefinidamente.
func _repeat_hospital_background_sound():
	if not $HospitalBackground.playing and self.can_play_hospital_sound:
		$HospitalBackground.play()

# Faz o efeito sonoro do relógio tocar indefinidamente.
func _repeat_clock_ticking_sound():
	if not $Clock_Ticking.playing and self.can_clock_play_sound:
		$Clock_Ticking.play()

func _physics_process(delta):
	# Termina o dia atual se o tempo tiver acabado.
	if $Interactables/ClockControl.time_up:
		self.end_current_day()
	
	# Toca o efeito sonoro do hospital.
	self._repeat_hospital_background_sound()
	
	# Toca o efeito sonoro ambiente.
	self._repeat_ambience_sound()
	
	# Toca o efeito sonoro do relógio.
	self._repeat_clock_ticking_sound()
	
	# Pega as dimensões da resolução atual.
	self.width = self.get_viewport().size.x
	self.height = self.get_viewport().size.y

	# Pega o nome do paciente no cartão ID.
	self.current_patient_name = self.get_node("Interactables/ID").patient_name
	
	# Pega o tipo sanguíneo do paciente pelo ID.
	self.current_blood_type = self.get_node("Interactables/ID").patient_blood_type
	
	# Altera o nome do paciente nos demais cartões.
	for node in get_tree().get_nodes_in_group("pickable"):
		# Altera o nome do paciente no cartão atual se houver o campo para
		# o nome do paciente no cartão.
		if "patient_name" in node:
			node.patient_name = self.current_patient_name
		# Altera o tipo sanguineo no cartão atual se houver o campo para
		# o tipo sanguineo no cartão.
		if "patient_blood_type" in node:
			node.patient_blood_type = self.current_blood_type

# Faz com que, se clicado em algum cartão, o mesmo acompanha o movimento do mouse,
# representando o "Drag".
func _on_pickable_clicked(object):
	if !held_object:
		held_object = object
		held_object.scale = Vector2(1.25, 1.25)
		held_object.pickup()

# Faz com que, se solto o cartão, o mesmo deixa de acompanhar o movimento do mouse,
# representando o "Drop".
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if held_object and !event.pressed:
			held_object.drop()
			held_object = null

# Altera as informações dos cartões/documentos dos pacientes.
func respawn_cards():
	for card in self.cards:
		card._ready()
	print("TODO: Game.gd Fazer o documento principal recalcular as respostas (cada documento calcula a resposta certa e exporta-a como uma variável, na função _ready).")

func begin_new_day():
	# Escolhe novos efeitos sonoros de ambiente.
	self._select_new_sounds()
	
	# Altera o dia atual.
	self.current_day += 1
	$NewLevel/Title.text = "Dia %d" % self.current_day
	
	# Toca animação de um novo dia e espera a mesma terminar.
	$AnimationPlayer.play("NEW_DAY_FADE")
	yield($AnimationPlayer, "animation_finished")
	
	# Reinicia o relógio.
	$Interactables/ClockControl._ready()
	
	# Toca os sons.
	self.can_clock_play_sound = true
	self.can_play_hospital_sound = true
	self.can_play_ambience_sound = true
	
	# Altera as informações dos cartões.
	self.respawn_cards()

# Termina o dia atual.
func end_current_day():
	# Ignora o "spam".
	$Interactables/ClockControl.time_up = false
	
	# Para os sons.
	self.can_clock_play_sound = false
	self.can_play_hospital_sound = false
	self.can_play_ambience_sound = false
	
	# Altera o dia atual na animação do fim do dia, exibindo o dia correto.
	$EndLevel/Title.text = "Dia %d terminou" % self.current_day
	
	# Para o som do relógio.
	$Clock_Ticking.stop()
	
	# Para o som do hospital.
	$HospitalBackground.stop()
	
	# Para o som ambiente.
	for sound in self.selected_sounds:
		sound.stop()
	
	# Toca o som do "Cuckoo".
	$Cuckoo.play()
	
	# Toca a animação que indica o termino do dia.
	$AnimationPlayer.play("END_DAY_FADE")
	yield($AnimationPlayer, "animation_finished")
	
	# Toca a aniamção que mostrará os botões de continuar ou voltar ao menu.
	$AnimationPlayer.play("BUTTONS_END_DAY_FADE")
	yield($AnimationPlayer, "animation_finished")

# Mostra o dia (fase) atual.
func _on_Calendar_pressed():
	# Altera o conteúdo da label "DayInfo", para exibir o dia corretamente.
	$CalendarFade/DayInfo.text = "Dia %d" % self.current_day
	# Toca a animação e espera que a mesma termine, impede 'overlap' de animações.
	$AnimationPlayer.play("DAY_INFO_FADE")
	yield($AnimationPlayer, "animation_finished")

func _on_CheckList_pressed():
	print("TODO: Game.gd Checklist_pressed() :. Mostrar documento principal. Aquele que o usuário tem que preencher.")

# Volta para o Menu.
func _on_GoBackToMenu_pressed():
	# Esconde os botões.
	$EndLevel/HBoxContainer.visible = false
	
	# Toca a animação de FADE.
	$AnimationPlayer.play("FADE")
	yield($AnimationPlayer, "animation_finished")
	
	# Mostra o Popup.
	$EndLevel/Popup.visible = true

# Vai para o próximo dia.
func _on_NextDay_pressed():
	# Esconde os botões.
	$EndLevel/HBoxContainer.visible = false
	$AnimationPlayer.play("FADE")
	yield($AnimationPlayer, "animation_finished")
	self.begin_new_day()

# Botão de confirmar do PopUp.
func _on_Yes_pressed():
	# Esconde o Popup.
	$EndLevel/Popup.visible = false
	
	# Toca a animação de FADE.
	$AnimationPlayer.play("FADE")
	yield($AnimationPlayer, "animation_finished")
	
	# Volta para o Menu.
	self.menu_scene.instance()
	self.get_tree().change_scene_to(self.menu_scene)

# Botão de negação do PopUp.
func _on_No_pressed():
	# Esconde o Popup.
	$EndLevel/Popup.visible = false
	
	# Toca a animação de FADE.
	$AnimationPlayer.play("FADE")
	yield($AnimationPlayer, "animation_finished")
	
	# Motra os botões.
	$EndLevel/HBoxContainer.visible = true
