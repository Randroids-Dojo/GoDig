---
title: "research: Web build performance optimization for Godot 4.6 - SharedArrayBuffer and threading"
status: open
priority: 2
issue-type: task
created-at: "2026-02-02T20:31:25.283482-06:00"
---

Research Godot 4.6 web export performance considerations. Topics: SharedArrayBuffer requirements, COOP/COEP headers, threading limitations, WebGL2 performance, memory limits in browsers, IndexedDB persistence patterns, mobile browser quirks (Safari/Chrome). Compare desktop vs mobile web performance. Reference existing web build infrastructure in build/serve.py. Key questions: What features should be disabled for web? How to detect and handle performance issues at runtime?
