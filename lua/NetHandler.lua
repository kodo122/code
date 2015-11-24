
NetHandler = {}
NetHandler.__index = NetHandler
NetHandler.handleFunc = 
{
	connect_result = function(self, event)
		self.handler:ConnectResult(event.errorCode)		
	end,
	accepted = function(self, event)
		self.handler:OnAccept(event.newSocket)
	end,	
	recv = function(self, event)
		if event.proto == 1 then
			self.rpc:OnCall(event.content)
		elseif event.proto == 2 then
			self.rpc:OnCallback(event.content)
		end
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
	
	local count = 0
	while true do
		
		local event = self.socket:PopEvent()		
		if not event then
			break
		end
		NetHandler.handleFunc[event.eventType](self, event)

		--todo for dbagent
		count = count + 1
		if count > 2000 then
			break
		end
	end
end


