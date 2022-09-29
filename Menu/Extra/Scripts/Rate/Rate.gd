extends Sprite

# A largura e comprimento da tela.
var width = 0
var height = 0

# O valor base da velocidade de deslocamento.
var base_x_speed = 5

# A velocidade de deslocamento no eixo "X" e "Y".
var x_speed
var y_speed = 50.0

# O tamanho da "cauda/rastro".
var trail_length

# A "cauda/rastro" associada.
var trail

# Realiza as configurações básicas.
func _ready():
	self.trail = self.get_parent().get_node("Trail")
	self.trail_length = self.trail.trail_length

# Reseta a posição.
func _reset_position():
	self.trail.trail_length = 0
	self._move_to(0, self.height / 2)

# Verifica se o objeto está fora da tela.
func _has_reached_boundaries():
	return self.position.x >= self.width + self.trail_length * 4

# Olha se pode fazer o "beep" do monitor para baixo.
func _can_beep_down():
	return (
		round(self.width / 3) <= self.position.x and self.position.x <= round(self.width / 3 + self.x_speed)
		or
		round(self.width / 1.5) <= self.position.x and self.position.x <= round(self.width / 1.5 + self.x_speed)
		)

# Faz o "beep" do monitor para baixo.
func _beep_down():
	self._move_to(self.position.x, self.height / 2 + self.y_speed)

# Olha se pode fazer o "beep" do monitor para cima.
func _can_beep_up():
	return (
		round(self.width / 3 + self.x_speed) <= self.position.x and self.position.x <= round(self.width / 3 + self.x_speed * 2)
		or
		round(self.width / 1.5 + self.x_speed) <= self.position.x and self.position.x <= round(self.width / 1.5 + self.x_speed * 2)
		)

# Faz o "beep" do monitor para cima.
func _beep_up():
	self._move_to(self.position.x, self.height / 2 - self.y_speed)

# Retorna a posição original.
func _no_beep():
	return (
		round(self.width / 3 + self.x_speed * 2) <= self.position.x and self.position.x <= round(self.width / 3 + self.x_speed * 3)
		or
		round(self.width / 1.5 + self.x_speed * 2) <= self.position.x and self.position.x <= round(self.width / 1.5 + self.x_speed * 3)
		)

# Retorna a posição original.
func _beep_origin():
	self._move_to(self.position.x, self.height / 2)

# Move o objeto para as coordenadas "position_x" e "position_y".
func _move_to(position_x, position_y):
	self.global_position = Vector2(position_x, position_y)

# Se movimenta no eixo "X" em "x_speed" unidades.
func _move_x():
	self.position.x += self.x_speed

# Atualiza a velocidade de deslocamento no eixo "x".
func _update_x_speed():
	# A soma da largura e comprimento da tela.
	var screen_dimension = self.width + self.height
	# A quantidade de números.
	var num_dim = str(screen_dimension).length()
	# O multiplicador baseado no tamanho da tela.
	var multiplier = pow(10, num_dim - 1)
	# Atribui o valor final a velocidade de deslocamento no eixo "x".
	self.x_speed = sqrt((screen_dimension / multiplier)) * self.base_x_speed
	
	print(self.x_speed)

# Executa em cada frame.
func _process(delta):
	# Atualiza a resolução da tela a cada frame.
	self.width = self.get_viewport().size.x
	self.height = self.get_viewport().size.y
	
	# Atualiza a velocidade de deslocamento no eixo "x".
	self._update_x_speed()

	# Reseta a posição se estiver fora da tela.
	if self._has_reached_boundaries():
		self._reset_position()
	else:
		# Faz o "beep" na animação.
		if self._can_beep_down():
			self._beep_down()
		elif self._can_beep_up():
			self._beep_up()
		elif self._no_beep():
			self._beep_origin()
		else:
			# Reseta o tamanho da "cauda/rastro" e anda no eixo "x".
			self.trail.trail_length = self.trail_length
		self._move_x()
