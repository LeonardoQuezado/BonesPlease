extends Control

var held_object = null

var width = 0
var height = 0

func _ready():
	print("TODO: testcardcollision.gd Fazer uma animação ou coisa do tipo do cartão dando 'spawn'.")
	for node in get_tree().get_nodes_in_group("pickable"):
		node.connect("clicked", self, "_on_pickable_clicked")

func _physics_process(delta):
	
	self.width = self.get_viewport().size.x
	self.height = self.get_viewport().size.y

func _on_pickable_clicked(object):
	if !held_object:
		held_object = object
		held_object.scale = Vector2(1.25, 1.25)
		held_object.pickup()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if held_object and !event.pressed:
			held_object.drop()
			held_object = null
