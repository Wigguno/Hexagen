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
	local HexList = Hexagen:GenerateHexagonGrid(Vector(0, 0, 128), 64, 32, self.LengthTable)

	local draw_time = 10

	-- Example Use of HexList
	for HexName, HexData in pairs(HexList) do 

		--DebugDrawCircle(HexData["location"], Vector(255, 255, 255), 20, HEX_RADIUS, true, draw_time)

		-- Draw lines to each neighbour
		for _, NeighbourName in pairs(HexData["neighbours"]) do
			local HexNeighbour = HexList[NeighbourName]
			DebugDrawLine(HexData["location"], HexNeighbour["location"], 255, 255, 255, true, draw_time) 
		end

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