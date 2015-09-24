-- Hexagen Generation Code
-- by wigguno

-- Using Cube coordinates by Amit Patel
-- http://www.redblobgames.com/grids/hexagons/

if Hexagen == nil then
	print("Loading Hexagen by wigguno")
	Hexagen = class({})
end

if TileList == nil then
	TileList = {}
	TileList.__index = TileList
end
if HexTile ==  nil then
	HexTile = {}
	HexTile.__index = HexTile
end
if NodeTile == nil then
	NodeTile = {}
	NodeTile.__index = NodeTile
end

function Hexagen:GenerateHexagonGrid(GridCenter, HexRadius, PathWidth, LengthTable)
	-- Hexagen:GenerateHexagonGrid(HexRadius, PathWidth, LengthTable)
	--
	-- GridCenter  (Vector): The center of the hex grid
	-- HexRadius  (Number): The distance from the center of a hex tile to one of the corners
	-- PathWidth  (Number): The distance to leave between adjacent hex tiles
	-- LengthTable (Table): A table that defines the length of each of the 6 legs
	--
	-- Example:
	-- TileList = Hexagen:GenerateHexagonGrid(Vector(0, 0, 128), 64, 32, {3, 2, 2, 3, 2, 2}))

	-- This is a distance used internally to set the distance between hexes
	local HexDistance = HexRadius + PathWidth
	
	-- Define our offset sizes for each direction
	-- This converts Cube Coordinates (A,B,C) into Cartesian Coordinates (X,Y)
	local HexOffset_A = Vector(	0, 		1, 		0) * HexDistance
	local HexOffset_B = Vector(	-0.85, 	-0.5, 	0) * HexDistance
	local HexOffset_C = Vector(	0.85, 	-0.5, 	0) * HexDistance

	-- set the center of the grid
	local CenterLocation = GridCenter

	-- Create the table
	-- HexTable[A][B][C]
	-- HexTable is a 3 dimensional table where each of the dimensions correspond to a direction

	local HexTable = {}
	local dim_len = math.max(LengthTable[1], LengthTable[2], LengthTable[3], LengthTable[4], LengthTable[5], LengthTable[6])

	-- We create the table bigger than we require and won't fill it entirely
	-- This table is used because finding neighbours is easy
	-- Once all hexes are generated and named, and their neighbours are located, this table becomes unneeded
	for dim_1 = (dim_len * -1), dim_len  do
		HexTable[dim_1] = {}

		for dim_2 = (dim_len * -1), dim_len do
			HexTable[dim_1][dim_2] = {}

			for dim_3 = (dim_len * -1), dim_len do
				if (dim_1 + dim_2 + dim_3) == 0 then
					HexTable[dim_1][dim_2][dim_3] = {}
				end
			end
		end
	end

	-- A combination of these will set the direction to one of the 6 legs
	DirectionA = {0,   1,  1,  0, -1, -1}
	DirectionB = {1,   0, -1, -1,  0,  1}
	DirectionC = {-1, -1,  0,  1,  1,  0}

	-- Keep track of how many hexes we find, and name them sequentially
	local HexCount = 1

	-- Do the center hex manually
	local hex = {}
	hex["name"] = "Hex_" .. HexCount
	hex["location"] = CenterLocation

	HexTable[0][0][0] = hex

	-- Go down each of the 6 legs and find all their hexes
	-- Then rotate around the center to find leaf hexes

	for Direction = 1,6 do
		-- These define how to multiply the radius to get to each hex in the grid
		-- We do 3 loops (The main leg loop, and two leaf loops), so we need 3 sets of factors
		local LenFactorA = DirectionA[Direction]
		local LenFactorB = DirectionB[Direction]
		local LenFactorC = DirectionC[Direction]

		-- The Leaf loops are in the direction +-2 from the leg direction
		-- make sure we get a correct index to the factor table!
		local LeafDirection1 = Direction + 2
		if LeafDirection1 > 6 then LeafDirection1 = LeafDirection1 - 6 end

		local LeafDirection2 = Direction - 2 
		if LeafDirection2 < 1 then LeafDirection2 = LeafDirection2 + 6
		end

		local LeafFactor1A = DirectionA[LeafDirection1]
		local LeafFactor1B = DirectionB[LeafDirection1]
		local LeafFactor1C = DirectionC[LeafDirection1]

		local LeafFactor2A = DirectionA[LeafDirection2]
		local LeafFactor2B = DirectionB[LeafDirection2]
		local LeafFactor2C = DirectionC[LeafDirection2]
		
		-- We want to cap each leaf search based on the next leg over
		-- so get the index to those legs
		MaxLeafDirection1 = Direction + 1
		if MaxLeafDirection1 > 6 then MaxLeafDirection1 = MaxLeafDirection1 - 6 end

		MaxLeafDirection2 = Direction - 1
		if MaxLeafDirection2 < 1 then MaxLeafDirection2 = MaxLeafDirection2 + 6 end

		-- Store the length of the adjacent legs for the leaf searches
		local MaxLeafDepth1 = LengthTable[MaxLeafDirection1]
		local MaxLeafDepth2 = LengthTable[MaxLeafDirection2]

		-- Loop over each leg in the length table
		for Radius = 1, LengthTable[Direction] do
			local LenA = Radius * LenFactorA
			local LenB = Radius * LenFactorB
			local LenC = Radius * LenFactorC

			-- Convert our Cube Coordinates into Cartesian Coordinates
			local HexLocation = CenterLocation + (LenA * HexOffset_A) + (LenB * HexOffset_B) + (LenC * HexOffset_C)

			-- Store this hex
			local hex = {}
			HexCount = HexCount + 1
			hex["name"] = "Hex_" .. HexCount
			hex["location"] = HexLocation

			HexTable[LenA][LenB][LenC] = hex
			
			-- Traverse around (clockwise) to create leaves
			for LeafDepth = 1, (Radius -1) do

				-- Cap at the length of the adjacent leg
				if LeafDepth <= MaxLeafDepth1 then
					local LeafA = LenA + (LeafDepth * LeafFactor1A)
					local LeafB = LenB + (LeafDepth * LeafFactor1B)
					local LeafC = LenC + (LeafDepth * LeafFactor1C)

					-- Convert our Cube Coordinates into Cartesian Coordinates
					local LeafLocation = CenterLocation + (LeafA * HexOffset_A) + (LeafB * HexOffset_B) + (LeafC * HexOffset_C)

					-- This will check if a hex exists in this space already. 
					if next(HexTable[LeafA][LeafB][LeafC]) == nil then

						-- if this is a new hex, name it and store it
						local hex = {}
						HexCount = HexCount + 1
						hex["name"] = "Hex_" .. HexCount
						hex["location"] = LeafLocation

						HexTable[LeafA][LeafB][LeafC] = hex
					end
				end
			end

			-- Traverse around (anti-clockwise) to create leaves
			for LeafDepth = 1, (Radius -1) do

				-- Cap at the length of the adjacent leg
				if LeafDepth <= MaxLeafDepth2 then
					local LeafA = LenA + (LeafDepth * LeafFactor2A)
					local LeafB = LenB + (LeafDepth * LeafFactor2B)
					local LeafC = LenC + (LeafDepth * LeafFactor2C)

					-- Convert our Cube Coordinates into Cartesian Coordinates
					local LeafLocation = CenterLocation + (LeafA * HexOffset_A) + (LeafB * HexOffset_B) + (LeafC * HexOffset_C)

					-- This will check if a hex exists in this space already. 
					if next(HexTable[LeafA][LeafB][LeafC]) == nil then

						-- if this is a new hex, name it and store it
						local hex = {}
						HexCount = HexCount + 1
						hex["name"] = "Hex_" .. HexCount
						hex["location"] = LeafLocation

						HexTable[LeafA][LeafB][LeafC] = hex

					end
				end
			end -- end Leaf2 generation	
		end -- end Stepping down Legs
	end -- end Generation Loop


	-- Define a list that will store our hexes with named keys, and neighbour information
	local TileList = TileList.new()

	-- Neighbours can be found by searching +-1 in the 3 directions
	local NeighbourDiffs = {}
	table.insert(NeighbourDiffs, {1, -1,  0})
	table.insert(NeighbourDiffs, {1,  0, -1})
	table.insert(NeighbourDiffs, {0,  1, -1})
	table.insert(NeighbourDiffs, {-1, 1, 0})
	table.insert(NeighbourDiffs, {-1, 0, 1})
	table.insert(NeighbourDiffs, {0, -1, 1})

	-- Loop over the entire HexTable looking for generated hexes
	for dim_1 = (dim_len * -1), dim_len  do
		for dim_2 = (dim_len * -1), dim_len do
			for dim_3 = (dim_len * -1), dim_len do

				-- check that the constraint is true
				if (dim_1 + dim_2 + dim_3) == 0 and next(HexTable[dim_1][dim_2][dim_3]) ~= nil then

					local hex = HexTable[dim_1][dim_2][dim_3]

					local h = HexTile.new(hex["name"])
					h.Location = hex["location"]
					
					-- For each of the 6 neighbour positions
					for n = 1, table.getn(NeighbourDiffs) do
						local nIndex1 = dim_1 + NeighbourDiffs[n][1]
						local nIndex2 = dim_2 + NeighbourDiffs[n][2]
						local nIndex3 = dim_3 + NeighbourDiffs[n][3]

						-- check if we are inside the bounds of the array
						if (nIndex1 <= dim_len) and nIndex1 >= (dim_len * -1)
						and (nIndex2 <= dim_len) and nIndex2 >= (dim_len * -1)
						and (nIndex3 <= dim_len) and nIndex3 >= (dim_len * -1)
						then

							-- Store the name of this neighbour in this hex
							local neighbour = HexTable[nIndex1][nIndex2][nIndex3]
							if neighbour ~= nil and next(neighbour) ~= nil then
								h.Neighbours[n] = neighbour["name"]
							end
						end
					end

					-- put the hex into the list with it's name as a key
					-- neighbours can now look up its location from this list
					TileList.HexList[h.Name] = h
				end
			end
		end
	end

	-- Store the number of Hex tiles in the output
	TileList.HexCount = HexCount

	-- As well as locating all the neighbouring hexes, get the list of "nodes" which are corners of each hex
	-- These are shared with neighbours
	local NodeCount = 0

	-- This is the distance from the center of the hex to the node
	local NodeOffset = {}
	NodeOffset[1] = Vector(	0, 		1, 		0) * HexDistance
	NodeOffset[2] = Vector(	-0.85, 	0.5, 	0) * HexDistance
	NodeOffset[3] = Vector(	-0.85, 	-0.5, 	0) * HexDistance
	NodeOffset[4] = NodeOffset[1] * -1
	NodeOffset[5] = NodeOffset[2] * -1
	NodeOffset[6] = NodeOffset[3] * -1
	
	-- loop over each of the hexes and generate their nodes
	for HexData in TileList:AllHexes() do
		
		-- check each of the 6 nodes for each hex
		-- unlike neighbours, each hex will have all 6 nodes.
		for NodeNum = 1,6 do

			-- Nodes can be generated by neighbours, so we need to check if we've already generated this node
			if HexData.Nodes[NodeNum] == nil then

				-- Get the offset to find the location of this node
				local offset = NodeOffset[NodeNum]
				
				NodeCount = NodeCount + 1
				-- Save and store this node in the Hex List
				local n = NodeTile.new("Node_" .. NodeCount)
				n.Location = HexData.Location + offset
				TileList.NodeList[n.Name] = n

				HexData.Nodes[NodeNum] = n.Name

				-- Each node can share two neighbours
				-- convert the node number to a neighbour number
				-- and check if that neighbour exists
				local TargetNeighbour1 = NodeNum
				local TargetNeighbour2 = NodeNum + 1
				if TargetNeighbour2 > 6 then TargetNeighbour2 = TargetNeighbour2 - 6 end

				-- loop over this nodes neighbours and check if the neighbour number matches our target
				for NeighbourDirection, Neighbour in pairs(HexData.Neighbours) do
					if NeighbourDirection == TargetNeighbour1 then

						-- Convert the base node number to this tiles node number
						local Neighbour1NodeNum = NodeNum + 2
						if Neighbour1NodeNum > 6 then Neighbour1NodeNum = Neighbour1NodeNum - 6 end

						-- Check if this node has already been generated, and store it
						if TileList.HexList[Neighbour].Nodes[Neighbour1NodeNum] == nil then
							TileList.HexList[Neighbour].Nodes[Neighbour1NodeNum] = n.Name
						end

					elseif NeighbourDirection == TargetNeighbour2 then

						-- Convert the base node number to this tiles node number
						local Neighbour2NodeNum = NodeNum -2
						if Neighbour2NodeNum < 1 then Neighbour2NodeNum = Neighbour2NodeNum + 6 end

						-- Check if this node has already been generated, and store it
						if TileList.HexList[Neighbour].Nodes[Neighbour2NodeNum] == nil then
							TileList.HexList[Neighbour].Nodes[Neighbour2NodeNum] = n.Name
						end
					end
				end
			end		
		end
	end

	-- Store the number of Hex tiles in the output
	TileList.NodeCount = NodeCount


	-- Now that we've generated all the nodes, we can link them to their neighbours
	-- This requires looping over the tiles because the tiles have the node number stored
	-- which is the direction of the node. Using this we can pick the right direction neighbouring tile
	-- which our node will link to

	-- Also insert information about the surrounding hexes 
	for HexData in TileList:AllHexes() do
		
		-- Find neighbours for each node on each hex
		for Num = 1,6 do
			local NodeName = HexData.Nodes[Num]
			local NodeData = TileList.NodeList[NodeName]

			-- we will check the tangential neighbour first
			-- this requires checking if the hex has one of two neighbouring hexes
			-- The node can then be found from that neighbour

			-- Check that we have the required neighbour
			local NeighbourNum1 = Num
			local NeighbourNum2 = Num + 1
			if NeighbourNum2 > 6 then NeighbourNum2 = NeighbourNum2 - 6 end

			if HexData.Neighbours[NeighbourNum1] ~= nil then
				local HexNeighbourName = HexData.Neighbours[NeighbourNum1] 
				local HexNeighbourData = TileList.HexList[HexNeighbourName]

				local targetNode = Num + 1
				if targetNode > 6 then targetNode = targetNode - 6 end

				local NeighbourNodeName = HexNeighbourData.Nodes[targetNode]

				table.insert(NodeData.Neighbours, NeighbourNodeName)

			elseif HexData.Neighbours[NeighbourNum2] ~= nil then
				local HexNeighbourName = HexData.Neighbours[NeighbourNum2] 
				local HexNeighbourData = TileList.HexList[HexNeighbourName]

				local targetNode = Num - 1
				if targetNode < 1 then targetNode = targetNode + 6 end

				local NeighbourNodeName = HexNeighbourData.Nodes[targetNode]

				table.insert(NodeData.Neighbours, NeighbourNodeName)
			end

			-- Get the next neighbour along the perimeter of this hex
			local NextNeighbour = Num + 1
			if NextNeighbour > 6 then NextNeighbour = NextNeighbour - 6 end
			table.insert(NodeData.Neighbours, HexData.Nodes[NextNeighbour])

			-- Get the previous neighbour along the perimeter of this hex
			local LastNeighbour = Num - 1
			if LastNeighbour < 1 then LastNeighbour = LastNeighbour + 6 end
			table.insert(NodeData.Neighbours, HexData.Nodes[LastNeighbour])

			-- Add this hex to the nodes table
			table.insert(NodeData.Hexes, HexData.Name)
		end
	end



	return TileList
end

function TileList.new()
	local self = setmetatable({}, TileList)
	self.HexCount = 0
	self.NodeCount = 0
	self.HexList = {}
	self.NodeList = {}

	-- An iterator for the hexes
	function self:AllHexes()
		local i = 0
		local n = self.HexCount
		return function()
			i = i + 1
			if i <= n then return self.HexList["Hex_" .. i] end
		end
	end

	-- An iterator the nodes
	function self:AllNodes()
		local i = 0
		local n = self.NodeCount
		return function()
			i = i + 1
			if i <= n then return self.NodeList["Node_" .. i] end
		end
	end
 
	-- use a* to find a path between two nodes
	function self:FindPath(PathType, StartingInd, EndingInd)
		local OpenList = {}
		local ClosedList = {}
		local Map = {}

		-- The movement cost will be the difference between Hex_1 and Hex_2 for the case of Hex Navigation
		-- and the difference between Node_1 and Node_2 for the case of Node Navigation
		local MovementCost = -1

		-- Populate the map based on what kind of pathing we're doing
		if string.lower(PathType) == "hex" then
			for HexData in self:AllHexes() do
				Map[HexData.Name] = copy(HexData, {})
			end
			MovementCost = (Map["Hex_1"].Location - Map["Hex_2"].Location):Length2D()
		elseif string.lower(PathType) == "node" then
			for NodeData in self:AllNodes() do
				Map[NodeData.Name] = copy(NodeData, {})
			end
			MovementCost = (Map["Node_1"].Location - Map["Node_2"].Location):Length2D()
		else
			print ("[Hexagen:FindPath] Invalid PathType passed!")
			return -1
		end

		-- Check that the starting and ending indexes are valid and different
		if StartingInd == EndingInd then
			print ("[Hexagen:FindPath] StartingInd and EndingInd are the same!")
			return -1
		elseif setContainsKey(Map, StartingInd) == false then
			print ("[Hexagen:FindPath] Invalid StartingInd passed!")
			return -1
		elseif setContainsKey(Map, EndingInd) == false then
			print ("[Hexagen:FindPath] Invalid EndingInd passed!")
			return -1
		end

		-- Add the starting point to the OpenList with a G score of 0
		Map[StartingInd]["GScore"] = 0
		Map[StartingInd]["FScore"] = self:PathingEstimateDistance(StartingInd, EndingInd)
		table.insert(OpenList, Map[StartingInd])
		local SolutionFound = false
		local iterations = 0

		-- Loop until we find a solution or determine it to be unsolvable
		while iterations < 10000 do

			-- Search for the Lowest F Score on the open list
			local LowestFScore = 999999
			local LowestTileName = ""

			for _, TileData in pairs(OpenList) do
				if TileData["FScore"] < LowestFScore then
					LowestFScore = TileData["FScore"]
					LowestTileName = TileData.Name
				end
			end
			iterations = iterations + 1
			
			-- Record this tiles G Score 
			if LowestTileName == "" then
				SolutionFound = false
				break
			end
			local ParentG = Map[LowestTileName]["GScore"]

			-- Evaluate each of the neighbours
			for _, NeighbourName in pairs(Map[LowestTileName].Neighbours) do
				local NeighbourData = Map[NeighbourName]
				
				-- If the neighbour is pathable and it's not on the closed list, evaluate it further
				if NeighbourData.Pathable == true and ListContainsTile(ClosedList, NeighbourData) == false then

					-- G Score is the cost of moving from the parent to this node
					local thisG = ParentG + MovementCost

					-- H Score is the cost of moving from this node to the finish
					-- We do a straight line cause we deleted the table with all the neighbours
					local thisH = self:PathingEstimateDistance(NeighbourName, EndingInd)

					local thisF = thisG + thisH

					--print(NeighbourName .. "G: " .. thisG .. " H: " .. thisH)

					-- Check if the tile is on the open list
					if ListContainsTile(OpenList, NeighbourData) == true then

						-- if the path from the start to this tile is now lower
						-- lower it's scores
						if NeighbourData["GScore"] > thisG then
							NeighbourData["parentInd"] = LowestTileName

							-- store the pathing scores
							NeighbourData["FScore"] = thisF
							NeighbourData["GScore"] = thisG
							NeighbourData["HScore"] = thisH
						end
					else
						-- store the pathing scores
						NeighbourData["FScore"] = thisF
						NeighbourData["GScore"] = thisG
						NeighbourData["HScore"] = thisH

						NeighbourData["parentInd"] = LowestTileName
						table.insert(OpenList, NeighbourData)
					end
				end
			end

			-- Remove this tile from the open list and add it to the closed list
			for i, val in pairs(OpenList) do
				if val.Name == LowestTileName then
					table.remove(OpenList, i)
					break
				end
			end
			table.insert(ClosedList, Map[LowestTileName])

			-- Check if we're finished

			-- Finish case 1) ClosedList contains EndingInd
			-- this means we found a solution
			if ListContainsTile(ClosedList, Map[EndingInd]) == true then
				SolutionFound = true
				break
			end
		end

		-- Fetch the list if we found a solution
		if SolutionFound == true then
			local nextstep = Map[EndingInd]
			local PathListR = {}
			local PathList = {}

			-- Traverse the parent indexes of the path to get the route in reverse
			while true do
				table.insert(PathListR, nextstep.Name)

				-- Get the name of tne next parent, and store it
				local parentName = nextstep["parentInd"]
				local parent = Map[parentName]
				nextstep = parent

				-- if we find the starting point, we're finished
				if nextstep.Name == StartingInd then
					break 
				end
			end
			table.insert(PathListR, StartingInd)

			-- Reverse the list to get the forward route
			for i = table.getn(PathListR), 1, -1 do
				table.insert(PathList, PathListR[i])
			end
			return PathList

		elseif SolutionFound == false then
			return nil
		end
	end

	-- get an estimate of the score to the final node
	function self:PathingEstimateDistance(StartingInd, EndingInd)

		if self.HexList[StartingInd] and self.HexList[EndingInd] then	
			return (self.HexList[EndingInd].Location - self.HexList[StartingInd].Location):Length2D()
		elseif self.NodeList[StartingInd] and self.NodeList[EndingInd] then
			return (self.NodeList[EndingInd].Location - self.NodeList[StartingInd].Location):Length2D()
		end
	end

	return self
end

function HexTile.new(HexName)
	local self = setmetatable({}, HexTile)
	self.Name = HexName
	self.Location = nil
	self.Neighbours = {}
	self.Nodes = {}
	self.Pathable = true

	-- An iterator for the neighbours
	function self.AllNeighbours()
		local i = 0
		local n = 6
		return function()
			i = i + 1
			if i <= n then 
				while self.Neighbours[i] == nil do 
					i = i + 1
					if i > n then return nil end
				end
				return self.Neighbours[i]
			end
		end
	end

	function self.AllNodes()
		local i = 0
		local n = 6
		return function()
			i = i + 1
			if i <= n then
				return self.Nodes[i] 
			end
		end
	end

	return self
end

function NodeTile.new(NodeName)
	local self = setmetatable({}, NodeTile)
	self.Name = NodeName
	self.Location = nil
	self.Neighbours = {}
	self.Hexes = {}
	self.Pathable = true

	-- An iterator for the neighbours
	function self.AllNeighbours()
		local i = 0
		local n = 6
		return function()
			i = i + 1
			if i <= n then 
				return self.Neighbours[i]
			end
		end
	end

	function self.AllHexes()
		local i = 0
		local n = 3
		return function()
			i = i + 1
			if i <= n then 
				while self.Hexes[i] == nil do 
					i = i + 1
					if i > n then return nil end
				end
				return self.Hexes[i]
			end
		end
	end

	return self
end

-- Deep Copy for a lua table
-- http://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
function copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end

-- Check if a set contains a key
-- http://stackoverflow.com/questions/2282444/how-to-check-if-a-table-contains-an-element-in-lua
function setContainsKey(set, key)
    return set[key] ~= nil
end

function ListContainsTile(list, tile)
	local tilename = tile.Name
	for _, t in pairs(list) do
		if t.Name == tilename then
			return true
		end
	end
	return false
end
