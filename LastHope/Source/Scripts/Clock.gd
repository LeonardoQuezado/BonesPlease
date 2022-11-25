extends Control

# Cria um timer para a cena atual.
var clock_text_timer = Timer.new()

# Cria um timer para a animação do separador do horário.
var clock_sep_timer = Timer.new()

# O texto que representa o tempo.
onready var clock_hour = get_node("FrameControl/HorizontalClockContainer/Hour")
# O texto que representa o separador.
onready var clock_sep = get_node("FrameControl/HorizontalClockContainer/Sep")

# Incrementa o tempo do relógio.
func _inc_clock_time():
	# Incrementa o tempo do relógio em 1 hora.
	self.clock_hour.text = str(int(self.clock_hour.text) + 1)
	
	# Verifica se o tempo chegou a 00:00 e termina a fase.
	if self.clock_hour.text == "24":
		self.clock_hour.text = "00"
		print("TODO: Clock.gd Para o jogo quando chegar em 00")

# Anima a separação do tempo.
func _blink_clock_separator():
	# Faz o separador do texto "piscar".
	self.clock_sep.modulate.a = int(self.clock_sep.modulate.a) ^ 1

# Configura o timer para o separador do tempo.
func _configure_clock_sep_timer():
	# Adiciona o timer a cena.
	self.add_child(self.clock_sep_timer)
	# Tempo de espera até a chamada de outra função.
	self.clock_sep_timer.wait_time = 1.0
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
	self.clock_text_timer.wait_time = 5.0
	# Executa repetidamente.
	self.clock_text_timer.one_shot = false
	# Conecta a função "_inc_clock_time" ao timer.
	self.clock_text_timer.connect("timeout", self, "_inc_clock_time")
	# Inicia o timer.
	self.clock_text_timer.start()

# Executado quando a cena for carregada.
func _ready():
	self._configure_clock_sep_timer()
	self._configure_clock_text_timer()
