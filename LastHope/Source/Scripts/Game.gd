extends Control

# Faz o carregamento prévio da cena do menu principal.
onready var menu_scene = preload("res://Source/Scenes/Menu.tscn")

# Faz o carregamento da cena do ID do paciente.
onready var id_scene = preload("res://Source/Scenes/ID.tscn")

# Faz o carregamento da cena do mini-documento principal.
onready var document_scene = preload("res://Source/Scenes/Document.tscn") 

# Faz o carregamento da cena do documento do tipo sanguineo.
onready var blood_scene = preload("res://Source/Scenes/Blood.tscn")

# Faz o carregamento da cena do documento dos batimentos cardiacos.
onready var heartrate_scene = preload("res://Source/Scenes/HeartRate.tscn")

# Faz o carregamento da cena do documento da temperatura.
onready var temperature_scene = preload("res://Source/Scenes/Temperature.tscn")

# Faz o carregamento da cena do documento do virus.
onready var virus_scene = preload("res://Source/Scenes/Virus.tscn")

# Faz o carregamento do "Dropdown" do tipo sanguineo.
onready var blood_dropdown = $DocumentFade/UI/IDSection/PatientBlood

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
var current_day = 18

# Indica o multiplicador de fase, os divisores de tal valor adicionarão novos conteúdos ao jogo.
var day_multiplier = 2

# Quantidade de pessoas salvas.
var saved_people_count = 0

# Quantidade de pessoas mortas.
var death_people_count = 0

# Indica se o documento principal pode ser aberto/preenchido.
var can_open_main_document = false

# As combinações dos sons ambientes.
var sounds

# A combinação de som escolhida.
var selected_sounds = null

# O randomizer.
var rng = RandomNumberGenerator.new()

func _ready():
	print("TODO: Game.gd Arrumar o tempo de cada fase.")
	print("TODO: Game.gd Arrumar o dia atual e/ou o multiplicador de dia quando terminar o debug.")
	print("TODO: Game.gd Botar o manual em um dos cantos (ajuda)")

	# Adiciona as opções aos dropdown.
	self.add_dropdown_itens()
	
	# Toca a animação de novo dia.
	self.begin_new_day()

# Adiciona as opções aos dropdown.
func add_dropdown_itens():
	# Tipos Sanguíneos.
	for blood_types in ["O+", "A+", "B+", "AB+", "O-", "A-", "B-", "AB-"]:
		self.blood_dropdown.add_item(blood_types)
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
	if !self.held_object:
		self.held_object = object
		self.held_object.scale = Vector2(1.25, 1.25)
		self.held_object.pickup()

# Faz com que, se solto o cartão, o mesmo deixa de acompanhar o movimento do mouse,
# representando o "Drop".
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if self.held_object and !event.pressed:
			self.held_object.drop()
			self.held_object = null

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

# Toca um som aleatório de "Bell".
func play_random_bell_sound():
	# Toca um som de "Bell" qualquer.
	var random_bell_sound = [$Bell1, $Bell2, $Bell3, $Bell4]
	var selected_bell_sound = random_bell_sound[self.rng.randi() % random_bell_sound.size()]
	selected_bell_sound.play()
	yield(selected_bell_sound, "finished")

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
			$DocumentFade/UI/IDSection/PatientBlood.text,
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
			
			# Adiciona a resposta a uma outra lista.
			cards_answers.append(card.is_answer_correct(answer))
		
		# Retorna "True" se não houver "False" nas respostas, retorna "False" caso contrário.
		return not false in cards_answers

# Aciona o "Timer" do paciente.
func start_patient_timer():
	# O "Timer" não está ativo.
	if not $PatientTimer.time_left > 0:
		$PatientTimer.start()

# Para o "Timer" do paciente.
func stop_patient_timer():
	# O "Timer" está ativo.
	$PatientTimer.stop()

# Altera as informações dos cartões/documentos dos pacientes.
func respawn_cards():
	# Destroi os cartões anteriores.
	self.destroy_cards()
	
	# Atualiza a seed do 'RNG'.
	self.rng.randomize()
	
	# Escolhe um tempo aleatório para atender aos pacientes.
	$PatientTimer.wait_time = self.rng.randi_range(10, 30)
	
	# Solta o documento, se estiver segurando algum.
	if self.held_object:
		self.held_object.drop()
		self.held_object = null
	
	# Indica que pode abrir/preencher o documento principal.
	self.can_open_main_document = true
	
	# Toca um som aleatório de sino, indicando que um novo paciente chegou.
	self.play_random_bell_sound()
	
	# Iniciar o timer do paciente, quando acabar, um novo paciente será gerado.
	self.start_patient_timer()
	
	# Ajusta os cartões a serem disponibilizados conforme o nível da fase.
	var cards_to_spawn = [self.id_scene]
	# Os cartões disponíves a instanciação.
	var available_cards = [
		self.blood_scene,
		self.heartrate_scene,
		self.temperature_scene,
		self.virus_scene
	]
	
	# Itera sobre a divisão do "current_day" com "day_multiplier".
	for i in range(0, (self.current_day / self.day_multiplier) + 1, 1):
		if i < available_cards.size():
			# Adiciona os cartões de índice 0 .. n conforme o dia.
			cards_to_spawn.append(available_cards[i])
	
	# Toca um som aleatório de "PaperSliding".
	self.play_random_paperslide_sound()

	# Itera sobre todos os documentos a serem instanciados, conforme o nível da fase.
	for card in cards_to_spawn:
		# Instanceia a cena.
		var instanced_card = card.instance()
	
		# Ajusta a posição da cena instanciada. (Na faixa de width / 1.5 e width / 3)
		instanced_card.transform.origin = Vector2(
			self.rng.randi_range(self.width / 1.5, self.width / 3),
			-100
		)
		
		# Torna o documento "arrastável".
		instanced_card.connect("clicked", self, "_on_pickable_clicked")
	
		# Adiciona-o a cena.
		$Interactables.add_child(instanced_card)

func destroy_cards():
	# Toca um som aleatório de "PaperSliding".
	self.play_random_paperslide_sound()

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
	
	# Para os "Timers" dos pacientes.
	self.stop_patient_timer()
	$DocumentFade/MedicCall.stop()
	
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
	# Só funciona quando o documento principal poder ser aberto/preenchido.
	if self.can_open_main_document:
		# Toca um som aleatório de "PaperFlip".
		self.play_random_paperflip_sound()
	
		# Mostra o documento.
		$DocumentFade.visible = true
		
		# Preenche o documento com as outras informações não obrigatórias.
		var cards_with_the_info = [
			"ID",
			"HeartRate",
			"Temperature"
		]
		for i in range(0, (self.current_day / self.day_multiplier) + 1, 1):
			if i < cards_with_the_info.size():
				for node in $Interactables.get_children():
					if cards_with_the_info[i] in node.name:
						if i == 0:
							$DocumentFade/UI/IDSection/PatientName.text = node.patient_name
							$DocumentFade/UI/IDSection/PatientAge.text = str(node.patient_age)
							$DocumentFade/UI/IDSection/PatientSex.text = node.patient_sex
						elif i == 1:
							$DocumentFade/UI/HeartRateSection/PatientBPM.text = "%d" % node.heart_bpm
						elif i == 2:
							$DocumentFade/UI/TemperatureSection/PatientTemperature.text = "%.1f°C" % node.temperature
		
		print("TODO: Game.gd - _on_CheckList_pressed() Destacar os campos a serem preenchidos.")
		
		# As seções, do documento principal, disponíveis para visualização.
		var available_sections = [
			$DocumentFade/UI/IDSection,
			$DocumentFade/UI/HeartRateSection,
			$DocumentFade/UI/TemperatureSection,
			$DocumentFade/UI/VirusSection
		]
		
		# Itera sobre as seções do documento principal.
		for i in range(0, (self.current_day / self.day_multiplier) + 1, 1):
			if i < available_sections.size():
				# Torna determinada seção visível.
				available_sections[i].visible = true

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

	# Indica que o documento principal não poder ser aberto/preenchido.
	self.can_open_main_document = false

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
	# Para os "Timers" do paciente.
	self.stop_patient_timer()
	$DocumentFade/MedicCall.stop()
	
	# Inica o "Timer" do MedicCall (chamada forçada de outro paciente.)
	$DocumentFade/MedicCall.start()
	
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
	mini_document.adjust_document_visible_sections(self.current_day, self.day_multiplier)
	
	# Ajusta a posição da documento. (Na faixa de width / 1.5 e width / 3)
	mini_document.transform.origin = Vector2(
		self.rng.randi_range(self.width / 1.5, self.width / 3),
		-100
	)
	
	# Torna o documento "arrastável".
	mini_document.connect("clicked", self, "_on_pickable_clicked")
	
	# Adiciona-o a cena.
	$Interactables.add_child(mini_document)

# Chama um novo paciente quando o tempo acabar.
func _on_PatientTimer_timeout():
	# Um documento foi enviado para avaliação, não DEVE ser gerado um novo paciente.
	if self.can_open_main_document:
		# Caso o documento principal esteja aberto, o mesmo é fechado a força.
		if $DocumentFade.visible:
			$DocumentFade.visible = false
		
		# Aumenta a contagem de mortes (não atendeu o paciente).
		self.death_people_count += 1
		
		# Gera um novo paciente.
		self.respawn_cards()
	else:
		self.stop_patient_timer()

# Chama um novo paciente (chamada forçada, feita pelo médico).
func _on_MedicCall_timeout():
	self.respawn_cards()
