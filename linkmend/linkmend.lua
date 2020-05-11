-- Link localization functions
local function LocalizeItemLink(msg)
	return gsub(msg, "|c(%x+)|Hitem:(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*)[:0-9]*|h%[(.-)%]|h|r", function(color, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, name)
		if suffixId == "0" then
			name = GetItemInfo(itemId) or name
			return link or format("|c%s|Hitem:%s:%s:%s:%s:%s:%s:%s:%s|h[%s]|h|r", color, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, name)
		else
			name = GetItemInfo(format("item:%s:0:0:0:0:0:%s", itemId, suffixId)) or name
			return format("|c%s|Hitem:%s:%s:%s:%s:%s:%s:%s:%s|h[%s]|h|r", color, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, name)
		end
	end)
end

local function LocalizeSpellLink(msg)
	return gsub(msg, "|c(%x+)|Hspell:(%d*)[:0-9]*|h%[(.-)%]|h|r", function(color, spellId, name)
		local link = GetSpellLink(spellId)
		return link or format("|c%s|Hspell:%s|h[%s]|h|r", color, spellId, name)
	end)
end

local function LocalizeEnchantLink(msg)
	return gsub(msg, "|c(%x+)|Henchant:(%d*)[:0-9]*|h%[(.-)%]|h|r", function(color, spellId, name)
		name = GetSpellInfo(spellId) or name
		return format("|c%s|Henchant:%s|h[%s]|h|r", "ffffd100", spellId, name)
	end)
end

local pfQuest = (IsAddOnLoaded("pfQuest") or IsAddOnLoaded("pfQuest-tbc")) and pfDB["quests"][GetLocale()]

local function LocalizeQuestLink(msg)
	return gsub(msg, "|c(%x+)|Hquest:(%d*):(%d*)[:0-9]*|h%[(.-)%]|h|r", function(color, questId, questLevel, name)
		questId = tonumber(questId)
		name = pfQuest[questId] and pfQuest[questId]["T"] or name
		return format("|c%s|Hquest:%s:%s|h[%s]|h|r", color, questId, questLevel, name)
	end)
end

-- CLINK removal borrowed from pfUI/modules/chat.lua by shagu
for i = 1, NUM_CHAT_WINDOWS do
	if not _G["ChatFrame"..i].HookAddMessageForLinkmend then
		_G["ChatFrame"..i].HookAddMessageForLinkmend = _G["ChatFrame"..i].AddMessage
		_G["ChatFrame"..i].AddMessage = function(frame, msg, a1, a2, a3, a4, a5)
			if msg then
				-- Remove Prat CLINKs
				msg = gsub(msg, "{CLINK:(%x+):([%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r")

				-- Remove Chatter CLINKs
				msg = gsub(msg, "{CLINK:item:(%x+):([%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r")
				msg = gsub(msg, "{CLINK:enchant:(%x+):([%d-]-):([^}]-)}", "|c%1|Henchant:%2|h[%3]|h|r")
				msg = gsub(msg, "{CLINK:spell:(%x+):([%d-]-):([^}]-)}", "|c%1|Hspell:%2|h[%3]|h|r")
				msg = gsub(msg, "{CLINK:quest:(%x+):([%d-]-):([%d-]-):([^}]-)}", "|c%1|Hquest:%2:%3|h[%4]|h|r")

				-- Send link to be localized
				if strfind(msg, "|Hitem:(.-)|h") then
					msg = LocalizeItemLink(msg)
				elseif strfind(msg, "|Hspell:(.-)|h") then
					msg = LocalizeSpellLink(msg)
				elseif strfind(msg, "|Henchant:(.-)|h") then
					msg = LocalizeEnchantLink(msg)
				elseif pfQuest and strfind(msg, "|Hquest:(.-)|h") then
					msg = LocalizeQuestLink(msg)
				end

				_G["ChatFrame"..i].HookAddMessageForLinkmend(frame, msg, a1, a2, a3, a4, a5)
			end
		end
	end
end
