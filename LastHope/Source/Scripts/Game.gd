extends Control

# O cartão que está sendo segurado atualmente.
var held_object = null

# O nome do paciente atual.
var current_patient_name = null

# As dimensões da resolução atual.
var width = 0
var height = 0

func _ready():
	print("TODO: testcardcollision.gd Fazer uma animação ou coisa do tipo do cartão dando 'spawn'.")

	# Ativa a função "clicked" em "_on_pickable_clicked" dos cartões.
	for node in get_tree().get_nodes_in_group("pickable"):
		node.connect("clicked", self, "_on_pickable_clicked")

func _physics_process(delta):
	# Pega as dimensões da resolução atual.
	self.width = self.get_viewport().size.x
	self.height = self.get_viewport().size.y

	# Pega o nome do paciente no cartão ID.
	self.current_patient_name = self.get_node("ID").patient_name
	
	# Altera o nome do paciente nos demais cartões.
	for node in get_tree().get_nodes_in_group("pickable"):
		node.patient_name = self.current_patient_name

# Faz com que, se clicado em algum cartão, o mesmo acompanha o movimento do mouse,
# representando o "Drag".
func _on_pickable_clicked(object):
	if !held_object:
		held_object = object
		held_object.scale = Vector2(1.25, 1.25)
		held_object.pickup()

# Faz com que, se solto o cartão, o mesmo deixa de acompanhar o movimento do mouse,
# representando o "Drop".
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if held_object and !event.pressed:
			held_object.drop()
			held_object = null
