
RPC = {}
RPC.__index = RPC

function RPC:new()
	
	local o = {}
	setmetatable(o, self)

	o.funcs = {}

	return o
end