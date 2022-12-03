extends RigidBody2D

signal clicked

# Se o cartão está sendo segurado.
var held = false

# Os tipos de vírus/doenças que um paciente pode contrair.
var viruses_types = ["AIDS", "COVID-19", "DENGUE", "HEPATITE", "DIABETE"]

# As imagens das doenças.
var virus_images = [
	"res://Source/Images/aids.png",
	"res://Source/Images/covid.png",
	"res://Source/Images/dengue.png",
	"res://Source/Images/figado.png",
	"res://Source/Images/diabete.png"
]

# Indica se o paciente está com o vírus/doença.
var has_virus = false

# Exporta o nome do paciente.
export(String) var patient_name

# Cria um RNG.
var rng = RandomNumberGenerator.new()

# Executada quando a cena é instanciada.
func _ready():
	self.rng.randomize()
	# O índice da doença escolhida.
	var virus_index = self.rng.randi() % self.viruses_types.size()
	# Altera a imagem conforme a doença.
	$UI/Virus.texture = load(self.virus_images[virus_index])
	# Escolhe um tipo de vírus/doença qualquer e exibe-o.
	$UI/PatientVirus.text = self.viruses_types[virus_index]
	# Indica se o paciente está com o vírus/doença.
	self.has_virus = self.rng.randi() % 2 == 0
	$UI/PatientHasVirus.pressed = self.has_virus

# Verifica se a resposta está certa.
func is_answer_correct(patient_virus_info):
	var patient_virus_type = patient_virus_info[0]
	var patient_has_virus = patient_virus_info[1]
	
	if patient_virus_type == $UI/PatientVirus.text:
		if self.has_virus:
			if patient_has_virus == "Sim":
				return true
		else:
			if patient_has_virus == "Não":
				return true
	return false

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
