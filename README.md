Dota 2 Custom Pathing Library
==============
#### Interfaces an existing Lua game pathing library, Jumper (https://github.com/Yonaba/Jumper), with Dota 2.

![](http://giant.gfycat.com/InfiniteImaginaryBettong.gif)

#### Possible uses:
1. Checking for a valid path in a Tower Defense game.
2. To simulate pathing as if buildings were rectangular-shaped.

---------------------

#### How To Install:
1. Put everything in your vscripts folder.
2. Merge the code in ```addon_game_mode.lua``` with your own ```addon_game_mode.lua```.
3. Call **Pathing:Setup(nMapLength)** in your InitGameMode function, where nMapLength is the length of one side of your square-shaped map. If you're using the tile editor, it will be 16384.
4. Merge the code in ```npc_abilities_custom.txt``` with your own ```npc_abilities_custom.txt```.
5. If you want a unit to use custom pathing, give it the "moveunit" ability. Cast the ability on locations to move the unit.
6. If you want to close squares, as shown in the gfy, add the "closesquares" ability to a unit and cast it on locations.

#### TODO:
* Integrate with Building Helper.
* Make a couple more useful functions.
