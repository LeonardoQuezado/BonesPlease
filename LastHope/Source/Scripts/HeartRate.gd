extends RigidBody2D

# Classificação dos batimentos cardíacos:
# 	1. 60 >= x <= 100 : Frequência cardíaca normal. 
#	2. > 100 : Taquicardia (Batimentos acelerados.)
#	3. < 60 : Bradicardia (Batimentos lentos.)

signal clicked

# Se o cartão está sendo segurado.
var held = false

# Exporta o nome do paciente.
export(String) var patient_name

# Exporta os batimentos cardíacos do paciente.
export(int) var heart_bpm

# Cria um RNG.
var rng = RandomNumberGenerator.new()

# Executada quando a cena é instanciada.
func _ready():
	# Gera um número aleatório, entre 40 e 120, e adiciona ao cartão.
	self.rng.randomize()
	self.heart_bpm = self.rng.randi_range(40, 120)
	$UI/HeartRate.text = "%03d" % self.heart_bpm

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)

# Move o cartão se o mesmo for pego.
func _physics_process(_delta):
	# Remove a gravidade.
	gravity_scale = 0
	# Altera o nome do paciente.
	$UI/PatientName.text = self.patient_name
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
