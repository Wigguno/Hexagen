# Hexagen
Hexagon grid generator for Dota 2 custom games

Hexagen utilizes cube coordinates as presented by Amit Patel  
http://www.redblobgames.com/grids/hexagons/

Example Results:  
http://i.imgur.com/ZU7MQvs.jpg  
http://i.imgur.com/eY94qGS.jpg  
http://i.imgur.com/a2DKdzC.jpg

# How To Use

Hexagen:GenerateHexagonGrid(HexRadius, PathWidth, LengthTable)

GridCenter  (Vector): The center of the hex grid  
HexRadius  (Number): The distance from the center of a hex tile to one of the corners  
PathWidth  (Number): The distance to leave between adjacent hex tiles  
LengthTable (Table): A table that defines the length of each of the 6 legs

Example:  
HexList = Hexagen:GenerateHexagonGrid(Vector(0, 0, 128, 64, 32, {3, 2, 2, 3, 2, 2}))

HexList is a table of all hex tiles and nodes in the grid. Each key is the name. Each value is a table that contains information about the hex/node, such as location, neighbours, and if it's pathable or not

The hexes can be iterated using
    for HexData in Hexagen:AllHexes(HexList) do
		...
	end
	
The nodes can be iterated similarly, using AllNodes instead of AllHexes.

For more information about how to use HexList, see addon_game_mode.lua
