extends Control

# Classificação dos batimentos cardíacos:
# 	1. 60 >= x <= 100 : Frequência cardíaca normal. 
#	2. > 100 : Taquicardia (Batimentos acelerados.)
#	3. < 60 : Bradicardia (Batimentos lentos.)

# Se o mouse está acima do "cartão".
var hover = false

# Exporta a variável "patient_name" (o nome do paciente).
export(String) var patient_name

# Exporta a variável "heart_bpm" (o "BPM" do paciente).
export(int) var heart_bpm

# Inicializa o "RNG".
var rng = RandomNumberGenerator.new()

# Sempre que esta cena, do "cartão", for instanciada,
# valores aleatórios para o "BPM" são gerados.
func _ready():
	# Gera um valor aleatório, entre 40 e 120, para os batimentos cardíacos.
	self.rng.randomize()
	self.heart_bpm = self.rng.randi_range(40, 120)
	# Altera o conteúdo do texto "HeartRate", incluindo sempre um zero à esquerda
	# se o número escolhido (aleatoriamente) for menor que 100.
	$CardNineRect/CardControl/HeartRate.text = "%03d" % self.heart_bpm

	print("TODO: HeartRate.gd na cena do jogo, pegar o nome do paciente pelo 'ID'")

func _notification(what):
	match what:
		# Caso o mouse saia da janela do jogo, o mesmo não
		# deixará que o usuário arraste o "cartão".
		MainLoop.NOTIFICATION_WM_MOUSE_EXIT:
			self.hover = false

# Move, caso o mouse esteja acima do "cartão" e com o botão esquerdo
# pressionado, o "cartão" para a posição do mouse.
func _physics_process(delta):
	# Altera o texto de "PatientName", garantindo que o nome estará correto.
	$CardNineRect/CardControl/PatientName.text = self.patient_name
	
	# Move o "cartão" para a posição do mouse.
	if self.hover and Input.is_action_pressed("click"):
		$CardNineRect.set_position(
			$CardNineRect.rect_global_position.linear_interpolate(
				self.get_global_mouse_position(),
				delta * 6.0
			)
		)

# Altera o valor de "hover" indicando que o "cartão" pode ser arrastando
# quando o mouse entrar na região do "cartão". 
func _on_CardNineRect_mouse_entered():
	self.hover = true

# Altera o valor de "hover" indicando que o "cartão" pode ser arrastando
# quando o mouse entrar na região do "cartão". 
func _on_CardNineRect_mouse_exited():
	self.hover = false
