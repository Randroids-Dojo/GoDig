# Session Design & Player Retention

## Mobile Session Patterns

### Typical Mobile Session Lengths
- **Micro sessions**: 1-3 minutes (waiting in line, quick break)
- **Short sessions**: 5-15 minutes (commute, bathroom)
- **Medium sessions**: 15-30 minutes (lunch break, relaxing)
- **Long sessions**: 30-60+ minutes (dedicated play time)

### GoDig Target Session Design
Primary target: **5-15 minute sessions** with natural stopping points

## Natural Stopping Points

### Inventory Full
- Most natural break point
- Player has tangible progress to save
- Creates "just fill inventory then stop" mindset
- Should happen every 3-8 minutes early game

### Reached Surface
- Sold resources, bought upgrade
- Clean mental closure
- "I accomplished something" feeling
- Good time to close app

### Depth Milestone
- "I hit 500m!" celebration
- Achievement unlocked moment
- Natural pause for celebration

### Upgrade Purchased
- Goal completed
- Stats improved
- New capability to try "next time"

## Session Flow Design

### Ideal Session Arc (10-15 min)
```
0-2 min:  Start at surface, prepare
2-8 min:  Dig down, collect resources
8-12 min: Navigate back to surface
12-15 min: Sell, upgrade, consider next dive
```

### Supporting This Arc
- Inventory size determines dig duration
- Tool durability (if implemented) paces returns
- Surface is always quick to access (elevator later)

## Retention Mechanics

### Daily Login Rewards

#### Pros
- Creates habit formation
- Gives reason to return
- Free value for player

#### Cons
- Can feel manipulative
- Missing days feels punishing
- FOMO can be negative

#### Recommendation: Light Touch
```
Day 1: 100 coins
Day 2: 200 coins
Day 3: 500 coins
Day 4: 1000 coins
Day 5: Random rare ore
Day 6: 2000 coins
Day 7: Mystery box (random upgrade)
```
- No "streak reset" punishment
- Each day is independent bonus
- Not required for progression

### Depth Records

#### Personal Best Tracking
- "Your deepest dive: 847m"
- Try to beat your own record
- Compare across sessions

#### Weekly Challenges?
- "Reach 1000m this week"
- Bonus reward for completion
- Optional, not required

### Return Triggers

#### "Continue Where You Left Off"
- Save mid-mine state
- "You were at 523m with full inventory!"
- One-tap to resume

#### "Your Tools Are Ready"
- If durability system: "Pickaxe repaired!"
- If energy system: "Energy recharged!"
- If neither: "New daily bonus waiting!"

### Offline Progress (Optional)

#### Passive Income
- Hired miners generate resources while offline
- "You earned 500 coins while away!"
- Late-game unlock

#### Why It Works
- Rewards returning players
- Doesn't require active play
- Creates "what did I earn?" curiosity

#### Concerns
- Can devalue active play
- Complexity to balance
- Maybe v1.1+ feature

## Engagement Without Manipulation

### Healthy Engagement
- Natural gameplay loops
- Clear goals and progress
- Respecting player time
- No artificial waiting

### Unhealthy Patterns to Avoid
- Energy systems that gate play
- "Watch ad to continue" interruptions
- Time-limited events with FOMO
- Pay-to-skip frustration walls

### GoDig Philosophy
- **Play when you want, stop when you want**
- Progress is always saved
- No timers blocking gameplay
- Monetization through value, not frustration

## Session Length Feedback

### Gentle Reminders
- After 30 min: "You've been mining for a while! Remember to take breaks."
- After 60 min: "Great session! Your progress is saved."
- Non-intrusive, dismissible

### Play Statistics
- Track session lengths
- Show in statistics menu
- "Total playtime: 12 hours"
- "Longest session: 45 minutes"

## Platform Considerations

### Mobile-Specific
- Quick resume from background
- Handle interruptions (calls, notifications)
- Portrait mode for one-handed play
- Battery-conscious (lower effects option)

### Web-Specific
- Browser tab can be closed anytime
- Cloud save for cross-device
- No installation barrier

## Metrics to Track (Analytics)

### Session Metrics
- Average session length
- Sessions per day per user
- Day 1/7/30 retention rates
- Session end points (what stopped them?)

### Progression Metrics
- Average depth reached per session
- Time to first upgrade
- Upgrade purchase rates
- Churn points (where players quit)

### Red Flags to Watch
- Very short sessions (< 2 min) = boring/confusing
- Very long sessions without breaks = potential unhealthy
- High drop-off at specific points = difficulty spike
- Low return rate = not compelling

## Questions to Resolve
- [x] Daily rewards → v1.1+ ethical opt-in system
- [x] Offline progress → Not planned, active play only
- [x] App close → Auto-save, respawn at surface safely
- [x] Session warnings → Optional gentle reminders

## Design Recommendations

### MVP
1. Auto-save on meaningful actions
2. Quick resume from app switch
3. Natural stopping points (inventory full)
4. Session length tracking (internal metrics)

### v1.0
1. Daily login bonus (light version)
2. Depth record tracking
3. "Continue where you left off" prompt
4. Basic analytics integration

### v1.1+
1. Offline progress system
2. Weekly challenges
3. Advanced retention features
4. Social comparison features
