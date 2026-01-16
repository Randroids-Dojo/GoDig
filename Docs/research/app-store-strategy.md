# App Store Strategy Research

## Sources
- [App Store Optimization Guide](https://www.apptentive.com/blog/app-store-optimization/)
- [Google Play Best Practices](https://developer.android.com/distribute/best-practices)
- [Apple App Store Guidelines](https://developer.apple.com/app-store/guidelines/)

## App Store Optimization (ASO)

### Key ASO Elements
1. **App Name**: Searchable, memorable
2. **Keywords**: Relevant search terms
3. **Description**: Compelling, keyword-rich
4. **Screenshots**: Show gameplay
5. **Icon**: Recognizable, stands out
6. **Ratings**: Social proof

## App Naming

### Considerations
- Short enough to display fully
- Include key genre word
- Memorable and unique
- Available on both stores

### Name Options
| Option | Pros | Cons |
|--------|------|------|
| GoDig | Short, catchy | Generic, may exist |
| GoDig: Mining Adventure | Descriptive | Long |
| Dig Deep | Clear genre | Very common |
| Treasure Miner | Descriptive | Generic |

**Recommendation**: "GoDig" or "GoDig: Endless Mining"

## Keywords & Search Terms

### Target Keywords
**Primary (High Volume):**
- mining game
- dig game
- idle miner
- treasure hunter

**Secondary (Medium Volume):**
- underground adventure
- digging simulator
- gem collector
- mining tycoon

**Long-tail (Low Competition):**
- endless digging game
- pixel mining adventure
- casual dig game

### Platform-Specific

**Google Play:**
- Keywords in title (80 chars)
- Keywords in short description (80 chars)
- Keywords in full description (4000 chars)

**App Store:**
- Keywords field (100 chars, comma-separated)
- Title (30 chars)
- Subtitle (30 chars)

## App Description

### Structure
```
[Hook - First 1-2 sentences visible before "Read More"]
Dig deep into an endless underground world! Mine gems, 
collect treasures, and build your mining empire.

[Features - Bullet points]
⛏️ ENDLESS DIGGING
Explore infinitely deep procedural mines

💎 COLLECT TREASURES
Find rare gems, artifacts, and fossils

🏪 BUILD YOUR EMPIRE
Unlock shops since upgrade your tools

🎮 EASY CONTROLS
Intuitive touch controls, play anywhere

[Call to Action]
Download now and start your mining adventure!

[Keywords naturally included]
Perfect for fans of idle games, mining simulators, 
and casual adventure games.
```

### Localized Descriptions
Translate for each target market:
- English (US/UK)
- Spanish
- Portuguese (Brazil)
- French
- German

## Screenshots Strategy

### Required Screenshots
| Platform | Count | Size |
|----------|-------|------|
| iOS iPhone | 3-10 | 6.5" (1284x2778) |
| iOS iPad | 3-10 | 12.9" (2048x2732) |
| Android Phone | 2-8 | 16:9 or 9:16 |
| Android Tablet | 2-8 | Various |

### Screenshot Content
1. **Gameplay**: Player digging underground
2. **Treasures**: Finding rare gems
3. **Surface**: Building shops
4. **Upgrades**: Tool/shop upgrade screen
5. **Depth**: Deep underground variety
6. **Controls**: Showing mobile interface

### Screenshot Style
- Actual gameplay (not mockups)
- Text overlays explaining features
- Consistent visual style
- Show best/exciting moments

### Example Layout
```
Screenshot 1: "DIG DEEP INTO ADVENTURE"
[Player digging with gems visible]

Screenshot 2: "COLLECT RARE TREASURES"
[Inventory full of colorful gems]

Screenshot 3: "BUILD YOUR MINING TOWN"
[Surface with multiple shops]

Screenshot 4: "UPGRADE YOUR TOOLS"
[Blacksmith upgrade screen]

Screenshot 5: "EXPLORE ENDLESS DEPTHS"
[Deep underground with rare ores]
```

## App Icon

### Design Principles
- Simple, recognizable at small sizes
- Represents core gameplay
- Uses brand colors
- No text (illegible at icon size)
- Stands out in store grid

### Icon Concepts
1. Pickaxe on gem background
2. Miner character silhouette
3. Diamond with pickaxe
4. Underground cross-section

### Technical Requirements
| Platform | Size | Format |
|----------|------|--------|
| iOS | 1024x1024 | PNG (no alpha) |
| Android | 512x512 | PNG (32-bit) |
| Web | Various | PNG/SVG |

## Video/Preview

### App Preview (iOS)
- 15-30 seconds
- Show core gameplay
- Capture attention immediately
- No audio required (most watch muted)

### Promo Video (Google Play)
- YouTube video link
- 30 seconds to 2 minutes
- Landscape or portrait

### Video Content
```
0:00-0:05 - Logo/title
0:05-0:10 - Surface overview
0:10-0:20 - Digging gameplay
0:20-0:25 - Finding treasure
0:25-0:30 - Upgrade/shop
```

## Ratings & Reviews

### Getting Reviews
- In-app rating prompt (after positive moment)
- Don't ask too early
- Don't ask after failure
- Respect "don't ask again"

### Rating Prompt Timing
```gdscript
func maybe_show_rating_prompt():
    if already_rated or asked_recently:
        return
    
    # Only after positive moments
    if just_found_rare_gem or just_hit_milestone:
        if sessions_count >= 5 and total_play_time > 30 * 60:
            show_rating_dialog()
```

### Responding to Reviews
- Thank positive reviews
- Address negative reviews constructively
- Fix reported bugs
- Never argue with reviewers

## Launch Strategy

### Soft Launch
**Markets**: Canada, Australia, New Zealand
**Duration**: 2-4 weeks
**Purpose**: Test, fix bugs, balance

### Global Launch
1. Fix soft launch issues
2. Prepare marketing materials
3. Submit to stores (1-2 week review)
4. Launch day social media push
5. Monitor closely first 48 hours

### Launch Day Checklist
- [x] Launch: Store listings finalized
- [x] Launch: Screenshots (6 per platform)
- [x] Launch: EN/ES/PT descriptions
- [x] Launch: Privacy policy URL
- [x] Launch: Support email configured
- [x] Launch: Social media accounts ready
- [x] Launch: Press kit with assets
- [x] Launch: Firebase Analytics ready

## Pricing Strategy

### Free-to-Play (Recommended)
- Lower barrier to entry
- IAP for monetization
- Ads (optional, non-intrusive)
- Higher download volume

### Premium
- One-time purchase ($1.99-4.99)
- No ads, no IAP
- Lower downloads, higher quality users
- Harder to market

### Freemium Model for GoDig
- Free download
- Optional "Remove Ads" IAP ($2.99)
- Optional cosmetic IAP
- No pay-to-win

## App Store Categories

### Primary Category
- **iOS**: Games > Casual
- **Android**: Games > Casual

### Secondary Category
- **iOS**: Games > Adventure
- **Android**: Games > Simulation

### Tags (Google Play)
- Mining
- Idle
- Digging
- Treasure
- Casual

## Questions to Resolve
- [x] App name → "GoDig" or "GoDig: Endless Mining"
- [x] Model → Free-to-play with $2.99 remove ads
- [x] Soft launch → Canada, Australia, New Zealand
- [x] Launch target → After 4-week beta success
- [x] Marketing → Organic first, paid if traction
