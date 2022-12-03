extends Control

# Faz o carregamento da cena do mini-documento principal.
onready var document_scene = preload("res://Source/Scenes/MiniDocument.tscn") 

# A variável pai desta cena.
export(PackedScene) var root_scene

# Indica que este documento pode ser aberto.
var can_open_document = true

# O "ID" atual ativo.
var active_id

# Inicializa o "RNG".
var rng = RandomNumberGenerator.new()

func _ready():
	# Adiciona as opções aos dropdown.
	self.add_dropdown_itens()

# Ajusta os campos visíveis para o jogador.
func adjust_document_visible_sections(current_day, day_multiplier):
	# Preenche o documento com as outras informações não obrigatórias.
	var cards_with_the_info = [
		"ID",
		"HeartRate",
		"Temperature"
	]
	for i in range(0, (current_day / day_multiplier) + 1, 1):
		if i < cards_with_the_info.size():
			for node in self.root_scene.get_node("Cards").get_children():
				if cards_with_the_info[i] in node.name:
					if i == 0:
						$UI/IDSection/PatientName.text = node.patient_name
						$UI/IDSection/PatientAge.text = str(node.patient_age)
						$UI/IDSection/PatientSex.text = node.patient_sex
					elif i == 1:
						$UI/HeartRateSection/PatientBPM.text = "%d" % node.heart_bpm
					elif i == 2:
						$UI/TemperatureSection/PatientTemperature.text = "%.1f°C" % node.temperature
	
	
	# As seções, do documento principal, disponíveis para visualização.
	var available_sections = [
		$UI/IDSection,
		$UI/HeartRateSection,
		$UI/TemperatureSection,
		$UI/VirusSection
	]
	
	# Itera sobre as seções do documento principal.
	for i in range(0, (current_day / day_multiplier) + 1, 1):
		if i < available_sections.size():
			# Torna determinada seção visível.
			available_sections[i].visible = true

# Adiciona as opções aos dropdown.
func add_dropdown_itens():
	# Tipos Sanguíneos.
	for blood_types in ["O+", "A+", "B+", "AB+", "O-", "A-", "B-", "AB-"]:
		$UI/IDSection/PatientBlood.add_item(blood_types)
	# Classificações dos batimentos cardiacos.
	for heart_rate_class in ["Normal", "Taquicardia", "Bradicardia"]:
		$UI/HeartRateSection/PatientBPMClass.add_item(heart_rate_class)
	# Classificação das temperaturas.
	for temp_class in ["Normal", "Estado Febril", "Febre"]:
		$UI/TemperatureSection/PatientTemperatureClass.add_item(temp_class)
	# Os tipos de vírus possíveis no paciente.
	for virus in ["AIDS", "COVID-19", "DENGUE", "HEPATITE", "VARÍOLA"]:
		$UI/VirusSection/PatientVirus.add_item(virus)
	# Se o paciente está com o vírus ou não.
	for condition in ["Sim", "Não"]:
		$UI/VirusSection/PatientHasVirus.add_item(condition)

# Toca um som aleatório de "PaperFlip".
func play_random_paperflip_sound():
	# Randomiza a "Seed" do "RNG".
	self.rng.randomize()
	# Os possíveis sons de "PaperFlip".
	var random_paper_sound = [$PaperFlip1, $PaperFlip2]
	# Escolhe um som aleatório da lista anterior.
	var selected_paper_sound = random_paper_sound[self.rng.randi() % random_paper_sound.size()]
	# Toca o som e aguarda o seu término.
	selected_paper_sound.play()
	yield(selected_paper_sound, "finished")

# Toca um som aleatório de "PaperSliding".
func play_random_paperslide_sound():
	# Randomiza a "Seed" do "RNG".
	self.rng.randomize()
	# Os possíveis sons de "PaperSliding".
	var random_paper_sound = [$PaperSliding1, $PaperSliding2, $PaperSliding3]
	# Escolhe um som aleatório da lista anterior.
	var selected_paper_sound = random_paper_sound[self.rng.randi() % random_paper_sound.size()]
	# Toca o som e aguarda o seu término.
	selected_paper_sound.play()
	yield(selected_paper_sound, "finished")

# Verifica as respostas dos cartões do paciente com a do jogador.
func check_answers():
	# Só funcionará se ainda houver tempo no jogo.
	if not self.root_scene.get_node("Clock").time_up:
		# Verifica se tem algum "ID" para ser verificado.
		if self.active_id != null:
			# Os campos a serem verificados.
			var player_answers = [
				$UI/IDSection/PatientBlood.text,
				$UI/HeartRateSection/PatientBPMClass.text,
				$UI/TemperatureSection/PatientTemperatureClass.text,
				[$UI/VirusSection/PatientVirus.text, $UI/VirusSection/PatientHasVirus.text]
			]
			# As indicação das respostas corretas/erradas.
			var cards_answers = []
			# Itera sobre os cartões do paciente atendido.
			for i in range(self.active_id.cards_held.size()):
				# Extrai os elementos.
				var card = self.active_id.cards_held[i]
				var answer = player_answers[i]
				# Compara as respostas e adiciona em uma lista.
				cards_answers.append(card.is_answer_correct(answer))
			return not false in cards_answers
		
# Esconde o documento (sai dele).
func _on_DocExitButton_pressed():
	# Toca um som aleatório de "PaperFlip".
	self.play_random_paperflip_sound()
	# Esconde o documento.
	self.visible = false

# "Envia" o documento para avaliação.
func _on_DocSendButton_pressed():
	# Toca um som aleatório de "PaperFlip".
	self.play_random_paperflip_sound()
	
	# Indica que este documento não pode ser aberto.
	self.can_open_document = false
	
	# Pega o "ID" atual.
	self.active_id = self.root_scene.root_scene.active_id
	
	# Verifica se há um "ID" atual.
	if self.active_id != null:
		# Para o timer do "ID" atual.
		self.active_id.get_node("DespawnTimer").set_paused(true)
		
		# Inicia o timer. ("avaliação médica".)
		$MedicEvaluation.start()
		
		# Esconde o documento.
		self.visible = false
	else:
		self.can_open_document = true

# Faz a avaliação das respostas do usuário.
func _on_MedicEvaluation_timeout():
	# Inicia a avaliação médica do documento.
	$MedicCall.start()
	
	# Toca o som de assinatura e espera o término da mesma.
	$Signature.play()
	yield($Signature, "finished")
	
	# Toca o som de carimbo e espera o término do mesmo.
	$Stamp.play()
	yield($Stamp, "finished")
	
	# Toca um som aleatório de "PaperSliding".
	self.play_random_paperslide_sound()
	
	# Verifica as respostas dos cartões do paciente com a do jogador.
	var is_player_answers_correct = self.check_answers()
	
	# Instanceia a cena do "mini_document".
	var mini_document = self.document_scene.instance()
	
	# Adiciona um carimbo conforme as respostas do jogador.
	if is_player_answers_correct:
		mini_document.add_accepted_stamp()
		# Aumenta a quantia de pessoas salvas pelo jogador.
		self.root_scene.root_scene.saved_people_count += 1
		# Toca uma animação indicando que o jogador salvou o paciente.
		self.root_scene.root_scene.get_node("Animations").play_saved_animation()
	else:
		mini_document.add_rejected_stamp()
		# Aumenta a quantia de pessoas mortas pelo jogador.
		self.root_scene.root_scene.dead_people_count += 1
		# Toca uma animação indicando que o jogador matou o paciente.
		self.root_scene.root_scene.get_node("Animations").play_dead_animation()
	
	# Ajusta os campos visíveis.
	mini_document.adjust_document_visible_sections(
		self.root_scene.root_scene.current_day,
		self.root_scene.root_scene.day_multiplier
	)
	
	# Preenche o documento com as informações fornecidas pelo jogador.
	mini_document.patient_name = $UI/IDSection/PatientName.text
	mini_document.patient_age = $UI/IDSection/PatientAge.text
	mini_document.patient_sex = $UI/IDSection/PatientSex.text
	mini_document.patient_blood_type = $UI/IDSection/PatientBlood.text
	mini_document.patient_bpm = $UI/HeartRateSection/PatientBPM.text
	mini_document.patient_bpm_class = $UI/HeartRateSection/PatientBPMClass.text
	mini_document.patient_temp = $UI/TemperatureSection/PatientTemperature.text
	mini_document.patient_temp_class = $UI/TemperatureSection/PatientTemperatureClass.text
	mini_document.patient_virus = $UI/VirusSection/PatientVirus.text
	mini_document.patient_has_virus = $UI/VirusSection/PatientHasVirus.text
	mini_document.update_sections()
	
	# Ajusta a posição da documento. (Na faixa de width / 1.5 e width / 3)
	mini_document.transform.origin = Vector2(
		self.rng.randi_range(self.root_scene.width / 1.5, self.root_scene.width / 3),
		-100
	)
	
	# Torna o documento "arrastável".
	mini_document.connect("clicked", self.root_scene.root_scene, "_on_pickable_clicked")
	
	# Adiciona o "mini_document" ao "ID" atual.
	self.active_id.cards_held.append(mini_document)
	
	# Adiciona a cena pai.
	self.root_scene.get_node("Cards").add_child(mini_document)

# Remove os cartões do paciente atual.
func _on_MedicCall_timeout():
	# Para o timer.
	self.active_id.get_node("DespawnTimer").stop()
	# Chama a função que removerá o cartão atual.
	self.active_id.clear_id_show_others()
	# Indica que o documento pode ser aberto.
	self.can_open_document = true
