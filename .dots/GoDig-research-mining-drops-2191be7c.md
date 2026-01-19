---
title: "research: Mining drops to inventory"
status: open
priority: 0
issue-type: task
created-at: "2026-01-18T23:35:22.745725-06:00"
---

When player destroys a block, what happens? Currently block_destroyed signal fires but nothing adds to inventory. Need to connect: dirt_block destruction -> determine drop -> add to InventoryManager. Should use ItemData or OreData? Where does the drop logic live (DirtBlock, Player, or separate system)?
