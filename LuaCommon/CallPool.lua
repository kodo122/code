
CallPool = {}
CallPool.__index = CallPool

function CallPool:new()
	
	local o = {}
	setmetatable(o, self)

	return o
end

function CallPool:Init()

	self.callFuncTable = {}
	self.callTable ={}
	
	self.callFuncTable.SetGOPos = SetGOPos

	return 
end

function CallPool:Register(callFunc, retCallBack, ...)

	assert(self.callFuncTable[callFunc])
	
	table.insert(self.callFuncTable[callFunc], {param = {...}, callBack = retCallBack })
end

function CallPool:Update()
	
	
end

