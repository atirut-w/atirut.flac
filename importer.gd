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
	assert(file.get_buffer(4).get_string_from_ascii() == "fLaC", "not a FLAC stream")
	file.endian_swap = true

	var stream := AudioStreamSample.new()

	while true:
		var header := BlockHeader.new(file)
		var start := file.get_position()
		print("Found meta block type %d" % header.block_type)

		match header.block_type:
			BlockHeader.BlockType.STREAMINFO:
				var info := StreamInfo.new(file)
				print(info.channel_count)

		file.seek(start + header.length)
		if header.is_last:
			break

	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], stream)


class BlockHeader:
	var is_last: bool
	var block_type: int
	var length: int

	enum BlockType {
		STREAMINFO,
		PADDING,
		APPLICATION,
		SEEKTABLE,
		VORBIS_COMMENT,
		CUESHEET,
		PICTURE
	}


	func _init(file: File):
		var ilbt := file.get_8()
		is_last = ilbt & 0x80
		block_type = ilbt & 0x7f
		assert(block_type != 127, "invalid FLAC block type")

		length = file.get_16() << 8
		length |= file.get_8()


class StreamInfo:
	var min_block_size: int
	var max_block_size: int
	var min_frame_size: int
	var max_frame_size: int

	var sample_rate: int
	var channel_count: int


	func _init(file: File):
		min_block_size = file.get_16()
		max_block_size = file.get_16()

		min_frame_size = file.get_16() << 8
		min_frame_size |= file.get_8()

		max_frame_size = file.get_16() << 8
		max_frame_size |= file.get_8()

		# God, this is so awful
		sample_rate = file.get_16() << 8
		sample_rate |= file.get_8()
		sample_rate &= 0x000ffff0
		sample_rate >>= 4
		assert(sample_rate > 0, "invalid sample rate")
