
NetHandler = {}
NetHandler.__index = NetHandler
NetHandler.handleFunc = 
{
	connect_result = function(self, event)
		self.handler:ConnectResult()		
	end,
	accepted = function(self, event)
		self.handler:OnAccept(event.newSocket)
	end,	
	recv = function(self, event)
		rpc:OnMsg(event.content)
	end,
	disconnect = function(self, event)
		self.handler:OnDisconnect()
	end,
	error = function(self, event)
		self.handler:OnError()
	end,
}

function NetHandler:new(socket, rpc, handler)
	
	local o = {}
	setmetatable(o, self)

	o.socket = socket
	o.rpc = rpc
	o.handler = handler

	return o
end

function NetHandler:Update()
	
	while true do
		
		local event = self.socket
		if not event then
			break
		end
		NetHandler.handleFunc(self, event)
	end
end


