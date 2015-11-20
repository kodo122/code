

UpdateFuncAction = {}
UpdateFuncAction.__index = UpdateFuncAction

function UpdateFuncAction:new(func, time)
	
	local o = {}
	setmetatable(o, self)

	o.func = func
	o.isOver = true
	
	if time then
		o.timer = STimer:new()
		o.timer:SetTimeOutTick(time * 1000)
	end

	return o
end

function UpdateFuncAction:Start(object)
	
	self.isOver = false
	self.object = object

	if self.timer then
		self.timer:Reset()
	end
end

function UpdateFuncAction:Update()
	
	if self.isOver then
		return
	end
	
	if self.func(self.object) then
		self.isOver = true
		print("UpdateFuncAction over")
		return
	end
	
	if self.timer and self.timer:IsTimeOut() then
		self.isOver = true
	end
end

function UpdateFuncAction:IsOver()
	return self.isOver
end

function UpdateFuncAction:Over()
	self.isOver = true
end



