@tool extends EditorPlugin


const LINE_NUMBER_GUTTER_INDEX = 2

var script_editor: ScriptEditor = EditorInterface.get_script_editor()
var code_editor: CodeEdit


func _enter_tree() -> void:
	script_editor.editor_script_changed.connect(_on_script_editor_editor_script_changed)


func _exit_tree() -> void:
	pass # TODO If possible, find out how to resore the custom draw to the original function
	#for editor in script_editor.get_open_script_editors():
		#var base_editor := editor.get_base_editor()
		#if base_editor is CodeEdit:
			#base_editor.set_gutter_custom_draw(LINE_NUMBER_GUTTER_INDEX, <original_draw_function>)


func _process(_delta: float) -> void:
	if code_editor == null:
		return

	for line in code_editor.get_line_count():
		const CARET_INDEX := 0
		var caret := code_editor.get_caret_line(CARET_INDEX)
		code_editor.set_line_gutter_text(line, LINE_NUMBER_GUTTER_INDEX, str(line - caret))

		if code_editor.get_line_gutter_item_color(line, LINE_NUMBER_GUTTER_INDEX) == Color.WHITE:
			var font_color := code_editor.get_theme_color(&"line_number_color", &"CodeEdit")
			code_editor.set_line_gutter_item_color(line, LINE_NUMBER_GUTTER_INDEX, font_color)


# Super good name B^)
func _on_script_editor_editor_script_changed(_script: Script) -> void:
	var base_editor := script_editor.get_current_editor().get_base_editor()
	if not base_editor is CodeEdit:
		return

	code_editor = base_editor
	code_editor.set_gutter_type(LINE_NUMBER_GUTTER_INDEX, TextEdit.GUTTER_TYPE_STRING)
