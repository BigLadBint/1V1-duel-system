# 1v1 Duel System for FiveM

Simple but robust 1v1 duel script using routing buckets.  
Players can challenge each other with `/1v1 [id]`, accept/decline via NUI popup, fight to 10 kills (configurable), automatic new rounds, and cleanup on disconnect.

### Features
- Invite / accept / decline system with 45-second timeout
- Routing bucket isolation (no interference from other players)
- Multiple arenas (random or sequential mode)
- Godmode + freeze during countdown (no early shooting)
- Score HUD + countdown timer
- Basic anti-exploit distance check on kills
- Auto cleanup when player leaves/crashes
- First to Config.MaxKills wins

### Author
**BigLadbint**

### Installation
1. Drag this folder into your `resources` directory
2. Ensure it in your `server.cfg`:
