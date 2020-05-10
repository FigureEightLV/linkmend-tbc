-- Link localization functions
local function LocalizeItemLink(msg)
	local id = select(3, strfind(msg, "item:(%d+)"))
	local link = id and select(2, GetItemInfo(id))

	if link then
		msg = gsub(msg, "|c(%x+)|Hitem:([%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-)|h%[(.-)%]|h|r", link)
	end

	return msg
end

local function LocalizeSpellLink(msg)
	local id = select(3, strfind(msg, "spell:(%d+)"))
	local link = id and GetSpellLink(id)

	if link then
		msg = gsub(msg, "|c(%x+)|Hspell:([%d-]-)|h%[(.-)%]|h|r", link)
	end

	return msg
end

local function LocalizeEnchantLink(msg)
	local id = select(3, strfind(msg, "enchant:(%d+)"))
	local name = id and GetSpellInfo(id)
	local link = name and format("|cffffd100|Henchant:%s|h[%s]|h|r", id, name)

	if link then
		msg = gsub(msg, "|c(%x+)|Henchant:([%d-]-)|h%[(.-)%]|h|r", link)
	end

	return msg
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
				end

				_G["ChatFrame"..i].HookAddMessageForLinkmend(frame, msg, a1, a2, a3, a4, a5)
			end
		end
	end
end
