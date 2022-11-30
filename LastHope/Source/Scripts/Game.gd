extends Control

# Faz o carregamento prévio da cena do menu principal.
onready var menu_scene = preload("res://Source/Scenes/Menu.tscn")

# Faz o carregamento da cena do ID do paciente.
onready var id_scene = preload("res://Source/Scenes/ID.tscn")

# Faz o carregamento da cena do mini-documento principal.
onready var document_scene = preload("res://Source/Scenes/Document.tscn") 

# Faz o carregamento da cena do documento dos batimentos cardiacos.
onready var heartrate_scene = preload("res://Source/Scenes/HeartRate.tscn")

# Faz o carregamento da cena do documento da temperatura.
onready var temperature_scene = preload("res://Source/Scenes/Temperature.tscn")

# Faz o carregamento da cena do documento do virus.
onready var virus_scene = preload("res://Source/Scenes/Virus.tscn")

# Faz o carregamento do "Dropdown" dos batimentos cardiacos.
onready var heart_rate_dropdown = $DocumentFade/UI/HeartRateSection/PatientBPMClass

# Faz o carregamento do "Dropdown" da temperatura do paciente.
onready var temperature_dropdown = $DocumentFade/UI/TemperatureSection/PatientTemperatureClass

# Faz o carregamento do "Dropdown" do tipo do virus no paciente.
onready var virus_dropdown = $DocumentFade/UI/VirusSection/PatientVirus

# Faz o carregamento do "Dropdown" da existencia do virus no paciente.
onready var has_virus_dropdown = $DocumentFade/UI/VirusSection/PatientHasVirus

# Faz o carregamento do "Timer" da availiação do documento principal.
onready var medic_evaluation_timer = $DocumentFade/MedicEvaluation

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

# Quantidade de pessoas salvas.
var saved_people_count = 0

# Quantidade de pessoas mortas.
var death_people_count = 0

# As combinações dos sons ambientes.
var sounds

# A combinação de som escolhida.
var selected_sounds = null

# O randomizer.
var rng = RandomNumberGenerator.new()

func _ready():
	print("TODO: Game.gd Arrumar o tempo de cada fase.")
	print("TODO: Game.gd Botar o manual em um dos cantos (ajuda)")

	# Adiciona as opções aos dropdown.
	self.add_dropdown_itens()
	
	# Toca a animação de novo dia.
	self.begin_new_day()

	# Ativa a função "clicked" em "_on_pickable_clicked" dos cartões.
	#for node in get_tree().get_nodes_in_group("pickable"):
	#	node.connect("clicked", self, "_on_pickable_clicked")

# Adiciona as opções aos dropdown.
func add_dropdown_itens():
	# Classificações dos batimentos cardiacos.
	for heart_rate_class in ["Normal", "Taquicardia", "Bradicardia"]:
		self.heart_rate_dropdown.add_item(heart_rate_class)
	# Classificação das temperaturas.
	for temp_class in ["Normal", "Estado Febril", "Febre"]:
		self.temperature_dropdown.add_item(temp_class)
	# Os tipos de vírus possíveis no paciente.
	for virus in ["AIDS", "COVID-19", "DENGUE", "HEPATITE", "VARÍOLA"]:
		self.virus_dropdown.add_item(virus)
	# Se o paciente está com o vírus ou não.
	for condition in ["Sim", "Não"]:
		self.has_virus_dropdown.add_item(condition)

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

	# Itera sobre os nós em "Interactables".
	for node in $Interactables.get_children():
		# Pega exclusivamente o ID.
		if "ID" in node.name:
			# Pega o nome do paciente no cartão ID.
			self.current_patient_name = node.patient_name
			
			# Pega o tipo sanguíneo do paciente pelo ID.
			self.current_blood_type = node.patient_blood_type
		
		# Pega quaisquer outros cartões.
		if node is RigidBody2D:
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

# Toca um som aleatório de "PaperFlip".
func play_random_paperflip_sound():
	# Toca um som de "PaperFlip" qualquer.
	var random_paper_sound = [$PaperFlip1, $PaperFlip2]
	var selected_paper_sound = random_paper_sound[self.rng.randi() % random_paper_sound.size()]
	selected_paper_sound.play()
	yield(selected_paper_sound, "finished")

# Toca um som aleatório de "PaperSliding".
func play_random_paperslide_sound():
	# Toca um som de "PaperSliding" qualquer.
	var random_paper_sound = [$PaperSliding1, $PaperSliding2, $PaperSliding3]
	var selected_paper_sound = random_paper_sound[self.rng.randi() % random_paper_sound.size()]
	selected_paper_sound.play()
	yield(selected_paper_sound, "finished")

# Verifica se as respostas estão corretas.
func check_answers():
	if not $Interactables/ClockControl.time_up:
		# Adiciona os cartões a serem verificados as respostas.
		var cards_to_verify = []
		for node in $Interactables.get_children():
			if node is RigidBody2D and not "ID" in node.name:
				cards_to_verify.append(node)
		
		# As respostas do jogador, deve ser colocado na ordem do documento.
		var player_answers = [
			$DocumentFade/UI/HeartRateSection/PatientBPMClass.text,
			$DocumentFade/UI/TemperatureSection/PatientTemperatureClass.text,
			[$DocumentFade/UI/VirusSection/PatientVirus.text, $DocumentFade/UI/VirusSection/PatientHasVirus.text]
		]
		
		# Itera sobre os cartões e as repostas a serem verificadas.
		var cards_answers = []
		for i in range(cards_to_verify.size()):
			# Pega os elementos da lista.
			var card = cards_to_verify[i]
			var answer = player_answers[i]
			
			print(card)
			print(answer)
			
			# Adiciona a resposta a uma outra lista.
			cards_answers.append(card.is_answer_correct(answer))
		
		# Retorna "false" se existir "false" nas respostas.
		if false in cards_answers:
			return false
		# Retorna "true" caso contrário.
		else:
			return true

# Altera as informações dos cartões/documentos dos pacientes.
func respawn_cards():
	# Destroi os cartões anteriores.
	self.destroy_cards()
	
	print("TODO: Game.gd - respawn_cards() Efeito sonoro, servindo como aviso sempre que um novo paciente chegar.")
	
	print("TODO: Game.gd - respawn_cards() Mudar os dias nos IFs dps.")
	
	print("TODO: Game.gd - respawn_cards() botar o cartão de 'blood' como primeiro, o jogador terá que preencher o campo ID. (Sexo, Tipo Sanguineo)")
	# Ajusta os cartões a serem disponibilizados conforme o nível da fase.
	var cards_to_spawn = [self.id_scene]
	if self.current_day >= 1:
		cards_to_spawn.append(self.heartrate_scene)
	if self.current_day >= 2:
		cards_to_spawn.append(self.temperature_scene)
	if self.current_day >= 3:
		cards_to_spawn.append(self.virus_scene)
	
	# Toca um som aleatório de "PaperSliding".
	self.play_random_paperslide_sound()

	# Itera sobre todos os documentos a serem instanciados, conforme o nível da fase.
	for card in cards_to_spawn:
		# Instanceia a cena.
		var instanced_card = card.instance()
	
		# Ajusta a posição da cena instanciada.
		instanced_card.transform.origin = Vector2(self.width / 2, 0)
		
		# Torna o documento "arrastável".
		instanced_card.connect("clicked", self, "_on_pickable_clicked")
	
		# Adiciona-o a cena.
		$Interactables.add_child(instanced_card)

func destroy_cards():
	# Toca um som aleatório de "PaperSliding".
	self.play_random_paperslide_sound()
	
	print("TODO: Game.gd - destroy_cards() Animação dos documentos indo para o lado direito ou esquerdo da tela, com a hitbox desligada e sumindo logo em seguida.")
	
	# Remove os cartões anteriores.
	for node in $Interactables.get_children():
		if node is RigidBody2D:
			node.queue_free()

func begin_new_day():
	# Escolhe novos efeitos sonoros de ambiente.
	self._select_new_sounds()
	
	# Reseta a quantidade de pessoas salvas/mortas.
	self.saved_people_count = 0
	self.death_people_count = 0
	
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
	
	# Esconde o documento, caso esteja visível.
	if $DocumentFade.visible:
		$DocumentFade.visible = false
	
	# Para os sons.
	self.can_clock_play_sound = false
	self.can_play_hospital_sound = false
	self.can_play_ambience_sound = false
	
	# Altera o dia atual na animação do fim do dia, exibindo o dia correto.
	$EndLevel/Title.text = "Dia %d terminou" % self.current_day
	
	# Altera a quantidade de pessoas salvas/mortas durante a fase.
	$EndLevel/VerticalContainer/SubTitleSaves/SaveCount.text = str(self.saved_people_count)
	$EndLevel/VerticalContainer/SubTitleDeaths/DeathCount.text = str(self.death_people_count)
	
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

# Mostra o documento principal.
func _on_CheckList_pressed():
	# Toca um som aleatório de "PaperFlip".
	self.play_random_paperflip_sound()

	print("TODO: Game.gd - _on_CheckList_pressed() Impedir o acesso ao botão caso um mini-documento esteja presenta na tela.")

	# Mostra o documento.
	$DocumentFade.visible = true
	
	print("TODO: Game.gd - _on_CheckList_pressed() Mudar os dias nos IFs dps.")
	print("TODO: Game.gd - _on_CheckList_pressed() Mudar a ordem dos documentos, o 'blood' será adicionado como primeiro.")
	
	# Esconde os outros campos conforme o dia do jogo.
	if self.current_day >= 1:
		$DocumentFade/UI/HeartRateSection.visible = true
	if self.current_day >= 2:
		$DocumentFade/UI/TemperatureSection.visible = true
	if self.current_day >= 3:
		$DocumentFade/UI/VirusSection.visible = true

# Esconde o documento principal.
func _on_DocExitButton_pressed():	
	# Toca um som aleatório de "PaperFlip".
	self.play_random_paperflip_sound()

	# Mostra o documento.
	$DocumentFade.visible = false

# Envia o documento para avaliação.
func _on_DocSendButton_pressed():
	# Toca um som aleatório de "PaperFlip".
	self.play_random_paperflip_sound()

	# Inicia o timer.
	self.medic_evaluation_timer.start()

	# Mostra o documento.
	$DocumentFade.visible = false

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

# Simula a assinatura e carimbo do médico responsável. 
func _on_MedicEvaluation_timeout():
	# Toca o som de assinatura, simula um médico assinando.
	$Signature.play()
	yield($Signature, "finished")
	
	# Toca o som de carimbo, simula o carimbo do médico.
	$Stamp.play()
	yield($Stamp, "finished")

	# Toca um som aleatório de "PaperSliding".
	self.play_random_paperslide_sound()

	# Verifica se as respostas do jogador estão corretas.
	var is_player_answers_correct = self.check_answers()

	# Da "spawn" no mini-documento principal, com uma animação de "sliding" de cima para baixo.
	var mini_document = self.document_scene.instance()
	
	# Adiciona o carimbo conforme as respostas do jogador.
	if is_player_answers_correct:
		mini_document.add_accepted_stamp()
		self.saved_people_count += 1
	else:
		mini_document.add_rejected_stamp()
		self.death_people_count += 1
	
	# Ajusta as seções do documento.
	mini_document.adjust_document_visible_sections(self.current_day)
	
	# Centraliza o documento.
	mini_document.transform.origin = Vector2(self.width / 2, 0)
	
	# Torna o documento "arrastável".
	mini_document.connect("clicked", self, "_on_pickable_clicked")
	
	# Adiciona-o a cena.
	$Interactables.add_child(mini_document)

	print("TODO: Game.gd - Gerar um novo paciente e alertar o jogador.")
	print("TODO: Game.gd - Quando um novo paciente for gerado, remover o mini-documento, assim como os demais documentos. (novos serão gerados)")
