extends Control

# Carrega a cena do cartão do paciente..
onready var id = preload("res://Source/Scenes/ID.tscn")

# Carrega a cena do "FiscalNote".
onready var note_scene = preload("res://Source/Scenes/FiscalNote.tscn")

# A variável pai desta cena.
export(PackedScene) var root_scene

# Inicializa o "RNG".
var rng = RandomNumberGenerator.new()

# Largura da resolução atual da janela.
var width = 0

# Atribui a cena pai aos nós filhos.
func _ready():
	# Atribui a cena pai, como cena root, à cena de "Document".
	$Document.root_scene = self
	# Esconde o document principal.
	$Document.visible = false

# Verifica se o tempo acabou, a cada frame.
func _physics_process(delta):
	# Pega a largura da resolução atual da janela.
	self.width = self.get_viewport().size.x
	
	# Verifica se o tempo acabou.
	if $Clock.time_up:
		# Para o relógio.
		$Clock.time_up = false
		# Termina o dia.
		self.root_scene.end_day()

# Toca um som aleatório de "Bell".
func play_random_bell_sound():
		# Randomiza a "Seed" do "RNG".
	self.rng.randomize()
	# Os possíveis sons de "Bell".
	var random_bell_sound = [$Bell1, $Bell2, $Bell3, $Bell4]
	# Escolhe um som aleatório da lista anterior.
	var selected_bell_sound = random_bell_sound[self.rng.randi() % random_bell_sound.size()]
	# Toca o som e aguarda o seu término.
	selected_bell_sound.play()
	yield(selected_bell_sound, "finished")

# Inicia o timer do "PatientTimer".
func start_patient_timer():
	$PatientTimer.start()

# Continua o timer do "PatientTimer".
func continue_patient_timer():
	$PatientTimer.set_paused(false)

# Pausa o timer do "PatientTimer".
func pause_patient_timer():
	$PatientTimer.set_paused(true)

# Para o timer do "PatientTimer".
func stop_patient_timer():
	$PatientTimer.stop()

# Reinicia o relógio.
func restart_clock():
	$Clock.restart_clock()

# Da "Spawn" em uma nota fiscal, indicando que um paciente não foi atendido.
func spawn_fiscal_note():
	# Toca uma animação avisando que um paciente não foi atendido.
	self.root_scene.get_node("Animations").play_no_reply_animation()
	
	# Toca o som "Printer" e aguarda o término.
	$Printer.play()
	yield($Printer, "finished")
	
	# Toca um som aleatório de "PaperSliding".
	$Document.play_random_paperslide_sound()
	
	# Da "Spawn" em "FiscalNote".
	var instanced_note = self.note_scene.instance()
	# Ajusta a posição de "FiscalNote".
	instanced_note.transform.origin = Vector2(
		self.rng.randi_range(self.width / 1.5, self.width / 3),
		-100
	)
	# Torna o cartão arrastável.
	instanced_note.connect("clicked", self.root_scene, "_on_pickable_clicked")
	# Adiciona a cena instanciada a esta cena.
	$Cards.add_child(instanced_note)

# Mostra o documento principal para preenchimento.
func _on_Checklist_pressed():
	if $Document.can_open_document:
		# Ajusta os campos visíveis para o jogador.
		$Document.adjust_document_visible_sections(
			self.root_scene.current_day,
			self.root_scene.day_multiplier
		)
		# Mostra o documento principal.
		$Document.visible = true
		# Toca um som aleatório de "PaperFlip".
		$Document.play_random_paperflip_sound()

# Mostra o dia atual. (Através de uma animação.)
func _on_Calendar_pressed():
	# Toca a animação do calendário.
	self.root_scene.get_node("Animations").play_calendar_animation()

# Gera um novo paciente e adiciona-o à tela.
func _on_PatientTimer_timeout():
	# Só contabiliza se ainda houver tempo.
	if not $Clock.time_up:
		# Randomiza a "Seed" do "RNG".
		self.rng.randomize()
		
		# Toca um som aleatório de "Bell".
		self.play_random_bell_sound()
		
		# Instanceia a cena "ID".
		var instanced_id = self.id.instance()
		
		# Atualiza a posição do cartão.
		instanced_id.transform.origin = Vector2(
			self.rng.randi_range(self.width / 1.5, self.width / 3),
			-100
		)
		
		# Adiciona esta cena à cena pai do "ID" alvo.
		instanced_id.root_scene = self
		
		# Permite a seleção de um "ID" dos "IDs" disponíveis.
		instanced_id.connect("clicked", self.root_scene, "_show_patient_on_clicked_card")

		# Toca um som aleatório de "PaperSliding".
		$Document.play_random_paperslide_sound()

		# Adiciona a cena instanciada a esta cena.
		$Cards.add_child(instanced_id)
		
		# Escolhe um novo tempo aleatório para o "PatientTimer".
		$PatientTimer.wait_time = self.rng.randi_range(5, 10)
