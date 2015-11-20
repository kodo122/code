
EventManager = {}
EventManager.__index = EventManager

function EventManager:new()
	
	local o = {}
	setmetatable(o, self)
	
	o.ProtoTable = {}
	
	return o
end

function EventManager:Register(id, func)
	assert(id and func)
	self.ProtoTable[id] = self.ProtoTable[id] or {}
	self.ProtoTable[id][func] = { f = func }
end

function EventManager:Unregister(id, func)
	assert(id and func)
	self.ProtoTable[id] = self.ProtoTable[id] or {};
	self.ProtoTable[id][func] = nil
end

function EventManager:Push(id, v1, v2, v3)
	if self.ProtoTable[id] then
		for _, funcInfo in pairs(self.ProtoTable[id]) do
			funcInfo.f(v1, v2, v3)
		end
	end
end
