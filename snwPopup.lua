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

snw.dbg     = false
snw.v       = 'v0.1.5'
snw.Frame   = CreateFrame("Frame")
snw.Events  = {}

--[[
  colors:
  red,    b34343
  green,  4eb343
]]

-- UTILITY METHODS ---------------------------------------------------------- --

-- hackfix localisations into a table
-- no clue why ACE makes such a fuss about this¯\_(ツ)_/¯
local L = setmetatable({}, {__index = function(t, k)
  local v = tostring(k)
  rawset(t, k, v)
  return v
end})

L['true']   = '|cffb34343shown|r'
L['false']  = '|cffb34343hidden|r'

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
    snw:print('[...]')
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
    snw:print(v)
  end
end

-- SLASH HANDLER ------------------------------------------------------------ --

SLASH_SNWDBG1   = '/snwdbg'
SLASH_SNWLOOT1  = '/snwloot'
SLASH_SNWDE1    = '/snwde'
SLASH_SNWBIND1  = '/snwbind'

SlashCmdList['SNWDBG'] = function(...)
  if select('#', ...) > 1 then -- the user is an idiot
    snw.dbg = select(1, ...)
  else
    snw.dbg = ...
  end
  snw:print('debug set to ' .. snw.dbg)
end

SlashCmdList['SNWLOOT'] = function()
  snw.db.loot = not snw.db.loot
  snw:print('Loot popups are now ' .. L[snw.db.loot])
end

SlashCmdList['SNWDE'] = function()
  snw.db.de = not snw.db.de
  snw:print('DE popups are now ' .. L[snw.db.de])
end

SlashCmdList['SNWBIND'] = function()
  snw.db.bind = not snw.db.bind
  snw:print('bind popups are now ' .. L[snw.db.bind])
end

-- EVENTS ------------------------------------------------------------------- --

-- args: frame, ...
-- because consistency
function snw.Events:LOOT_BIND_CONFIRM(f, ...)
  if snw.db.bind then return end
  local id = ...
  if not id then id = 1 end

  ConfirmLootSlot(id)
  StaticPopup_Hide('LOOT_BIND')
end

function snw.Events:CONFIRM_LOOT_ROLL(...)
  if snw.db.loot then return end
  local id, rollType = ...

  ConfirmLootRoll(id, rollType)
  StaticPopup_Hide('CONFIRM_LOOT_ROLL')
end

function snw.Events:CONFIRM_DISENCHANT_ROLL(...)
  if snw.db.de then return end
  local id, rollType = ...

  ConfirmLootRoll(id, rollType)
  StaticPopup_Hide('CONFIRM_LOOT_ROLL')
end

function snw.Events:PLAYER_LOGIN(...)
  -- probably not even needed
end

function snw.Events:ADDON_LOADED(addon)
  if addon == 'snwPopup' then
    -- bruteforce, since neither StaticPopup_Hide,
    -- nor forcing StaticPopups table works
    -- UIParent:UnregisterEvent('CONFIRM_LOOT_ROLL')
    -- UIParent:UnregisterEvent('CONFIRM_DISENCHANT_ROLL')
    -- UIParent:UnregisterEvent('LOOT_BIND_CONFIRM')

    if snwDB then
      snw.db.loot = snwDB.loot
      snw.db.de   = snwDB.de
      snw.db.bind = snwDB.bind
    else
      snw:print('No db file found')
      snw:print('Default values set to |cffb34343hide all|r')
      snw.db.loot = false
      snw.db.de   = false
      snw.db.bind = false
    end
  end
end

function snw.Events:PLAYER_LOGOUT(...)
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
