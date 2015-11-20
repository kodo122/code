
Net = {}
Net.__index = Net

function Net:new(socketId)
	
	local o = {}
	setmetatable(o, self)

	o.socketId = socketId

	return o
end

function Net:Init()
	return self.netHelper:Initialize(maxIoSize)
end

function Net:RegListener(ip, port, maxAcceptIoCount, maxAcceptEachWait)
	
end

function Net:Connect(ip, port)


end

function Net:Update()
	
	
	
end
