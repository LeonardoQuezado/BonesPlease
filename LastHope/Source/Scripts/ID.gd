extends RigidBody2D

signal clicked

# Se o cartão está sendo segurado.
var held = false

# Exporta a variável "patient_name" (o nome do paciente).
export(String) var patient_name

# Exporta a variável "patient_age" (a idade do paciente).
export(int) var patient_age

# Exporta a variável "patient_blood_type" (o tipo sanguíneo do paciente).
export(String) var patient_blood_type

# Os tipos sanguíneos.
var blood_types = ["O+", "A+", "B+", "AB+", "O-", "A-", "B-", "AB-"]

# Inicializa o "RNG".
var rng = RandomNumberGenerator.new()

# Inicializa o "Directory".
var dir = Directory.new()

# Inicializa o "File".
var txt_file = File.new()

# Escolhe uma imagem e um nome aleatório.
func gen_random_persona():
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
	$CardNineRect/IDControl/PatientSex.text = target_folder[0].capitalize()

# Executada quando a cena é instanciada.
func _ready():
	self.rng.randomize()
	
	# Escolhe um tipo sanguíneo qualquer e exibe-o.
	self.patient_blood_type = self.blood_types[self.rng.randi() % self.blood_types.size()]
	$CardNineRect/IDControl/PatientBlood.text = self.patient_blood_type
	
	# Escolhe uma idade qualquer, entre 20 e 60 anos.
	self.patient_age = self.rng.randi_range(20, 60)
	$CardNineRect/IDControl/PatientAge.text = str(self.patient_age)
	
	# Escolhe uma imagem e um nome aleatório.
	self.gen_random_persona()
	
	# Gera uma validade aleatória para o "ID" do paciente.
	var day = self.rng.randi_range(1, 31)
	var month = self.rng.randi_range(1, 12)
	var year = self.rng.randi_range(0, 22)
	# Atributi a validade ao "ID".
	$CardNineRect/IDControl/PatientDate.text = "%02d/%02d/%02d" % [day, month, year]

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
