extends RigidBody2D

signal clicked

# Se o cartão está sendo segurado.
var held = false

# Exporta o nome do paciente.
export(String) var patient_name

# Exporta a idade do paciente.
export(int) var patient_age

# Exporta o sexo do paciente.
export(String) var patient_sex

# Exporta o tipo sanguineo do paciente.
export(String) var patient_blood_type

# Exporta os batimentos cardiacos do paciente.
export(int) var patient_bpm

# Exporta a temperatura do paciente.
export(float) var patient_temp

# Exporta a doença do paciente.
export(String) var patient_virus

# Exporta se o paciente tem a doença.
export(bool) var patient_has_virus

# Inicializa o "RNG".
var rng = RandomNumberGenerator.new()

func _ready():
	print("TODO: Document.gd Preencher esse documento também.")

# Ajusta o documento conforme a fase atual.
func adjust_document_visible_sections(current_day, day_multiplier):	
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

# Escolhe um "lugar aleatório" para carimbar.
func select_random_stamp():
	# Randomiza a seed do "RNG".
	self.rng.randomize()

	# Coleta todos os "Stamps" disponíveis para uso.
	var available_stamps = []
	for node in $UI.get_children():
		if "Stamp" in node.name:
			available_stamps.append(node)
	# Retorna o "Stamp" selecionado.
	return available_stamps[self.rng.randi() % available_stamps.size()]

# Adiciona o carimbo de "Aceito".
func add_accepted_stamp():
	var selected_stamp = self.select_random_stamp()
	selected_stamp.texture = load("res://Source/Images/ApprovedStamp.png")

# Adiciona o carimbo de "Rejeitado".
func add_rejected_stamp():
	var selected_stamp = self.select_random_stamp()
	selected_stamp.texture = load("res://Source/Images/RejectedStamp.png")

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)

# Move o cartão se o mesmo for pego.
func _physics_process(_delta):
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
