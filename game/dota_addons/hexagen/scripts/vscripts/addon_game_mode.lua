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

	self:RegenHexes()

	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 1)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)

	local mode = GameRules:GetGameModeEntity() 
	mode:SetFogOfWarDisabled(true)	
	mode:SetCustomGameForceHero("npc_dota_hero_rattletrap")
	
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(CHexygenGameMode, "OnDotaPlayerPickHero"), self)
	CustomGameEventManager:RegisterListener( "change_length", Dynamic_Wrap(CHexygenGameMode, "OnChangeLengthSettings") )

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

	-- Call Hexagen
	local HexList = Hexagen:GenerateHexagonGrid(Vector(0, 0, 128), 64, self.PathWidth, self.LengthTable)

	local draw_time = 10
	local display = "both"

	if display == "hex" or display == "both" then

		-- Set some random hexes to unpathable
		for i = 1,10 do
			HexList["Hex_" .. i]["pathable"] = false
		end

		--HexList["Hex_" .. RandomInt(0, HexList["HexCount"])]["pathable"] = false

		-- Example Use of HexList
		for HexData in Hexagen:AllHexes(HexList) do

			local colour = Vector(255, 255, 255)
			if HexData["pathable"] == true then
				colour = Vector(0, 255, 0)

				for NeighbourNum, NeighbourName in pairs(HexData["neighbours"]) do
					local NeighbourData = HexList[NeighbourName]

					if NeighbourData["pathable"] == true then
						DebugDrawLine(HexData["location"], NeighbourData["location"], 0, 255, 0, true, draw_time)
					end
				end
			elseif HexData["pathable"] == false then
				colour = Vector(255, 0, 0)
			end
			
			DebugDrawCircle(HexData["location"], colour, 20, 64, true, draw_time)
		end
	end
	if display == "node" or display == "both" then

		-- Set some nodes to unpathable		
		for i = 1,30 do
			HexList["Node_" .. i]["pathable"] = false
		end

		--HexList["Node_" .. RandomInt(1, HexList["NodeCount"])]["pathable"] = false
		
		for NodeData in Hexagen:AllNodes(HexList) do

			local colour = Vector(255, 255, 255)
			if NodeData["pathable"] == true then
				colour = Vector(0, 255, 0)

				for _, NeighbourName in pairs(NodeData["neighbours"]) do
					local NeighbourData = HexList[NeighbourName]

					if NeighbourData["pathable"] == true then
						DebugDrawLine(NodeData["location"], NeighbourData["location"], 0, 255, 0, true, draw_time)
					end
				end
			elseif NodeData["pathable"] == false then
				colour = Vector(255, 0, 0)
			end

			DebugDrawCircle(NodeData["location"], colour, 20, 5, true, draw_time)	

		end
	end

	-- Spawn hexagons on every hex
	for HexData in Hexagen:AllHexes(HexList) do

		-- spawn a hexagon.
		table.insert(self.Hexygen_EntHexList, self:SpawnHex(HexData["location"]))
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

-- Evaluate the state of the game
function CHexygenGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )

	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end