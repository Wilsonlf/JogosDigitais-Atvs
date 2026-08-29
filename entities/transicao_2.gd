extends Area2D

@export_file("*.tscn") var proxima_fase: String

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" and proxima_fase != "":
		get_tree().change_scene_to_file(proxima_fase)
