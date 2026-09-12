extends Camera2D

var jogador: Node2D = null

func _ready() -> void:
	jogar_alvo()

func _physics_process(_delta: float) -> void:
	if jogador == null:
		jogar_alvo()
		return

	global_position = jogador.global_position

func jogar_alvo() -> void:
	var alvo = get_tree().get_first_node_in_group("player")
	if alvo != null:
		jogador = alvo
