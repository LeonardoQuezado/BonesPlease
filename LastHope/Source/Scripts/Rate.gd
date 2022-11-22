extends Sprite

# A largura e comprimento da tela.
var width = 0
var height = 0

# O valor base da velocidade de deslocamento no eixo "X".
var base_x_speed = 5

# O valor base da velocidade de deslocamento no eixo "Y".
var base_y_speed = 50.0

# O valor base da largura da "cauda/rastro"
var base_trail_width = 2

# A velocidade de deslocamento no eixo "X" e "Y".
var x_speed
var y_speed

# O tamanho da "cauda/rastro".
var trail_length

# A "cauda/rastro" associada.
var trail

# O som de "Beep" do monitor.
var beep_sound
# O som dos batimentos cardíacos.
var heartbeat_sound
# O som de estática.
var static_sound
# O som de um "Beep" prolongado.
var long_beep_sound

# Realiza as configurações básicas.
func _ready():
	self.beep_sound = self.get_parent().get_node("MonitorBeep")
	self.heartbeat_sound = self.get_parent().get_node("HeartBeat")
	self.static_sound = self.get_parent().get_node("Static")
	self.long_beep_sound = self.get_parent().get_node("NoBeeps")
	self.trail = self.get_parent().get_node("Trail")
	self.trail_length = self.trail.trail_length
	self.trail.width = self.base_trail_width

# Toca os sons que tem que tocar para simular uma frequência cardíaca.
func _play_sounds():
	self.beep_sound.play()
	self.heartbeat_sound.play()

# Reseta a posição.
func _reset_position():
	self.trail.trail_length = 0
	self._move_to(0, self.height / 2)

# Verifica se o objeto está fora da tela.
func _has_reached_boundaries():
	return self.position.x >= self.width + self.trail_length * 4

# Olha se pode fazer o "beep" do monitor para baixo.
func _can_beep_down():
	# Lado esquerdo da tela.
	var window_left_side = self.width / 3
	
	# "Range" em que o "beep down" pode ser feito.
	var left_min_range = int(window_left_side / self.x_speed) * self.x_speed
	var left_max_range = int((window_left_side + self.x_speed) / self.x_speed) * self.x_speed
	
	# Lado direito da tela.
	var window_right_side = self.width / 1.5
	
	# "Range" em que o "beep down" pode ser feito.
	var right_min_range = int(window_right_side / self.x_speed) * self.x_speed
	var right_max_range = int((window_right_side + self.x_speed) / self.x_speed) * self.x_speed
	
	return (
		left_min_range <= self.position.x and self.position.x <= left_max_range
		or
		right_min_range <= self.position.x and self.position.x <= right_max_range
	)

# Faz o "beep" do monitor para baixo.
func _beep_down():
	self._move_to(self.position.x, self.height / 2 + self.y_speed)

# Olha se pode fazer o "beep" do monitor para cima.
func _can_beep_up():
	# Lado esquerdo da tela.
	var window_left_side = self.width / 3
	
	# "Range" em que o "beep up" pode ser feito.
	var left_min_range = int((window_left_side + self.x_speed) / self.x_speed) * self.x_speed
	var left_max_range = int((window_left_side + (self.x_speed * 2)) / self.x_speed) * self.x_speed
	
	# Lado direito da tela.
	var window_right_side = self.width / 1.5
	
	# "Range" em que o "beep up" pode ser feito.
	var right_min_range = int(window_right_side / self.x_speed) * self.x_speed
	var right_max_range = int((window_right_side + (self.x_speed * 2)) / self.x_speed) * self.x_speed
	
	return (
		left_min_range <= self.position.x and self.position.x <= left_max_range
		or
		right_min_range <= self.position.x and self.position.x <= right_max_range
	)

# Faz o "beep" do monitor para cima.
func _beep_up():
	self._play_sounds()
	self._move_to(self.position.x, self.height / 2 - self.y_speed)

# Retorna a posição original.
func _no_beep():
	# Lado esquerdo da tela.
	var window_left_side = self.width / 3
	
	# "Range" em que o "no beep" pode ser feito.
	var left_min_range = int((window_left_side + (self.x_speed * 2)) / self.x_speed) * self.x_speed
	var left_max_range = int((window_left_side + (self.x_speed * 3)) / self.x_speed) * self.x_speed
	
	# Lado direito da tela.
	var window_right_side = self.width / 1.5
	
	# "Range" em que o "no beep" pode ser feito.
	var right_min_range = int(window_right_side / (self.x_speed * 2)) * self.x_speed
	var right_max_range = int((window_right_side + (self.x_speed * 3)) / self.x_speed) * self.x_speed
	
	return (
		left_min_range <= self.position.x and self.position.x <= left_max_range
		or
		right_min_range <= self.position.x and self.position.x <= right_max_range
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
	# Atribui o valor final a velocidade de deslocamento no eixo "x".
	self.y_speed = sqrt((screen_dimension / multiplier)) * self.base_y_speed	
	# Atualiza o tamanho da "cauda/rastro" baseado no tamanho da tela.
	self.trail.width = sqrt((screen_dimension / multiplier)) * self.base_trail_width

# Fica tocando o som de estática o tempo todo.
func _play_static_sound():
	if self.static_sound.playing == false:
		self.static_sound.play()
		
# Fica tocando um som de "beep" prolongado o tempo todo.
func _play_long_beep_sound():
	if self.long_beep_sound.playing == false:
		self.long_beep_sound.play()

# Executa em cada frame.
func _physics_process(delta):
	# Atualiza a resolução da tela a cada frame.
	self.width = self.get_viewport().size.x
	self.height = self.get_viewport().size.y
	
	# Ajusta o tamanho da "cauda" conforme a largura da janela.
	self.trail_length = sqrt(sqrt(self.width))

	# Atualiza a velocidade de deslocamento no eixo "x".
	self._update_x_speed()
		
	# Verifica se o menu principal está ativo e faz a animação do monitor.
	if get_tree().root.get_child(0).is_menu_active:
		# Para o som de estática.
		self.static_sound.stop()
		
		# Para o som do "Beep" prolongado.
		self.long_beep_sound.stop()

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
	# Toca um "beep" longo e remove a animação dos batimentos cardíacos.
	elif get_tree().root.get_child(0).is_exit_active:
		# Para o som de estática.
		self.static_sound.stop()
		
		# Toca o som do "Beep" prolongado indefinidamente.
		self._play_long_beep_sound()
		
		# Reseta a posição se estiver fora da tela.
		if self._has_reached_boundaries():
			self._reset_position()
		else:
			# Reseta o tamanho da "cauda/rastro" e anda no eixo "x".
			self.trail.trail_length = self.width * 2
			# Anda no eixo "X".
			self._move_x()
	# Toca o som estático sem parar.
	else:
		# Verifica se o som estático está tocando e toca-o.
		self._play_static_sound()
