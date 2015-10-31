
ThingData = {}
ThingData.__index = ThingData

function ThingData:new()
	
	local o = {}
	setmetatable(o, self)

	return o
end
