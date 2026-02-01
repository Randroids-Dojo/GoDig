---
title: "implement: Coin flow sell animation with sound"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T09:45:00.639540-06:00"
---

Research Session 23 identified sell animations as critical for satisfaction. This moment repeats hundreds of thousands of times across player lifecycle.

## Context
Research findings:
- 'Currency flows from claim button to wallet's UI location'
- Beatstar: 'coins flip and spin, reflecting light when entering balance'
- Brawl Stars: 'currency pauses mid-animation, ensuring players admire it'
- Each currency type should have unique sound profile
- Benefits compound over player lifecycle - worth investment

## Specification

### Animation Flow
1. Player confirms sell at shop
2. Ore icons fly from inventory toward coin counter
3. Each ore transforms into coin(s) mid-flight
4. Coins fan out, then converge on wallet/counter
5. Brief pause as coins 'land' - counter ticks up
6. Final celebration burst when all coins collected

### Sound Design
- Ore-to-coin transformation: sparkle/transmutation sound
- Coins in flight: subtle whoosh
- Coins landing: satisfying 'clink' (stagger timing for cascade feel)
- Counter tick-up: mechanical register sound
- Final celebration: triumphant jingle

### Visual Polish
- Coins should have slight spin/tumble
- Trajectory curves, not straight lines
- Golden particle trail
- Screen shake (subtle) on large sales
- Number counter animates up, not instant

## Affected Files
- Shop scene - trigger animation on sell
- CoinAnimation component (new) - handle flight path
- AudioManager - sell sound effects
- HUD - coin counter animation

## Verify
- [ ] Build succeeds
- [ ] Coins visibly flow from inventory to counter
- [ ] Sound plays in satisfying cascade
- [ ] Counter animates up progressively
- [ ] Large sales feel more impressive than small sales
