extends Line2D

# O alvo pai.
var target
# Os pontos da reta.
var point
# O caminho do nó do alvo pai.
export(NodePath) var target_path
# A quantia máxima de pontos na reta.
export var trail_length = 0

# Define o alvo pai, através do caminho.
func _ready():
	self.target = get_node(self.target_path)
	
# Executado a cada frame.
func _process(delta):
	# Define a posição e rotação da reta.
	self.global_position = Vector2(0, 0)
	self.global_rotation = 0

	# Adiciona um novo ponto à reta, baseando-se na posição do alvo pai.
	self.point = self.target.global_position
	add_point(self.point)
	
	# Remove os pontos que excedem a contagem de pontos da reta.
	while self.get_point_count() > self.trail_length:
		self.remove_point(0)
