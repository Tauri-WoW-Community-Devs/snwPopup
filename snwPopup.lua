--[[
  snwPopup.lua
  extracted from snwUtility

  Author: snwflake
  Discord: snwflake#4516
  Gameversion: 5.4.8#18414
]]

-- REFS --------------------------------------------------------------------- --

local rawset = rawset
local select, pairs, type = select, pairs, type
local tostring = tostring

-- NAMESPACING -------------------------------------------------------------- --

local snw = {}

snw.dbg = false
snw.v = 'v0.1.5'
snw.Frame = CreateFrame("Frame")
snw.Events = {}
snw.storedDialogs = {}

-- UTILITY METHODS ---------------------------------------------------------- --

-- hackfix localisations into a table
-- no clue why ACE makes such a fuss about this¯\_(ツ)_/¯
local L = setmetatable({}, {__index = function(t, k)
  local v = tostring(k)
  rawset(t, k, v)
  return v
end})

function snw:debug(...)
  if not snw.dbg then return end
  print('|cffff8359' .. L['snwDebug'] .. ':|r', ...)
end

function snw:print(...)
  print('|cffff8359' .. L['snwUtil'] .. ':|r ', ...)
end

function snw:dmpTbl(t, i)
  if not snw.dbg then return end
  if "table" ~= type(t) then snw:debug(t) return end
  if not i then i = 0 end
  if i > 10 then
    snw:debug('[...]')
		return
	end
  for k, v in pairs(t) do
    local s = ''
		if i > 0 then
			for i = 0, i do
				s = s .. "    ";
			end
		end
		if "table" == type(v) then
			i = i + 1;
			snw:dmpTbl(v, i);
      i = i - 1;
    else
      s = s .. tostring(v)
    end
    snw:debug(v)
  end
end

-- SLASH HANDLER ------------------------------------------------------------ --

SLASH_SNWDBG1 = '/snwdbg'
SlashCmdList['SNWDBG'] = function(...)
  if select('#', ...) > 1 then -- the user is an idiot
    snw.dbg = select(1, ...)
  else
    snw.dbg = ...
  end
  snw:print('debug set to ' .. snw.dbg)
end

-- REMOVE CONFIRMATION DIALOG --------------------------------------------- --

function snw:nukeBind(forceHide)
  snw:debug('nukeBind')
  if not forceHide then return end

  StaticPopup_Hide('LOOT_BIND')
end

function snw:nukeRoll(forceHide)
  snw:debug('nukeRoll')
  if not forceHide then return end

  StaticPopup_Hide('CONFIRM_LOOT_ROLL')
end

-- EVENTS ------------------------------------------------------------------- --

-- args: frame, ...
-- because consistency
function snw.Events:LOOT_BIND_CONFIRM(f, ...)
  snw:dmpTbl(...)

  local id = ...
  if not id then id = 1 end
  ConfirmLootSlot(id)
  snw:debug('Confirmed loot with id: ' .. id)
  snw:nukeBind(true)
end

function snw.Events:CONFIRM_LOOT_ROLL(...)
  snw:dmpTbl(...)

  local id, rollType = ...
  ConfirmLootRoll(id, rollType)
  snw:debug('Roll for id: ' .. id .. ', type: ' .. rollType)
  snw:nukeRoll(true)
end

function snw.Events:CONFIRM_DISENCHANT_ROLL(...)
  snw:dmpTbl(...)

  local id, rollType = ...
  ConfirmLootRoll(id, rollType)
  snw:debug('DE roll for id: ' .. id .. ', type: ' .. rollType)
  snw:nukeRoll(true)
end

function snw.Events:PLAYER_LOGIN(...)
  snw:print(L["We up bois!"] .. ' ' .. snw.v)
end

function snw.Events:ADDON_LOADED(addon)
  snw:debug('Addon loaded ' .. addon)
  -- ????
  -- despite namespace, **all** addons pass this smh
  if addon == 'snwPopup' then
    -- bruteforce, since neither StaticPopup_Hide,
    -- nor forcing StaticPopups table works
    -- UIParent:UnregisterEvent('CONFIRM_LOOT_ROLL')
    -- UIParent:UnregisterEvent('CONFIRM_DISENCHANT_ROLL')
    -- UIParent:UnregisterEvent('LOOT_BIND_CONFIRM')

    if snwDB then
      -- iterate db and actually set values, cba
    else
      snw:debug('No db file found')
      -- set default values once there are actually some xd
    end
  end
end

function snw.Events:PLAYER_LOGOUT(...)
  snw:debug('Logout')
  snwDB = snw.db
end

-- REGISTER EVENTHANDLER ---------------------------------------------------- --

snw.Frame:SetScript('OnEvent', function(self, event, ...)
  snw.Events[event](self, ...)
end)

for k,v in pairs(snw.Events) do
  snw:debug('Registering Event ', k)
  snw.Frame:RegisterEvent(k)
end
