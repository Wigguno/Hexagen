-- Example Hexagen use
-- By wiggnuo

if CHexygenGameMode == nil then
	_G.CHexygenGameMode = class({})
end

require ( "libraries/util" )
require ( "hexagen" )

function Precache( context )
	PrecacheResource( "model", "models/hexygen_props/hex_64.vmdl", context )
	PrecacheResource( "model", "models/hexygen_props/hex_064.vmdl", context )	
	PrecacheResource( "model", "models/hexygen_props/house.vmdl", context )
	PrecacheResource( "model", "models/hexygen_props/road.vmdl", context )

end

-- Create the game mode when we activate
function Activate()
	GameRules.HexyGen = CHexygenGameMode()
	GameRules.HexyGen:InitGameMode()
end

function CHexygenGameMode:InitGameMode()
	print( "Hexagen Example is loading..." )

	self.Hexygen_EntHexList = {}
	self.PathWidth = 32
	self.LengthTable = {}
	self.LengthTable[1] = 3
	self.LengthTable[2] = 2
	self.LengthTable[3] = 2
	self.LengthTable[4] = 3
	self.LengthTable[5] = 2
	self.LengthTable[6] = 2

	self.draw_pathing_hexes = false
	self.draw_pathing_nodes = false
	
	self:RegenHexes()

	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 1)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
	GameRules:SetPreGameTime(0)

	local mode = GameRules:GetGameModeEntity() 
	mode:SetFogOfWarDisabled(true)	
	mode:SetCustomGameForceHero("npc_dota_hero_rattletrap")
	
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(CHexygenGameMode, "OnDotaPlayerPickHero"), self)
	CustomGameEventManager:RegisterListener( "change_length", Dynamic_Wrap(CHexygenGameMode, "OnChangeLengthSettings") )
	CustomGameEventManager:RegisterListener( "draw_pathing", Dynamic_Wrap(CHexygenGameMode, "OnChangeDrawSettings") )
	CustomGameEventManager:RegisterListener( "toggle_hexlist_pathing", Dynamic_Wrap(CHexygenGameMode, "OnToggleHexListPathing") )
	CustomGameEventManager:RegisterListener( "pathing_query", Dynamic_Wrap(CHexygenGameMode, "OnPathingQuery") )
	CustomGameEventManager:RegisterListener( "request_hexlist", Dynamic_Wrap(CHexygenGameMode, "OnRequestHexList") )
	CustomGameEventManager:RegisterListener( "draw_neighbours", Dynamic_Wrap(CHexygenGameMode, "OnDrawNeighbours") )

	mode:SetThink( "OnThink", self, "GlobalThink", 2 )
	print( "Hexagen Example is loaded." )
end

-- On Dota Player Pick Hero
-- Fired when a player has picked a hero and loads into the game
function CHexygenGameMode:OnDotaPlayerPickHero(keys)
	--PrintTable(keys)
	local player 	= EntIndexToHScript(keys.player)
	local hero 		= EntIndexToHScript(keys.heroindex)

	hero:SetHullRadius(0)
	hero:SetAbilityPoints(0)
	hero:SetGold(0, false)
	hero:SetGold(0, true)
	hero:SetModel("models/development/invisiblebox.vmdl")
	hero:SetAbsOrigin(Vector(0, 0, 0))

	hero:FindAbilityByName("hero_hider"):SetLevel(1)

	for k, v in pairs(hero:GetChildren()) do
		if v:GetClassname() == "dota_item_wearable" then
			v:SetModel("models/development/invisiblebox.vmdl")
		end
	end
end

-- Function to reload the hex grid
function CHexygenGameMode:RegenHexes()

	-- Delete all the old hexes
	for _, hex in pairs(self.Hexygen_EntHexList) do
		hex:RemoveSelf()
	end

	self.Hexygen_EntHexList = {}
	self.DrawPath = nil -- reset the pathfinding path because the old indices will mean nothing
	self.drawNeighboursTarget = nil -- reset the draw neighbours target

	-- Call Hexagen
	self.TileList = Hexagen:GenerateHexagonGrid(Vector(0, 0, 128), 64, self.PathWidth, self.LengthTable)

	print("HexCount: " .. self.TileList.HexCount)
	print("NodeCount: " .. self.TileList.NodeCount)

	-- Send the list to panorama so it can do stuff with it
	CustomGameEventManager:Send_ServerToAllClients( "send_hexlist_to_client", self.TileList )

	-- Spawn hexagons on every hex
	for HexData in self.TileList:AllHexes() do

		-- spawn a hexagon.
		table.insert(self.Hexygen_EntHexList, self:SpawnHex(HexData.Location))
	end
end


-- Spawns a visual hex tile
-- Probably only used for this game mode
function CHexygenGameMode:SpawnHex(Location)

	local ent_hex = SpawnEntityFromTableSynchronous("prop_dynamic", {
		origin = Location,
		model = "models/hexygen_props/hex_064.vmdl",
		angles = Vector(0,  30, 0)
		})

	return ent_hex
end

-- Panorama Event 
-- Catches updated lengths fron the UI and regenerates
function CHexygenGameMode:OnChangeLengthSettings(keys)
	local mode = GameRules.HexyGen
	--print(keys.length_table)

	mode.LengthTable[1] = keys.length_table.A
	mode.LengthTable[2] = keys.length_table.B
	mode.LengthTable[3] = keys.length_table.C
	mode.LengthTable[4] = keys.length_table.D
	mode.LengthTable[5] = keys.length_table.E
	mode.LengthTable[6] = keys.length_table.F
	mode.PathWidth 		= keys.length_table.PW

	mode:RegenHexes()
end

function CHexygenGameMode:OnRequestHexList()
	local mode = GameRules.HexyGen
	-- Send the list to panorama so it can do stuff with it
	CustomGameEventManager:Send_ServerToAllClients( "send_hexlist_to_client", mode.TileList )
end

function CHexygenGameMode:OnChangeDrawSettings(keys)
	local mode = GameRules.HexyGen
	--PrintTable(keys)

	mode.draw_pathing_hexes = keys.hex
	mode.draw_pathing_nodes = keys.node
end

function CHexygenGameMode:OnToggleHexListPathing(keys)
	local mode = GameRules.HexyGen
	--PrintTable(keys)

	-- Toggle the pathable state of the passed index
	-- Panorama has already found the closest node to this point

	if mode.TileList.HexList[keys.ind] then
		if mode.TileList.HexList[keys.ind].Pathable == true then
			mode.TileList.HexList[keys.ind].Pathable = false
		elseif mode.TileList.HexList[keys.ind].Pathable == false then
			mode.TileList.HexList[keys.ind].Pathable = true
		end

	elseif mode.TileList.NodeList[keys.ind] then
		if mode.TileList.NodeList[keys.ind].Pathable == true then
			mode.TileList.NodeList[keys.ind].Pathable = false
		elseif mode.TileList.NodeList[keys.ind].Pathable == false then
			mode.TileList.NodeList[keys.ind].Pathable = true
		end

	end

end

function CHexygenGameMode:OnDrawNeighbours(keys)
	local mode = GameRules.HexyGen
	--PrintTable(keys)
	print("Got draw target: " .. keys.ind)
	mode.drawNeighboursTarget = keys.ind
end

function CHexygenGameMode:OnPathingQuery(keys)
	local mode = GameRules.HexyGen
	--PrintTable(keys)
	
	local PathIndList = mode.TileList:FindPath(keys.type, keys.start, keys.finish)

	if PathIndList == nil then
		print("path not found!")
	else
		print("Path found!")
	end
	mode.DrawPath = PathIndList

end

-- Evaluate the state of the game
function CHexygenGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		
	local draw_time = 1.00

	-- Draw the PathFinding path if there is one
	if self.DrawPath ~= nil then
		if self.TileList.HexList[self.DrawPath[1]] then

			local LastLoc = self.TileList.HexList[self.DrawPath[1]]
			for _, Name in pairs(self.DrawPath) do
				local Data = self.TileList.HexList[Name]
				DebugDrawLine(LastLoc.Location, Data.Location, 0, 0, 255, true, draw_time)
				LastLoc = Data
			end
		elseif self.TileList.NodeList[self.DrawPath[1]] then 

			local LastLoc = self.TileList.NodeList[self.DrawPath[1]]
			for _, Name in pairs(self.DrawPath) do
				local Data = self.TileList.NodeList[Name]
				DebugDrawLine(LastLoc.Location, Data.Location, 0, 0, 255, true, draw_time)
				LastLoc = Data
			end
		end
	end

	if self.drawNeighboursTarget ~= nil then
		local t = nil
		if self.TileList.HexList[self.drawNeighboursTarget] then
			t = self.TileList.HexList[self.drawNeighboursTarget]
			
			for n in t:AllNeighbours() do
				DebugDrawLine(t.Location, self.TileList.HexList[n].Location, 255, 255, 0, true, draw_time)
			end

		elseif self.TileList.NodeList[self.drawNeighboursTarget] then
			t = self.TileList.NodeList[self.drawNeighboursTarget]

			for n in t:AllNeighbours() do
				DebugDrawLine(t.Location, self.TileList.NodeList[n].Location, 255, 255, 0, true, draw_time)
			end
		end
	end

	if self.draw_pathing_hexes == 1 then

		-- Example Use of TileList
		for HexData in self.TileList:AllHexes() do

			-- Default to white
			local colour = Vector(255, 255, 255)

			-- if this hex is pathable
			if HexData.Pathable == true then

				-- draw it in green
				colour = Vector(0, 255, 0)

				-- and link it to it's neighbours (in green)
				for NeighbourName in HexData.AllNeighbours() do
					local NeighbourData = self.TileList.HexList[NeighbourName]

					-- only link to pathable neighbours
					if NeighbourData.Pathable == true then
						DebugDrawLine(HexData.Location, NeighbourData.Location, 0, 255, 0, true, draw_time)
					end
				end

			-- if it's not pathable then draw it in red, and don't link it to its neighbours
			elseif HexData.Pathable == false then
				colour = Vector(255, 0, 0)
			end
			
			-- draw the circle
			DebugDrawCircle(HexData.Location, colour, 20, 64, true, draw_time)
		end
	end

	if self.draw_pathing_nodes == 1 then
		-- loop over all nodes and do the same thing as hexes
		for NodeData in self.TileList:AllNodes() do

			local colour = Vector(255, 255, 255)
			if NodeData.Pathable == true then
				colour = Vector(0, 255, 0)

				for NeighbourName in NodeData.AllNeighbours() do
					local NeighbourData = self.TileList.NodeList[NeighbourName]

					if NeighbourData.Pathable == true then
						DebugDrawLine(NodeData.Location, NeighbourData.Location, 0, 255, 0, true, draw_time)
					end
				end
			elseif NodeData.Pathable == false then
				colour = Vector(255, 0, 0)
			end

			DebugDrawCircle(NodeData.Location, colour, 20, 5, true, draw_time)	
		end	
	end



	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end