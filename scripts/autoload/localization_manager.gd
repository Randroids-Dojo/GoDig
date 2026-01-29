extends Node
## GoDig Localization Manager
##
## Handles translation loading and string lookup for multi-language support.
## Uses Godot's built-in TranslationServer with CSV-based translations.

# ============================================
# SIGNALS
# ============================================

signal language_changed(locale: String)
signal translations_loaded()

# ============================================
# CONSTANTS
# ============================================

## Supported languages with their locale codes
const SUPPORTED_LANGUAGES := {
	"en": "English",
	"es": "Español",
	"fr": "Français",
	"de": "Deutsch",
	"pt": "Português",
	"ja": "日本語",
	"zh": "中文",
	"ko": "한국어",
}

## Default fallback language
const DEFAULT_LOCALE := "en"

## Translation file path
const TRANSLATIONS_PATH := "res://resources/translations/"

# ============================================
# STATE
# ============================================

var current_locale: String = DEFAULT_LOCALE
var _translations_loaded: bool = false

# Translation keys organized by category
var _translation_keys: Dictionary = {}


func _ready() -> void:
	_detect_system_language()
	_load_translations()
	print("[LocalizationManager] Ready with locale: %s" % current_locale)


# ============================================
# LANGUAGE DETECTION
# ============================================

func _detect_system_language() -> void:
	var system_locale := OS.get_locale_language()
	if system_locale in SUPPORTED_LANGUAGES:
		current_locale = system_locale
	else:
		current_locale = DEFAULT_LOCALE


# ============================================
# TRANSLATION LOADING
# ============================================

func _load_translations() -> void:
	# Load translation CSV if it exists
	var translation_file: String = TRANSLATIONS_PATH + "translations.csv"

	if ResourceLoader.exists(translation_file):
		var translation = load(translation_file)
		if translation:
			TranslationServer.add_translation(translation)
			_translations_loaded = true
			translations_loaded.emit()
			print("[LocalizationManager] Loaded translations from CSV")
			return

	# Fall back to individual .po files
	for locale in SUPPORTED_LANGUAGES.keys():
		var po_path: String = TRANSLATIONS_PATH + locale + ".po"
		if ResourceLoader.exists(po_path):
			var translation = load(po_path)
			if translation:
				TranslationServer.add_translation(translation)
				print("[LocalizationManager] Loaded %s translation" % locale)

	_translations_loaded = true
	translations_loaded.emit()


# ============================================
# PUBLIC API
# ============================================

## Get localized string by key
## Returns the key itself if translation not found (for debugging)
func get_string(key: String) -> String:
	return TranslationServer.translate(key)


## Get localized string with placeholder substitution
## Usage: get_string_format("COINS_EARNED", {"amount": 100}) -> "You earned 100 coins!"
func get_string_format(key: String, values: Dictionary) -> String:
	var text := get_string(key)
	for placeholder in values:
		text = text.replace("{%s}" % placeholder, str(values[placeholder]))
	return text


## Get localized string with plural forms
## Usage: get_string_plural("BLOCKS_MINED", count) -> "1 block mined" or "5 blocks mined"
func get_string_plural(key_singular: String, key_plural: String, count: int) -> String:
	if count == 1:
		return get_string_format(key_singular, {"count": count})
	else:
		return get_string_format(key_plural, {"count": count})


## Change the current language
func set_language(locale: String) -> void:
	if locale not in SUPPORTED_LANGUAGES:
		push_warning("[LocalizationManager] Unsupported locale: %s" % locale)
		return

	current_locale = locale
	TranslationServer.set_locale(locale)
	language_changed.emit(locale)
	print("[LocalizationManager] Language changed to: %s" % locale)


## Get current language code
func get_current_locale() -> String:
	return current_locale


## Get current language display name
func get_current_language_name() -> String:
	return SUPPORTED_LANGUAGES.get(current_locale, "Unknown")


## Get all supported languages as dictionary {locale: display_name}
func get_supported_languages() -> Dictionary:
	return SUPPORTED_LANGUAGES.duplicate()


## Check if a specific locale is supported
func is_locale_supported(locale: String) -> bool:
	return locale in SUPPORTED_LANGUAGES


## Get the next language in rotation (for simple language toggle)
func get_next_locale() -> String:
	var locales := SUPPORTED_LANGUAGES.keys()
	var current_index := locales.find(current_locale)
	var next_index := (current_index + 1) % locales.size()
	return locales[next_index]


## Cycle to next language
func cycle_language() -> void:
	set_language(get_next_locale())


# ============================================
# TRANSLATION KEY HELPERS
# ============================================

## Register translation keys for a category (for documentation/tooling)
func register_keys(category: String, keys: Array) -> void:
	_translation_keys[category] = keys


## Get all registered keys for a category
func get_keys_for_category(category: String) -> Array:
	return _translation_keys.get(category, [])


## Get all registered categories
func get_categories() -> Array:
	return _translation_keys.keys()


# ============================================
# COMMON GAME STRINGS
# ============================================

## Item/Ore names
func get_item_name(item_id: String) -> String:
	return get_string("ITEM_%s" % item_id.to_upper())


## Layer names
func get_layer_name(layer_id: String) -> String:
	return get_string("LAYER_%s" % layer_id.to_upper())


## Achievement names
func get_achievement_name(achievement_id: String) -> String:
	return get_string("ACHIEVEMENT_%s_NAME" % achievement_id.to_upper())


## Achievement descriptions
func get_achievement_description(achievement_id: String) -> String:
	return get_string("ACHIEVEMENT_%s_DESC" % achievement_id.to_upper())


## Building names
func get_building_name(building_id: String) -> String:
	return get_string("BUILDING_%s" % building_id.to_upper())


## Tool names
func get_tool_name(tool_id: String) -> String:
	return get_string("TOOL_%s" % tool_id.to_upper())


## Equipment names
func get_equipment_name(equipment_id: String) -> String:
	return get_string("EQUIPMENT_%s" % equipment_id.to_upper())


# ============================================
# NUMBER FORMATTING
# ============================================

## Format a number with locale-appropriate separators
func format_number(value: int) -> String:
	var text := str(value)
	var formatted := ""
	var count := 0

	for i in range(text.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			# Use locale-appropriate separator
			match current_locale:
				"de", "fr", "es", "pt":
					formatted = "." + formatted
				_:
					formatted = "," + formatted
		formatted = text[i] + formatted
		count += 1

	return formatted


## Format currency (coins)
func format_coins(amount: int) -> String:
	return get_string_format("COINS_FORMAT", {"amount": format_number(amount)})


## Format depth
func format_depth(depth: int) -> String:
	return get_string_format("DEPTH_FORMAT", {"depth": format_number(depth)})
