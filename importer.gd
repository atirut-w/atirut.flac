tool
extends EditorImportPlugin


enum Presets {}


func get_importer_name() -> String:
    return "atirut.flac"


func get_visible_name() -> String:
    return "FLAC Audio"


func get_recognized_extensions() -> Array:
    return ["flac"]


func get_save_extension() -> String:
    return "sample"


func get_resource_type() -> String:
    return "AudioStreamSample"


func get_preset_count() -> int:
    return Presets.size()


func get_preset_name(preset: int) -> String:
    match preset:
        _:
            return "Unknown"


func get_import_options(preset: int) -> Array:
    match preset:
        _:
            return []


func get_option_visibility(option: String, options: Dictionary) -> bool:
    return true


func import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array, gen_files: Array) -> int:
    var file := File.new()
    assert(file.open(source_file, File.READ) == OK, "failed to open %s" % source_file)
    
    var stream := AudioStreamSample.new()

    return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], stream)
