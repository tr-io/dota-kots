-- Generated from template
RESPAWN_TIME = 5
MAX_KILLS = 50

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function CAddonTemplateGameMode:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	
	-- Setup rules
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetSameHeroSelectionEnabled( true )
	GameRules:SetHeroSelectionTime( 2.0 )
	GameRules:SetPreGameTime( 30.0 )
	GameRules:GetGameModeEntity():SetRecommendedItemsDisabled( true )
	GameRules:GetGameModeEntity():SetCameraDistanceOverride( 1350.0 )
	GameRules:GetGameModeEntity():SetBuybackEnabled( false )
	--GameRules:GetGameModeEntity():SetFogOfWarDisabled( true )
	print("LOL GAMERULES SET BROS")
	
	self.scoreDire = 0
	self.scoreRadiant = 0
	self.kills_to_win = 50
	
	GameRules:SetHeroSelectionTime( 0.0 )
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(CAddonTemplateGameMode, 'OnPlayerConnectFull'), self)
    GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	
	--ListenToGameEvent('entity_killed', Dynamic_Wrap(CAddon, 'OnEntityKilled'), self )
	ListenToGameEvent("entity_killed", Dynamic_Wrap(CAddonTemplateGameMode, "OnEntityKilled"), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(CAddonTemplateGameMode, 'OnNPCSpawned'), self)
	ListenToGameEvent('player_disconnect', Dynamic_Wrap(CAddonTemplateGameMode, 'OnDisconnect'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(CAddonTemplateGameMode, 'OnGameRulesStateChange'), self)
	
	Convars:RegisterCommand( "call1", function(...) return self:call1( ... ) end, "Function Call 1", FCVAR_CHEAT )
	Convars:RegisterCommand( "call2", function(...) return self:call2( ... ) end, "Function Call 2", FCVAR_CHEAT )
	Convars:RegisterCommand( "call3", function(...) return self:call3( ... ) end, "Function Call 3", FCVAR_CHEAT )
	Convars:RegisterCommand( "call4", function(...) return self:call4( ... ) end, "Function Call 4", FCVAR_CHEAT )
	
	self.bSeenWaitForPlayers = false
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheUnitByNameSync("npc_dota_hero_earth_spirit", context)
	PrecacheUnitByNameSync("npc_dota_hero_rattletrap", context)
	PrecacheUnitByNameSync("npc_dota_hero_dark_seer", context)
end

-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
	-- Reconnect heroes
    for _,hero in pairs( Entities:FindAllByClassname( "npc_dota_hero_earth_spirit")) do
        if hero:GetPlayerOwnerID() == -1 then
            local id = hero:GetPlayerOwner():GetPlayerID()
            if id ~= -1 then
                print("Reconnecting hero for player " .. id)
                hero:SetControllableByPlayer(id, true)
                hero:SetPlayerID(id)
            end
        end
    end

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function CAddonTemplateGameMode:OnPlayerConnectFull(keys)
    local player = PlayerInstanceFromIndex(keys.index + 1)
    print("Creating hero.")
    local hero = CreateHeroForPlayer('npc_dota_hero_earth_spirit', player)
end

function CAddonTemplateGameMode:OnEntityKilled(keys)
   local killedEntity = EntIndexToHScript(keys.entindex_killed)
   if killedEntity:IsRealHero() then
      GameRules:GetGameModeEntity():SetThink(
         function () killedEntity:RespawnHero(false, false, false) end,
         nil, RESPAWN_TIME)
		
		local playerDied = killedEntity:GetTeam()
		local playerDeathID = killedEntity:GetPlayerID();
		
		if playerDied == 2 then
			GameRules:SendCustomMessage("<font color='#58ACFA'>"..PlayerResource:GetPlayerName(playerDeathID).."</font> got wrecked!", 0, 0)
			RewardTeam(3)
			self.scoreDire = self.scoreDire + 1
			if self.scoreDire >= self.kills_to_win then
				GameRules:SetSafeToLeave( true )
				GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
			end
		elseif playerDied == 3 then
			GameRules:SendCustomMessage("<font color='#FF0000'>"..PlayerResource:GetPlayerName(playerDeathID).."</font> got wrecked!", 0, 0)
			RewardTeam(2)
			self.scoreRadiant = self.scoreRadiant + 1
			if self.scoreRadiant >= self.kills_to_win then
				GameRules:SetSafeToLeave( true )
				GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
			end
		else
			return
		end
		
		GameRules:GetGameModeEntity():SetTopBarTeamValue( DOTA_TEAM_BADGUYS, self.scoreDire )
		GameRules:GetGameModeEntity():SetTopBarTeamValue( DOTA_TEAM_GOODGUYS, self.scoreRadiant )
   end
end

function RewardTeam (teamID)
   for i = 0, 9, 1 do
      local player = PlayerResource:GetPlayer(i)

      if player and player:GetTeam() == teamID then
         -- Reward player here, e.g.:
         local hero = player:GetAssignedHero()
         if hero then
            hero:AddExperience(200, false)
			hero:SetGold(hero:GetGold() + 500, true)
			print("EZKATKA IT WORKED")
         end
      end
   end
end

function CAddonTemplateGameMode:OnNPCSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)
	
	if npc:IsRealHero() then
		if npc.bFirstSpawned == nil then
			npc.bFirstSpawned = true
			CAddonTemplateGameMode:OnHeroInGame(npc)
		else
			npc:AddNewModifier(npc, nil, "modifier_invulnerable", nil)
			GameRules:GetGameModeEntity():SetContextThink("invuln_timer", 
				function() 
				removeInvulnerability(npc) end, 3)
		end
	end
end

function removeInvulnerability(npc)
   npc:RemoveModifierByNameAndCaster("modifier_invulnerable", npc)
end

function CAddonTemplateGameMode:OnHeroInGame(hero)
	hero:SetGold(900, true)
	hero:AddNewModifier(hero, nil, "modifier_stunned", nil)
end

function CAddonTemplateGameMode:OnDisconnect(keys)
	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid
end

function CAddonTemplateGameMode:OnGameInProgress()
	local removeStun
	for i = 0, 9, 1 do
		removeStun = PlayerResource:GetPlayer(i)
		if removeStun ~= nil then
         local hero = removeStun:GetAssignedHero()
         hero:RemoveModifierByName("modifier_stunned")
      end
	end
end

function CAddonTemplateGameMode:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		self.bSeenWaitForPlayers = true
	elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
		ShowGenericPopup( "#kots_title", "#kots_instructions", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		CAddonTemplateGameMode:OnGameInProgress()
	end
end