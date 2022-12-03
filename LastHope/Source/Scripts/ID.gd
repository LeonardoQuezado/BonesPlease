extends RigidBody2D

signal clicked

# Carrega a cena do "Blood".
onready var blood_scene = preload("res://Source/Scenes/Blood.tscn")

# Carrega a cena do "HeartRate".
onready var heartrate_scene = preload("res://Source/Scenes/HeartRate.tscn")

# Carrega a cena da "Temperature".
onready var temperature_scene = preload("res://Source/Scenes/Temperature.tscn")

# Carrega a cena do "Virus".
onready var virus_scene = preload("res://Source/Scenes/Virus.tscn")

# Se o cartão está sendo segurado.
var held = false

# Exporta a variável "patient_name" (o nome do paciente).
export(String) var patient_name

# Exporta a variável "patient_age" (a idade do paciente).
export(int) var patient_age

# Exporta a variável "patient_sex" (o genero do paciente).
export(String) var patient_sex

# Exporta a variável "patient_blood_type" (o tipo sanguíneo do paciente).
export(String) var patient_blood_type

# A variável pai desta cena.
export(PackedScene) var root_scene

# Os tipos sanguíneos.
var blood_types = ["O+", "A+", "B+", "AB+", "O-", "A-", "B-", "AB-"]

# Inicializa o "RNG".
var rng = RandomNumberGenerator.new()

# Inicializa o "Directory".
var dir = Directory.new()

# Inicializa o "File".
var txt_file = File.new()

# Os cartões que o paciente irá apresentar.
var cards_held = []

# Executada quando a cena é instanciada.
func _ready():
	# Randomiza o "Seed" do "RNG".
	self.rng.randomize()

	# Gera um tipo sanguíneo aleatório para o paciente.	
	self.gen_random_blood_type()
	
	# Gera uma idade aleatório para o paciente.
	self.gen_random_age()
	
	# Escolhe uma imagem e um nome aleatório.
	self.gen_random_persona()
	
	# Gera um data de validade aleatória para o paciente.
	self.gen_random_exp_data()
	
	# Gera um tempo limite de duração do cartão.
	self.gen_despawn_time()

# Adiciona N cartões, com base no dia, ao "ID".
func spawn_cards_to_id(current_day, day_multiplier):
	# Os cartões disponíveis à instanciação.
	var available_cards = [
		self.blood_scene,
		self.heartrate_scene,
		self.temperature_scene,
		self.virus_scene
	]
	# Os cartões que PODEM ser instanciados (de acordo com o dia).
	var cards_to_spawn = []
	# Itera sobre a divisão do "current_day" com "day_multiplier".
	for i in range(0, (current_day / day_multiplier) + 1, 1):
		if i < available_cards.size():
			cards_to_spawn.append(available_cards[i])

	# Toca um som aleatório de "PaperSliding".
	self.root_scene.get_node("Document").play_random_paperslide_sound()

	# O cartõa instanciado.
	var instanced_card = null
	# Itera sobre os cartões que podem ser instanciados.
	for card in cards_to_spawn:
		# Instanceia o cartão.
		instanced_card = card.instance()
		# Adiciona o cartão instanciado ao "ID".
		self.cards_held.append(instanced_card)
		# Atualiza a posição do cartão.
		instanced_card.transform.origin = Vector2(
			self.rng.randi_range(self.root_scene.width / 1.5, self.root_scene.width / 3),
			-100
		)
		# Adiciona algumas informações básicas aos cartões.
		if "Blood" in instanced_card.name:
			instanced_card.patient_blood_type = self.patient_blood_type
		instanced_card.patient_name = self.patient_name
		# Permite a seleção de um "ID" dos "IDs" disponíveis.
		instanced_card.connect("clicked", self.root_scene.root_scene, "_on_pickable_clicked")
		# Adiciona a cena instanciada à cena pai.
		self.root_scene.get_node("Cards").add_child(instanced_card)

# Gera um tempo limite de duração do cartão.
func gen_despawn_time():
	# Randomiza o "Seed" do "RNG".
	self.rng.randomize()

	# Gera um tempo aleatório entre 10s e 30s.
	$DespawnTimer.wait_time = self.rng.randi_range(10, 30)

	# Define o valor máximo ao "ProgressBar".
	$CardNineRect/ProgressBar.max_value = $DespawnTimer.wait_time
	
	# Inicia o "DespawnTimer".
	$DespawnTimer.start()

# Atualiza as informações do "ProgressBar".
func update_progress_bar():
	# Atualiza o valor de "ProgressBar" para o tempo restante do "DespawnTimer".
	$CardNineRect/ProgressBar.value = $DespawnTimer.time_left
	
	# Altera a cor da barra de progresso conforme o tempo restante.
	if ($CardNineRect/ProgressBar.max_value * 51) / 100 <= $CardNineRect/ProgressBar.value and $CardNineRect/ProgressBar.value <= ($CardNineRect/ProgressBar.max_value * 80) / 100:
		$CardNineRect/ProgressBar.tint_progress = Color(0, 1, 0)
		$CardNineRect/SpeechBubble/Reaction.texture = load("res://Source/Images/smiling.png")
	if ($CardNineRect/ProgressBar.max_value * 26) / 100 <= $CardNineRect/ProgressBar.value and $CardNineRect/ProgressBar.value <= ($CardNineRect/ProgressBar.max_value * 50) / 100:
		$CardNineRect/ProgressBar.tint_progress = Color(1, 1, 0)
		$CardNineRect/SpeechBubble/Reaction.texture = load("res://Source/Images/neutral.png")
	if ($CardNineRect/ProgressBar.max_value * 0) / 100 <= $CardNineRect/ProgressBar.value and $CardNineRect/ProgressBar.value <= ($CardNineRect/ProgressBar.max_value * 25) / 100:
		$CardNineRect/ProgressBar.tint_progress = Color(1, 0, 0)
		$CardNineRect/SpeechBubble/Reaction.texture = load("res://Source/Images/angry.png")
		
# Gera um tipo sanguíneo aleatório para o paciente.
func gen_random_blood_type():
	# Randomiza o "Seed" do "RNG".
	self.rng.randomize()

	# Escolhe um tipo sanguíneo qualquer e exibe-o.
	self.patient_blood_type = self.blood_types[self.rng.randi() % self.blood_types.size()]
	$CardNineRect/IDControl/PatientBlood.text = self.patient_blood_type

# Gera uma idade aleatório para o paciente.
func gen_random_age():
	# Randomiza o "Seed" do "RNG".
	self.rng.randomize()

	# Escolhe uma idade qualquer, entre 20 e 60 anos.
	self.patient_age = self.rng.randi_range(20, 60)
	$CardNineRect/IDControl/PatientAge.text = str(self.patient_age)

# Gera um data de validade aleatória para o paciente.
func gen_random_exp_data():
	# Randomiza o "Seed" do "RNG".
	self.rng.randomize()

	# Gera uma validade aleatória para o "ID" do paciente.
	var day = self.rng.randi_range(1, 31)
	var month = self.rng.randi_range(1, 12)
	var year = self.rng.randi_range(0, 22)
	# Atributi a validade ao "ID".
	$CardNineRect/IDControl/PatientDate.text = "%02d/%02d/%02d" % [day, month, year]

# Escolhe uma imagem e um nome aleatório.
func gen_random_persona():
	# Randomiza o "Seed" do "RNG".
	self.rng.randomize()

	# Escolhe uma imagem e um nome aleatório.
	self.dir.change_dir("res://Source/Personas/")
	self.dir.list_dir_begin()
	
	# Pega as pastas dentro da pasta raiz.
	var folders = []
	while true:
		var file = self.dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			folders.append(file)
	self.dir.list_dir_end()
	
	# Escolhe uma das pastas contidas na pasta raiz.
	var target_folder = folders[self.rng.randi() % folders.size()]
	
	# Passa para a pasta escolhida e escolhe um nome aleatório.
	self.txt_file.open("res://Source/Personas/%s/%s.txt" % [target_folder, target_folder], File.READ)
	# Transforma o conteúdo do arquivo em uma lista.
	var content = self.txt_file.get_as_text().split("\n")
	self.txt_file.close()
	# Atribui o nome escolhido.
	self.patient_name = content[self.rng.randi() % content.size()]
	$CardNineRect/IDControl/PatientName.text = self.patient_name
	
	# Escolhe uma imagem aleatória.
	self.dir.change_dir("res://Source/Personas/%s/Pictures/" % target_folder)
	self.dir.list_dir_begin()
	
	# Pega as imagens dentro da pasta raiz.
	var pics = []
	while true:
		var pic = self.dir.get_next()
		if pic == "":
			break
		elif not pic.begins_with(".") and not pic.ends_with(".import"):
			pics.append(pic)
	self.dir.list_dir_end()
	
	# Atribui a imagem escolhida.
	$CardNineRect/IDControl/PatientPicture.texture = load(
		"res://Source/Personas/%s/Pictures/%s" % [target_folder, pics[self.rng.randi() % pics.size()]]
	)
	
	# Atribui o gênero escolhido.
	self.patient_sex = target_folder[0].capitalize()
	$CardNineRect/IDControl/PatientSex.text = self.patient_sex

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)

# Move o cartão se o mesmo for pego.
func _physics_process(_delta):
	# Atualiza as informações do "ProgressBar".
	self.update_progress_bar()
	
	# Remove a gravidade.
	gravity_scale = 0
	if held:
		global_transform.origin = get_global_mouse_position()

# Indica que o cartão foi pego.
func pickup():
	if held:
		return
	mode = RigidBody2D.MODE_STATIC
	held = true

# Indica que o cartão foi solto.
func drop(impulse=Vector2.ZERO):
	if held:
		mode = RigidBody2D.MODE_CHARACTER
		apply_central_impulse(impulse)
		held = false

# Remove o "ID" atual, junto com seus cartões e mostra os outros.
func clear_id_show_others():
	# Toca um som aleatório de "PaperSliding".
	self.root_scene.get_node("Document").play_random_paperslide_sound()
	# Remove o cartão, se estiver agarrado.
	self.root_scene.root_scene.held_object = null
	# Remove o nó atual.
	self.queue_free()
	
	# Itera sobre os demais cartões da cena pai.
	for node in self.root_scene.get_node("Cards").get_children():
		if node is RigidBody2D:
			if "ID" in node.name:
				# Torna os cartões visiveis.
				node.visible = true
				# Habilita a HitBox.
				node.get_node("HitBox").disabled = false
				# Continuar o timer.
				node.get_node("DespawnTimer").set_paused(false)
	# Remove os demais cartões do "ID".
	for node in self.cards_held:
		node.queue_free()
	# Esconde o botão da "Checklist".
	self.root_scene.get_node("Checklist").visible = false
	# Continua o timer do "PatientTimer".
	self.root_scene.continue_patient_timer()

# "Paciente não atendido", remove o ID do paciente da tela.
func _on_DespawnTimer_timeout():
	# Só contabiliza se o tempo não estivar acabado.
	if not self.root_scene.get_node("Clock").time_up:
		# Esconde o documento principal se estiver ativo.
		self.root_scene.get_node("Document").visible = false
		# Incrementa a quantia de pessoas que não foram atendidas.
		self.root_scene.root_scene.no_reply_people_count += 1
		# Toca um som aleatório de "PaperSliding".
		self.root_scene.get_node("Document").play_random_paperslide_sound()
		# Remove o cartão, se estiver agarrado.
		self.root_scene.root_scene.held_object = null
		# Remove o nó atual.
		self.queue_free()
		
		# Da "Spawn" em uma nota fiscal, indicando que um paciente não foi atendido.
		self.root_scene.spawn_fiscal_note()
		
		# Itera sobre os demais cartões da cena pai.
		for node in self.root_scene.get_node("Cards").get_children():
			if node is RigidBody2D:
				if "ID" in node.name:
					# Torna os cartões visiveis.
					node.visible = true
					# Habilita a HitBox.
					node.get_node("HitBox").disabled = false
					# Continuar o timer.
					node.get_node("DespawnTimer").set_paused(false)
		# Remove os demais cartões do "ID".
		for node in self.cards_held:
			node.queue_free()
		# Esconde o botão da "Checklist".
		self.root_scene.get_node("Checklist").visible = false
		# Continua o timer do "PatientTimer".
		self.root_scene.continue_patient_timer()
