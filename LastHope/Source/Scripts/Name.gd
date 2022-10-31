extends Control

# O nome do usuário.
export var user_name = ""

# O nó responsável pelo "NameEdit".
onready var name_edit = get_node("HorizontalNameContainer/VerticalNameContainer/NameEdit")

# O nó responsável pelo "HistoryLabel".
onready var history_label = get_node("HistoryControl/VerticalHistoryContainer/HistoryLabelTop")

# O nó responsável pelo botão de "Confirm".
onready var confirm_button = get_node("HorizontalNameContainer/VerticalNameContainer/Confirm")

# O nó responsável pela animação.
onready var animation_player = get_node("NameCanvas/AnimationPlayer")

# Indica se algum texto foi inserido pela primeira vez.
var has_text = false

# Expressão regular, aceita somente letras minúsculas e maiúsculas.
var regex = RegEx.new()

# Executada quando o nó for iniciado/instanciado.
func _ready():
	# Toca a animação de "Fade-In".
	self.animation_player.play("FADE_IN")
	# Espera a animação terminar.
	yield(self.animation_player, "animation_finished")
	# Define o RegEx.
	self.regex.compile("^[a-zA-Z]+$")
	# Altera o foco ao texto de entrada.
	self.name_edit.grab_focus()

# Executado quando algum texto é alterado.
func _on_NameEdit_text_changed(new_text):
	# Verifica se o texto inserido pelo usuário é válido.
	# Isto é, possui somente letras minúsculas ou maiúsculas.
	if self.regex.search(new_text) != null:
		# Altera o texto caso esteja de acordo.
		self.name_edit.text = new_text
		# Indica que tem texto.
		self.has_text = true
	else:
		# Limpa todo o texto caso contrário.
		self.name_edit.text = ""
		# Indica que não tem nenhum texto.
		self.has_text = false
	# Altera a posição do "Caret" conforme o texto é alterado.
	self.name_edit.caret_position = len(self.name_edit.text)

# Executado a cada frame.
func _physics_process(delta):
	# Altera a visibilidade do botão "Confirm" conforme a existência de texto no "NameEdit".
	self.confirm_button.visible = self.has_text

# Executado quando o botão "Confirmar" for pressionado.
func _on_Confirm_pressed():
	# Toca a animação de "Fade Out", removendo a entrada de texto.
	self.animation_player.play("FADE_OUT")
	# Espera a animação de "Fade Out" terminar.
	yield(self.animation_player, "animation_finished")
	
	# Altera e armazena o nome do usuário.
	self.user_name = self.name_edit.text
	
	# Altera o texto da história.
	self.history_label.text = self.user_name + ", você é o único capaz de salvá-los."
	
	# Toca a animação de "Fade In", mostrando a história.
	self.animation_player.play("HISTORY_ANIM")
	yield(self.animation_player, "animation_finished")
	
	# Troca para a cena do jogo principal.
	self.get_tree().change_scene("res://Source/Scenes/Tutorial.tscn")
	
	# Toca a animação de "Fade In" da história.
	print("TODO: Name.gd dps do static o tutorial comeca")
	print("TODO: Fazer a ambientacao do jogo/ pensei em botar o som de um ventilador cof five nights cof")
