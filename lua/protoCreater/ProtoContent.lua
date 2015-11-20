
ProtoData = {}
ProtoData.__index = ProtoData

function ProtoData:new()
	
	local o = {}
	setmetatable(o, self)


	return o
end




