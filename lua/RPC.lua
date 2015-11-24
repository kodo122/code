
RPC = {}
RPC.__index = RPC

function RPC:new()
	
	local o = {}
	setmetatable(o, self)

	o.funcs = {}
	o.callbacks = {}

	return o
end

function RPC:SetSocket(socket)
	self.socket = socket	
end

function RPC:Register(name, func)
	self.funcs[name] = func
end

function RPC:Call(name, callback, ...)

	if callback then
		self.callbacks[name] = callback
	end	
	local str = self:SerializeMsg(name, {...})
	if self.socket then
		self.socket:Send(1, str)
	end
end

function RPC:Callback(name, params)

	local str = self:SerializeMsg(name, params)
	if self.socket then
		self.socket:Send(2, str)
	end	
end

function RPC:OnCall(str)

	local funcName, params = self:Unserialize(str)
	
	local func = self.funcs[funcName]
	if not func then
		print("rpc call " .. funcName .. " not find")
		return
	end
	local result = {func(unpack(params))}
	if #result ~= 0 then
		self:Callback(funcName, result)
	end	
end

function RPC:OnCallback(str)

	local funcName, params = self:Unserialize(str)
	
	local func = self.callbacks[funcName]
	if not func then
		print("rpc callback " .. funcName .. " not find")
		return
	end
	func(unpack(params))
end

function RPC:SerializeMsg(name, params)
	
	local buffer = StringBuffer:new()
	local msg = SMsg:new(buffer)

	buffer:WriteString8(name)
	buffer:WriteUInt8(#params)

	for _, v in ipairs(params) do
		msg:WriteVal(v)
	end
	
	return buffer:ToString()
end

function RPC:Unserialize(str)
	
	local buffer = StringBuffer:new(str)
	local funcName = buffer:ReadString8()

	local paramCount = buffer:ReadUInt8()
	local params = {}
	local msg = SMsg:new(buffer)
	
	for i = 1, paramCount do
		local val = msg:ReadVal()
		table.insert(params, val)
	end
	return funcName, params
end
