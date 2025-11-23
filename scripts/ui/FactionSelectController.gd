class_name FactionSelectController
extends Control

signal faction_selected(faction_id: String)

func _ready() -> void:
	$Center/Buttons/KPMGButton.pressed.connect(func(): _on_faction_button_pressed("KPMG"))
	$Center/Buttons/PwCButton.pressed.connect(func(): _on_faction_button_pressed("PWC"))
	$Center/Buttons/EYButton.pressed.connect(func(): _on_faction_button_pressed("EY"))
	$Center/Buttons/DeloitteButton.pressed.connect(func(): _on_faction_button_pressed("DELOITTE"))

func _on_faction_button_pressed(faction_id: String) -> void:
	# TODO (UI & Input Agent): Add transition effects.
	faction_selected.emit(faction_id)
