@tool extends EditorPlugin


const LINE_NUMBER_GUTTER_INDEX = 2

var script_editor: ScriptEditor = EditorInterface.get_script_editor()
var code_editor: CodeEdit
var font_color: Color


func _enter_tree() -> void:
	script_editor.editor_script_changed.connect(_on_script_editor_editor_script_changed)


func _exit_tree() -> void:
	pass # TODO If possible, find out how to resore the custom draw to the original function
	#for editor in script_editor.get_open_script_editors():
		#var base_editor := editor.get_base_editor()
		#if base_editor is CodeEdit:
			#base_editor.set_gutter_custom_draw(LINE_NUMBER_GUTTER_INDEX, <original_draw_function>)


func get_zoom(editor_index: int) -> int:
	# Can't staticly type this, because CodeTextEditor isn't exposed to the API
	var code_text_editor := code_editor.get_parent()
	var hbox: HBoxContainer = code_text_editor.get_child(1)
	var menu_button: MenuButton = hbox.get_child(5)
	return int(menu_button.text.trim_suffix(" %"))


func draw_line_number(line: int, gutter: int, area: Rect2) -> void:
	var font := code_editor.get_theme_font(&"font", &"CodeEdit")
	const MARGIN := 1
	var font_size := floori(EditorInterface.get_editor_settings().get_setting(
			"interface/editor/code_font_size") * 2 * get_zoom(0) / 100.0) - MARGIN

	var pos := area.position
	pos.y += area.size.y - (area.size.y - font_size) / 2 # Switch from bottom-left to centered
	#pos.y += lerpf(font_size, area.size.y, 0.5)
	var width := area.size.x

	# TODO Handle multi-caret support
	const CARET_INDEX := 0
	var caret := code_editor.get_caret_line(CARET_INDEX)
	var text := str(line - caret)

	# Drawing through the font to avoid error messages about drawing only being allowed in _draw()
	font.draw_string(code_editor.get_canvas_item(), pos, text,
			HORIZONTAL_ALIGNMENT_RIGHT, width, font_size, font_color)


# Super good name B^)
func _on_script_editor_editor_script_changed(_script: Script) -> void:
	var base_editor := script_editor.get_current_editor().get_base_editor()
	if not base_editor is CodeEdit:
		return

	code_editor = base_editor

	# Normally, both colors are used, primarily the line gutter color.
	# IDK the logic behind which lines are colored what, so I'll stick to line gutter color for now
	font_color = code_editor.get_line_gutter_item_color(0, LINE_NUMBER_GUTTER_INDEX)
	#font_color = code_editor.get_theme_color(&"line_number_color", &"CodeEdit")

	code_editor.set_gutter_custom_draw(LINE_NUMBER_GUTTER_INDEX, draw_line_number)
