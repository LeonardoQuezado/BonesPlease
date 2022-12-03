extends Control

# O cartão que está sendo segurado atualmente.
var held_object = null

# O cartão "ID" que está ativo.
var active_id = null

# O dia atual do jogo.
var current_day = 0

# O multiplicador do dia.
var day_multiplier = 2

# Quantidade de pessoas salvas pelo jogador.
var saved_people_count = 0

# Quantidade de pessoas que não foram atendidas pelo jogador.
var no_reply_people_count = 0

# Quantidade de pessoas mortas pelo jogador.
var dead_people_count = 0

# Indica se o som do relógio pode ser tocado.
var can_clock_play_sound = false

# Indica se o som do hospital pode ser tocado.
var can_play_hospital_sound = false

# Indica se o som do ambiente pode ser tocado.
var can_play_ambience_sound = false

# As combinações dos sons ambientes.
var sounds

# A combinação de som escolhida.
var selected_sounds = null

# Inicializa o "RNG".
var rng = RandomNumberGenerator.new()

# Configura algumas coisas ao iniciar a cena.
func _ready():
	# Atribui esta cena, como cena root, à cena de "Animations".
	$Animations.root_scene = self
	# Atribui esta cena, como cena root, à cena de "Interactables".
	$Interactables.root_scene = self

	# Começa um novo dia.
	self.start_new_day()

func _physics_process(delta):
	# Repete o efeito sonoro do hospital.
	self._repeat_hospital_background_sound()
	
	# Repte o efeito sonoro ambiente.
	self._repeat_ambience_sound()
	
	# Repete o efeito sonoro do relógio.
	self._repeat_clock_ticking_sound()

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

# Reinicia os status do jogador.
func restart_player_status():
	self.saved_people_count = 0
	self.dead_people_count = 0

# "Inicia" o dia/fase atual.
func start_new_day():
	# Aumenta o nível atual em 1.
	self.current_day += 1
	
	# Para os timers de "Document".
	self.stop_medic_timers()
	
	# Indica que o documento pode ser aberto.
	$Interactables/Document.can_open_document = true
	# Esconde o botão da "Checklist".
	$Interactables/Checklist.visible = false
	
	# Verifica se o temporizador está pausado e para-o.
	if $Interactables/PatientTimer.paused:
		$Interactables.continue_patient_timer()
	# Para o timer do "PatientTimer".
	$Interactables.stop_patient_timer()
	
	# Para os timers nos "IDs".
	self.stop_timer_on_ids()
	
	# Limpa os cartões que ficaram na tela.
	self.clear_remaining_cards()
	
	# Reinicia os status do jogador.
	self.restart_player_status()
	
	# Escolhe novos efeitos sonoros de ambiente.
	self._select_new_sounds()
	
	# Reseta as animações.
	$Animations.reset()
	
	# Toca a animação de começo de fase.
	$Animations.play_start_level_animation()
	
	# Reinicia o relógio.
	$Interactables.restart_clock()

# "Termina" o dia/fase atual.
func end_day():
	# Para os timers de "Document".
	self.stop_medic_timers()
	
	# Para os timers nos "IDs".
	self.stop_timer_on_ids()
	
	# Verifica se o temporizador está pausado e para-o.
	if $Interactables/PatientTimer.paused:
		$Interactables.continue_patient_timer()
	# Para o temporizador dos pacientes.
	$Interactables.stop_patient_timer()
	 
	# Limpa os cartões que ficaram na tela.
	self.clear_remaining_cards()
	
	# Para os sons.
	self.can_clock_play_sound = false
	self.can_play_hospital_sound = false
	self.can_play_ambience_sound = false
	
	# Para o som do relógio.
	$Clock_Ticking.stop()
	
	# Para o som do hospital.
	$HospitalBackground.stop()
	
	# Para o som ambiente.
	for sound in self.selected_sounds:
		sound.stop()
	
	# Reseta as animações.
	$Animations.reset()
	
	# Toca a animação de fim de fase.
	$Animations.play_end_level_animation()

# Para os timers de "Document".
func stop_medic_timers():
	$Interactables/Document/MedicCall.stop()
	$Interactables/Document/MedicEvaluation.stop()
	
# Para os timers nos "IDs".
func stop_timer_on_ids():
	for node in $Interactables/Cards.get_children():
		if "ID" in node.name:
			node.get_node("DespawnTimer").stop()

# Limpa os cartões que ficaram na tela.
func clear_remaining_cards():
	for node in $Interactables/Cards.get_children():
		if node is RigidBody2D:
			node.visible = true
			node.queue_free()
	
# Se clicado em algum "ID", mostra os cartões do "ID" clicado.
func _show_patient_on_clicked_card(object):
	# Atribui o "ID" atual como "ID" ativo.
	self.active_id = object
	# Mostra o "Checklist".
	$Interactables/Checklist.visible = true
	# Para o timer do "PatientTimer".
	$Interactables.pause_patient_timer()
	# Esconde os outros "ID".
	for node in $Interactables.get_node("Cards").get_children():
		if node is RigidBody2D:
			if not "FiscalNote" in node.name:
				# Esconde os outros "IDs" menos o "ID" que foi clicado.
				if node != object:
					node.visible = false
					# Desabilita as HitBox.
					node.get_node("HitBox").disabled = true
					# Para o timer.
					node.get_node("DespawnTimer").set_paused(true)
				else:
					# Desconecta esta função do "ID" clicado.
					node.disconnect("clicked", self, "_show_patient_on_clicked_card")
					# Habilita a fução de agarrar o cartão.
					self._on_pickable_clicked(node)
					node.connect("clicked", self, "_on_pickable_clicked")
					# Gera os demais cartões/documentos do paciente (vulgo "ID").
					node.spawn_cards_to_id(self.current_day, self.day_multiplier)

# Faz com que, se clicado em algum cartão, o mesmo acompanha o movimento do mouse,
# representando o "Drag".
func _on_pickable_clicked(object):
	# Agarra o objeto.
	if !self.held_object:
		self.held_object = object
		# Aumenta a escala do objeto agarrado.
		self.held_object.scale = Vector2(1.25, 1.25)
		self.held_object.pickup()

# Faz com que, se solto o cartão, o mesmo deixa de acompanhar o movimento do mouse,
# representando o "Drop".
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		# Solta o objeto.
		if self.held_object and !event.pressed:
				self.held_object.drop()
				self.held_object = null
