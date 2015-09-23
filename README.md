# Hexagen
Hexagon grid generator for Dota 2 custom games

Hexagen utilizes cube coordinates as presented by Amit Patel  
http://www.redblobgames.com/grids/hexagons/

Example Results:  
http://i.imgur.com/ZU7MQvs.jpg  
http://i.imgur.com/eY94qGS.jpg

# How To Use

Hexagen:GenerateHexagonGrid(HexRadius, PathWidth, LengthTable)

GridCenter  (Vector): The center of the hex grid  
HexRadius  (Number): The distance from the center of a hex tile to one of the corners  
PathWidth  (Number): The distance to leave between adjacent hex tiles  
LengthTable (Table): A table that defines the length of each of the 6 legs

Example:  
HexList = Hexagen:GenerateHexagonGrid(Vector(0, 0, 128, 64, 32, {3, 2, 2, 3, 2, 2}))

HexList is a table of all hex tiles in the grid. Each key is the name of the hexagon. Each value is a table that contains the vector location, and a table of all neighbouring tile keys

For more information about how to use HexList, see addon_game_mode.lua
