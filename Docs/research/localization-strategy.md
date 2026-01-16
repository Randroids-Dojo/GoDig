# Localization Strategy Research

## Sources
- [Godot Localization Docs](https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html)
- [Mobile Game Localization Best Practices](https://www.gamedeveloper.com/business/mobile-game-localization)

## Priority Markets

### Tier 1 (Launch)
| Language | Market Size | Notes |
|----------|-------------|-------|
| English | Global | Base language |
| Spanish | Large mobile market | Latin America + Spain |
| Portuguese | Brazil is huge | Brazilian Portuguese |

### Tier 2 (v1.0)
| Language | Market Size | Notes |
|----------|-------------|-------|
| French | Europe, Africa | |
| German | Strong gaming market | |
| Japanese | Mobile gaming culture | |
| Korean | Competitive market | |
| Chinese (Simplified) | Massive market | Requires separate build |

### Tier 3 (v1.1+)
- Italian, Russian, Polish, Turkish, Thai, Indonesian

## Godot Localization Setup

### Translation Files
```
localization/
├── en.csv          # English (base)
├── es.csv          # Spanish
├── pt_BR.csv       # Portuguese (Brazil)
└── ... 
```

### CSV Format
```csv
keys,en,es,pt_BR
MENU_PLAY,Play,Jugar,Jogar
MENU_SETTINGS,Settings,Configuración,Configurações
HUD_DEPTH,Depth: %dm,Profundidad: %dm,Profundidade: %dm
ITEM_COAL,Coal,Carbón,Carvão
```

### In-Code Usage
```gdscript
# Using translation key
$Label.text = tr("MENU_PLAY")

# With formatting
$Label.text = tr("HUD_DEPTH") % [current_depth]
```

## Design for Localization

### Text Expansion
Different languages need different space:
| Language | Expansion vs English |
|----------|---------------------|
| German | +30% |
| French | +20% |
| Spanish | +25% |
| Japanese | -10% (but taller) |
| Chinese | -30% (but wider) |

**Solution**: Design UI with 30% extra space or use auto-sizing.

### Avoid Concatenation
```gdscript
# BAD - can't localize word order
var text = "You found " + str(count) + " " + item_name

# GOOD - use format strings
var text = tr("FOUND_ITEMS") % [count, tr(item_name)]
# "FOUND_ITEMS" = "You found %d %s" / "Has encontrado %d %s"
```

### Icons Over Text
Where possible, use icons:
- Coin icon instead of "coins"
- Pickaxe icon for tools
- Direction arrows
- Universal symbols

## Minimal Text Approach

### GoDig-Specific Strategy
Mining games can be very visual:
- Numbers are universal
- Icons communicate items
- Colors indicate rarity
- Minimal tutorial text needed

### Text Needs
| Category | Text Amount |
|----------|-------------|
| Menus | Low (icons help) |
| Items | Medium (names) |
| Tutorial | Medium |
| Shop | Low (prices visual) |
| Achievements | Medium |
| Story/Lore | None (no story) |

## Implementation Plan

### Phase 1: Localization-Ready (MVP)
- [ ] Use tr() for ALL strings
- [ ] Create en.csv with all keys
- [ ] UI designed for text expansion
- [ ] Numbers/prices are visual

### Phase 2: First Languages (v1.0)
- [ ] Add es.csv, pt_BR.csv
- [ ] Professional translation
- [ ] Test all screens
- [ ] Font supports characters

### Phase 3: Asian Languages (v1.1)
- [ ] Add CJK fonts
- [ ] Handle text direction
- [ ] Region-specific assets if needed

## Font Considerations

### Required Character Sets
- Latin (English, Spanish, Portuguese, French, German)
- Cyrillic (Russian)
- CJK (Chinese, Japanese, Korean)
- Arabic (right-to-left!)

### Font Recommendations
```gdscript
# Godot 4 dynamic fonts
var latin_font = preload("res://assets/fonts/noto_sans.ttf")
var cjk_font = preload("res://assets/fonts/noto_sans_cjk.ttf")
```

**Noto Sans**: Free, covers most languages

## Testing Localization

### Pseudo-Localization
Test UI without full translation:
```gdscript
# Debug mode: show keys
func tr_debug(key: String) -> String:
    if OS.is_debug_build() and show_keys:
        return "[%s]" % key
    return tr(key)

# Expansion test: add 30% length
func tr_expanded(key: String) -> String:
    var text = tr(key)
    return text + "xxx"  # Test overflow
```

### Checklist Before Release
- [ ] All strings use tr()
- [ ] No hardcoded text
- [ ] UI handles expansion
- [ ] Fonts support all languages
- [ ] Numbers formatted correctly
- [ ] Dates/times localized
- [ ] Screenshots updated per language

## Budget Considerations

### Translation Costs
- Professional: $0.10-0.20 per word
- Crowdsourced: Free but inconsistent
- Machine + edit: $0.05 per word

### For GoDig (estimated 2000 words)
- 3 languages (Tier 1): ~$1,200
- 7 languages (Tier 2): ~$2,800
- All languages: ~$5,000+

### Alternative: Community Translation
After launch, accept volunteer translations with credit.

## Questions to Resolve
- [ ] Professional or community translation?
- [ ] How many languages at launch?
- [ ] CJK at v1.0 or later?
- [ ] Budget for localization?
- [ ] Region-specific content (holidays)?
