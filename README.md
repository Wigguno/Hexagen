# Hexagen
Hexagon grid generator for Dota 2 custom games

Hexagen utilizes cube coordinates as presented by Amit Patel  
http://www.redblobgames.com/grids/hexagons/

Example Results:  
http://i.imgur.com/ZU7MQvs.jpg  
http://i.imgur.com/eY94qGS.jpg  
http://i.imgur.com/a2DKdzC.jpg
http://i.imgur.com/yqYCS8o.jpg

# How To Use
```lua
Hexagen:GenerateHexagonGrid(GridCenter, HexRadius, PathWidth, LengthTable)
```
GridCenter  (Vector): The center of the hex grid  
HexRadius  (Number): The distance from the center of a hex tile to one of the corners  
PathWidth  (Number): The distance to leave between adjacent hex tiles  
LengthTable (Table): A table that defines the length of each of the 6 legs

Example:  
```lua
HexList = Hexagen:GenerateHexagonGrid(Vector(0, 0, 128), 64, 32, {3, 2, 2, 3, 2, 2}))
```

HexList is a table of all hex tiles and nodes in the grid. Each key is the name. Each value is a table that contains information about the hex/node, such as location, neighbours, and if it's pathable or not  
HexList also contains two number values, the number of hexes, and the number of nodes. These are stored with keys "HexCount" and "NodeCount"

Hexagen also includes iterators to iterate over the results of a HexList
```lua
-- Iterate over all Hexes
for HexData in Hexagen:AllHexes(HexList) do
	...
end

-- Iterate over all Nodes
for NodeData in Hexagen:AllNodes(HexList) do
	...
end
```

To run a pathfinding query on a grid, use 
```lua
PathList = Hexagen:FindPath(HexList, PathType, StartingName, EndingName)
```
Where PathType is either "Hex" or "Node" to run a hex or node query. Starting/Ending Name are the name of the tiles for the path to start and end at

PathList will be a list of all the names of the tiles in the path, or nil if no route was found

For more information about how to use HexList, see addon_game_mode.lua
