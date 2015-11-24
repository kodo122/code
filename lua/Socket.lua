
Socket = {}
Socket.__index = Socket

function Socket:new(net, id)
	
	local o = {}
	setmetatable(o, self)

	o.net = net
	o.netHelper = net.netHelper
	o.id = id
	o.events = {}
	o.eventReadIndex = 1

	return o
end

function Socket:PushEvent(event)
	table.insert(self.events, event)
end

function Socket:PopEvent()
	local eventCount = #self.events
	if eventCount == 0 then
		return nil
	end

	local event = self.events[self.eventReadIndex]
	
	if self.eventReadIndex == eventCount then
		self.eventReadIndex = 0
		self.events = {}
	else
		self.eventReadIndex = self.eventReadIndex + 1
	end
	
	return event
end

function Socket:Send(proto, msg)
	self.netHelper:SendString(self.id, proto, msg, string.len(msg))
end

function Socket:RegRW()
	self.netHelper:RegRW(self.id, 65535, true)
end

function Socket:Close()
	self.net:CloseSocket(self)
	self.events = {}
	self.eventReadIndex = 1
end
