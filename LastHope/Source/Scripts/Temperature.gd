extends RigidBody2D

# Classificação temperatura corporal.
# NORMALIDADE: 36°C a 37.2°C
# ESTADO FEBRIL: 37.3°C a 37.7°C
# FEBRE: 37.8°C a 38.5°C

signal clicked

# Se o cartão está sendo segurado.
var held = false

# Exporta o nome do paciente.
export(String) var patient_name

# Exporta a temperatura do paciente.
export(float) var temperature

# Cria um RNG.
var rng = RandomNumberGenerator.new()

# Executada quando a cena é instanciada.
func _ready():
	# Gera um número aleatório, entre 36.0 e 38.5, e adiciona ao cartão.
	self.rng.randomize()
	self.temperature = self.rng.randf_range(36.0, 38.5)
	$UI/PatientTemperature.text = "%.1f°C" % self.temperature
	
	print("TODO: Temperature.gd na cena do jogo, pegar o nome do paciente pelo 'ID'")

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
