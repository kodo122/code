
Net = {}
Net.__index = Net

function Net:new()
	
	local o = {}
	setmetatable(o, self)

	o.netHelper = NetHelper:new()
	o.sockets = {}

	return o
end

function Net:Init(maxIoSize)
	return self.netHelper:Initialize(maxIoSize)
end

function Net:RegListener(ip, port, maxAcceptIoCount, maxAcceptEachWait)
	
	local id = self.netHelper:RegListener(ip, port, maxAcceptIoCount, maxAcceptEachWait)
	if id == 0 then
		return nil
	end
	local socket = Socket:new(self, id)
	self.sockets[id] = socket
	
	return socket
end

function Net:Connect(ip, port)

	local id = self.netHelper:Connect(ip, port)
	if id == 0 then
		return nil
	end
	local socket = Socket:new(self, id)
	self.sockets[id] = socket
	
	return socket
end

function Net:Update()
	
	while true do
		local remoteNetEvent = self.netHelper:PopEvent()
		if not remoteNetEvent then
			break
		end

		local id = remoteNetEvent.id

		local netEvent = 
		{ 
			eventType = remoteNetEvent.eventType,
			errorCode = remoteNetEvent.errorCode,
		}

		if eventType == "recv" then
			netEvent.proto = remoteNetEvent.proto,
			netEvent.content = remoteNetEvent.content,
		then eventType == "accepted" then
			local socket = Socket:new(self, remoteNetEvent.newSocketId)
			self.sockets[id] = socket
			netEvent.newSocket = socket
		end
		
		local socket = self.sockets[id]
		assert(socket)
		
		socket:PushEvent(netEvent)
	end
end

function Net:CloseSocket(socket)
	self.netHelper:Close(socket.id)
	self[socket.id] = nil
end

