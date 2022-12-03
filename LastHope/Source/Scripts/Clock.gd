extends Control

# Cria um timer para a cena atual.
var clock_text_timer = Timer.new()

# Cria um timer para a animação do separador do horário.
var clock_sep_timer = Timer.new()

# Indica se o tempo terminou ou não.
export(bool) var time_up = false

# O texto que representa o tempo.
onready var clock_hour = get_node("FrameControl/HorizontalClockContainer/Hour")
# O texto que representa o separador.
onready var clock_sep = get_node("FrameControl/HorizontalClockContainer/Sep")

# Horário de começo do expediente do jogador.
var initial_value = null

# Horário de término do expediente do jogador.
var final_value = null

# Inicializa o "RNG".
var rng = RandomNumberGenerator.new()

# Executado quando a cena for carregada.
func _ready():
	self.restart_clock()

# Reinicia o relógio.
func restart_clock():
	# Randomiza a "Seed" do "RNG".
	self.rng.randomize()
	# Escolhe um horário de começo qualquer.
	self.initial_value = self.rng.randi_range(0, 19)
	# Horário de término será o horário de começo + 4.
	self.final_value = self.initial_value + 4
	
	# Indica que o expediente não terminou.
	self.time_up = false
	
	# Altera o horário exibido no relógio.
	self.clock_hour.text = "%02d" % self.initial_value
	
	# Configura os "Timers".
	self._configure_clock_sep_timer()
	self._configure_clock_text_timer()

# Incrementa o tempo do relógio.
func _inc_clock_time():
	# Incrementa o tempo do relógio em 1 hora.
	var next_hour = int(self.clock_hour.text) + 1
	self.clock_hour.text = "%02d" % next_hour
	
	# Verifica se o tempo chegou a 00:00 e termina a fase.
	if int(self.clock_hour.text) > self.final_value:
		# Impede a exibição do horário "24".
		if self.clock_hour.text == "24":
			self.clock_hour.text = "00"
		# Indica que o expediente terminou.
		self.time_up = true
		# Para a contagem no relógio.
		self.clock_sep_timer.stop()
		self.clock_text_timer.stop()

# Anima a separação do tempo.
func _blink_clock_separator():
	# Faz o separador do texto "piscar".
	self.clock_sep.modulate.a = int(self.clock_sep.modulate.a) ^ 1

# Configura o timer para o separador do tempo.
func _configure_clock_sep_timer():
	# Adiciona o timer a cena.
	self.add_child(self.clock_sep_timer)
	# Tempo de espera até a chamada de outra função.
	self.clock_sep_timer.wait_time = 0.5
	# Executa repetidamente.
	self.clock_sep_timer.one_shot = false
	# Conecta a função "_inc_clock_time" ao timer.
	self.clock_sep_timer.connect("timeout", self, "_blink_clock_separator")
	# Inicia o timer.
	self.clock_sep_timer.start()

# Configura o timer para o texto do tempo.
func _configure_clock_text_timer():
	# Adiciona o timer a cena.
	self.add_child(self.clock_text_timer)
	# Tempo de espera até a chamada de outra função.
	self.clock_text_timer.wait_time = 30.0
	# Executa repetidamente.
	self.clock_text_timer.one_shot = false
	# Conecta a função "_inc_clock_time" ao timer.
	self.clock_text_timer.connect("timeout", self, "_inc_clock_time")
	# Inicia o timer.
	self.clock_text_timer.start()
