
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

	local contents = {}
	WriteVal(name, contents)
	local msg = Serialize(contents, ...)

	local str = table.concat(contents)
	--todo
	--self:OnMsg(name, msg)
end

function RPC:OnMsg(name, str)
	if self.funcs[name] then
		local t = Unserialize(str)
		self.funcs[name](unpack(t))
	end
end

function TestFunc(a, b, c)
	print(a)
	print(b)
	print(c)
end

local rpc = RPC:new()
rpc:Register("TestFunc", TestFunc)

rpc:Call("TestFunc", 1, "abc", 2.2)

