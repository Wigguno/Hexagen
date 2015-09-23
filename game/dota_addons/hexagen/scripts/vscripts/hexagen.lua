-- Hexagen Generation Code
-- by wigguno

-- Using Cube coordinates by Amit Patel
-- http://www.redblobgames.com/grids/hexagons/

if Hexagen == nil then
	print("Loading Hexagen by wigguno")
	Hexagen = class({})
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
	-- HexList = Hexagen:GenerateHexagonGrid(Vector(0, 0, 128, 64, 32, {3, 2, 2, 3, 2, 2}))

	-- This is a distance used internally to set the distance between hexes
	local HexDistance = HexRadius + PathWidth
	
	-- Define our offset sizes for each direction
	-- This converts Cube Coordinates (A,B,C) into Cartesian Coordinates (X,Y)
	local HexOffset_A = Vector(	0, 		1, 		0) * HexDistance
	local HexOffset_B = Vector(	-0.85, 	-0.5, 	0) * HexDistance
	local HexOffset_C = Vector(	0.85, 	-0.5, 	0) * HexDistance

	-- set the center of the grid
	local CenterLocation = Vector(0, 0, 128)

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
				end
				HexTable[dim_1][dim_2][dim_3] = {}
			end
		end
	end

	-- A combination of these will set the direction to one of the 6 legs
	DirectionA = {0,   1,  1,  0, -1, -1}
	DirectionB = {1,   0, -1, -1,  0,  1}
	DirectionC = {-1, -1,  0,  1,  1,  0}

	-- Keep track of how many hexes we find, and name them sequentially
	local HexCount = 0

	-- Do the center hex manually
	local hex = {}
	hex["name"] = "Hex_" .. HexCount
	hex["location"] = CenterLocation
	hex["neighbours"] = {}

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
			hex["neighbours"] = {}

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
						hex["neighbours"] = {}
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
						hex["neighbours"] = {}
						HexTable[LeafA][LeafB][LeafC] = hex

					end
				end
			end -- end Leaf2 generation	
		end -- end Stepping down Legs
	end -- end Generation Loop


	-- Define a list that will store our hexes with named keys, and neighbour information
	local HexList = {}

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
								table.insert(hex["neighbours"], neighbour["name"])
							end
						end
					end

					-- put the hex into the list with it's name as a key
					-- neighbours can now look up its location from this list
					HexList[hex["name"]] = hex
				end
			end
		end
	end

	return HexList
end