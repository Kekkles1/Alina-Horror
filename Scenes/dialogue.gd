extends CanvasLayer
class_name DialogueBox

@onready var name_label: Label = $Panel/NameLabel
@onready var text_label: RichTextLabel = $Panel/TextLabel
@onready var hint_label: Label = $Panel/HintLabel

var lines: Array[String] = []
var index := 0
var active := false

func start_dialogue(dialogue_lines: Array[String], speaker := ""):
	if dialogue_lines.is_empty():
		return

	lines = dialogue_lines
	index = 0
	active = true
	visible = true

	if speaker != "":
		name_label.text = speaker
		name_label.visible = true
	else:
		name_label.visible = false

	_show_line()

func _unhandled_input(event):
	if not active:
		return

	if event.is_action_pressed("ui_accept"):
		index += 1
		if index >= lines.size():
			close()
		else:
			_show_line()

	elif event.is_action_pressed("ui_cancel"):
		close()

func _show_line():
	text_label.clear()
	text_label.add_text(lines[index])
	hint_label.text = "ENTER"

func close():
	active = false
	visible = false
	lines.clear()
	index = 0
