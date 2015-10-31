
Pack = {}
Pack.__index = Pack

function Pack:new()
	
	local o = {}
	setmetatable(o, self)

	return o
end

function Pack:Init(packData)
	self.packData = packData
end

function Pack:PushThing(thing)
	
end

function Pack:PopThing(thing, count)

	for k, v in pairs(self.packData) do
		
		
		
	end
end
