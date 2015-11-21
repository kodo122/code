
RPC = {}
RPC.__index = RPC

function RPC:new()
	
	local o = {}
	setmetatable(o, self)

	o.funcs = {}

	return o
end

function RPC:Register(name, func)
	self.funcs[name] = func
end

function RPC:Call(name, ...)

	local buffer = StringBuffer:new()
	local msg = SMsg:new(buffer)

	buffer:WriteString(name)
	
	local params = {...}
	
	buffer:WriteUInt8(#params)

	for _, v in ipairs(params) do
		msg:WriteVal(v)
	end
	
	local str = msg:ToString()

	--todo
	--self:OnMsg(name, msg)
end

function RPC:OnMsg(str)

	local buffer = StringBuffer:new(str)
	local funcName = buffer:ReadString()

	local paramCount = buffer:ReadUInt8()
	local params = {}
	local msg = SMsg:new(buffer)
	
	for i = 1, paramCount do
		local val = msg:ReadVal()
		table.insert(params, val)
	end
	
	local func = self.funcs[funcName]
	
	func(unpack(params))
end
