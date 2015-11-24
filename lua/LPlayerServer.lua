
PlayerServer = {}
PlayerServer.__index = PlayerServer

function PlayerServer:new()
	
	local o = {}
	setmetatable(o, self)

	return o
end

function PlayerServer:Init()
	
	self.net = Net:new()
	self.net:Init(1024)
	
	self.socket = self.net:RegListener("127.0.0.1", 7878, 1000, 10)
	self.netHandler = NetHandler:new(self.socket, nil, self)
end

function PlayerServer:Update()
	self.net:Update()
	self.netHandler:Update()
end

function PlayerServer:LateUpdate()
	self.net:LateUpdate()
end

function PlayerServer:OnAccept(socket)
	
	socket:RegRW()
	
	local player = Player:new(socket)
	player:Init()
	_playerManager:PushPlayer(player)
end



