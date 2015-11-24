
PlayerData = {}
PlayerData.__index = PlayerData

function PlayerData:new()
	
	local o = {}
	setmetatable(o, self)
	
	return o
end
