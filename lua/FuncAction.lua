
FuncAction = {}
FuncAction.__index = FuncAction

function FuncAction:new(func)
	
	local o = {}
	setmetatable(o, self)

	o.func = func

	return o
end

function FuncAction:Start(object)
	
	self.func(object)
	self.isOver = true
end

function FuncAction:Update()
	
	if self.isOver then
		return
	end
end

function FuncAction:IsOver()
	return self.isOver
end

function FuncAction:Over()
	self.isOver = true
end
