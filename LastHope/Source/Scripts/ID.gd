extends Control

# Se o mouse está acima do "cartão".
var hover = false

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

func _notification(what):
	match what:
		# Caso o mouse saia da janela do jogo, o mesmo não
		# deixará que o usuário arraste o "cartão".
		MainLoop.NOTIFICATION_WM_MOUSE_EXIT:
			self.hover = false

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
	
# Called when the node enters the scene tree for the first time.
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

# Move, caso o mouse esteja acima do "cartão" e com o botão esquerdo
# pressionado, o "cartão" para a posição do mouse.
func _physics_process(delta):
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
