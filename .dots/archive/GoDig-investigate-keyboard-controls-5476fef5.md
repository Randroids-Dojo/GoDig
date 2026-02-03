---
title: "Investigate: Keyboard controls not working on desktop web"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-03T04:13:45.873752-06:00\\\"\""
closed-at: "2026-02-03T04:17:58.917064-06:00"
close-reason: Fixed. Added tap-to-start overlay for web builds to capture user interaction before FTUE auto-start. This grants keyboard focus to the canvas.
---

Bug report: Keyboard controls (WASD/arrows) are not working when playing the web build on desktop browsers.

Investigation areas:
- Check if input events are being captured by the canvas
- Verify InputMap actions are set up for keyboard
- Check if touch controls are overriding/blocking keyboard input
- Test if focus is being lost to another element
- Review PlatformDetector logic for web builds
- Check browser console for any input-related errors

Test in: Chrome, Firefox, Safari on macOS
