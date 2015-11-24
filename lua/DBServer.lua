
DBServer = {}
DBServer.__index = DBServer

function DBServer:new()
	
	local o = {}
	setmetatable(o, self)

	o.users = {}

	return o
end

function DBServer:Init()
	
	self.net = Net:new()
	self.net:Init(1024)
	
	self.socket = self.net:RegListener("127.0.0.1", 7070, 1000, 10)
	self.netHandler = NetHandler:new(self.socket, nil, self)
end

function DBServer:Update()
	self.net:Update()
	self.netHandler:Update()

	for _, v in pairs(self.users) do
		v:Update()
	end
end

function DBServer:LateUpdate()
	self.net:LateUpdate()
end

function DBServer:OnAccept(socket)
	
	socket:RegRW()
	
	local user = User:new(socket)
	user:Init()
	
	self.users[user] = user
end

