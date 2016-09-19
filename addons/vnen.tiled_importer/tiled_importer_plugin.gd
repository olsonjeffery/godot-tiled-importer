tool
extends EditorImportPlugin

const TiledMap = preload("tiled_map.gd")
var dialog = null

func get_name():
	return "org.vnen.tiled_importer"

func get_visible_name():
	return "TileMap from Tiled Editor"

func config(base_control):
	dialog = preload("import_dialog.tscn").instance()
	base_control.add_child(dialog)

func import_dialog(path):

	var meta = null
	if (path != ""):
		meta = ResourceLoader.load_import_metadata(path)

	dialog.configure(self, path, meta)
	dialog.popup_centered()


func import(path, metadata):
	if metadata.get_source_count() != 1:
		return "Invalid number of sources (should be 1)."

	var src = metadata.get_source_path(0)

	var tiled_map = TiledMap.new()

	var options = {
		"embed": metadata.get_option("embed"),
		"rel_path": metadata.get_option("rel_path"),
		"target": path,
	}

	tiled_map.init(src, options)

	var tiled_data = tiled_map.get_data()

	if typeof(tiled_data) == TYPE_STRING:
		# If is string then it's an error message
		return tiled_data

	var dir = Directory.new()
	dir.make_dir_recursive(path.get_base_dir().plus_file(options.rel_path.substr(0, options.rel_path.length() - 1)))

	var err = tiled_map.build()
	if err != "OK":
		return err

	var scene = tiled_map.get_scene()

	var packed_scene = PackedScene.new()
	err = packed_scene.pack(scene)
	if err != OK:
		return "Error packing scene"

	err = ResourceSaver.save(path, packed_scene, ResourceSaver.FLAG_CHANGE_PATH)
	if err != OK:
		return "Error saving scene"

	return "OK... so far..."