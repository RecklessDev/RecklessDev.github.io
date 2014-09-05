---
title: "Match 3 progress: Refactoring, animations and custom combination recipes"
---

After a session of refactoring, the game is (again) working. Things are now nicely separated and I've removed all the initial hacks. Tried to separate the module responsible for game board management so I have a reusable component for similar games in the future.

[![Match 3 game view](/images/post_match_3_progress.gif)](/images/post_match_3_progress.gif)
**Match 3 game view**
{: class="post-image"}

I reworked the way game board handles its dimensions to be easier to alter it and changed the selection mechanism for blocks. Instead of clicking on each one it makes more sense to click once and drag to others. This allows greater liberty for selecting the number of elements to be used in a recipe. As of now it is quite glitchy, it will need more attention but that is for later.

I was really unhappy with the highlight I initially created so I changed it to be more visible. It is ugly, but at least I can properly see what it is highlighted. I plan to add a "zoom in" + "shake" + "glow" effects instead of the red highlight I implemented now.

Additionally, now instead of matching three elements of the same type I'm using an XML to write custom recipes. In the gif above it can be seen that I match a "white ball" (mana) with two red swords (2x fire elements). This will cast a "Fire Spell", which, as of now, has the only effect of logging in the console the message "Casting Fire Spell" and nothing else. A healing spell as well as a restore mana spell is supported.

Took the liberty to find some characters on the unity store and simply put them on the sides of the board. They do nothing now except looking dumb. Looking dumb with some text above them. But a health system with a simple AI (auto-attack, really) is coming. Add the spell casting mechanism to that and we have the first demo version that should be ready and published (as a prototype demo) in two weeks. Yeei.