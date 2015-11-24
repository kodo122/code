
LobbyConnector = {}
LobbyConnector.__index = LobbyConnector

function LobbyConnector:new()
	
	local o = {}
	setmetatable(o, self)

	o.net = Net:new()
	o.rpc = RPC:new()
	
	return o
end

function LobbyConnector:Init()
	self.net:Init(10)
	self.socket = self.net:Connect("127.0.0.1", 7878)
	self.netHandler = NetHandler:new(self.socket, self.rpc, self)
	self.rpc:SetSocket(self.socket)
end

function LobbyConnector:Update()
	
	self.net:Update()
	self.netHandler:Update()
end

function LobbyConnector:ConnectResult(errorCode)
	
	print("connectResult " .. errorCode)
	
	self.socket:RegRW()
	_login = Login:new()
	_login:Init()
end
