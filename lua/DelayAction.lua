
DelayAction = {}
DelayAction.__index = DelayAction

function DelayAction:new(time)
	
	local o = {}
	setmetatable(o, self)

	o.timer = STimer:new()
	o.timer:SetTimeOutTick(time * 1000)

	return o
end

function DelayAction:Start(object)
	
	self.isOver = false
	self.object = object
	
	self.timer:Reset()
end

function DelayAction:Update()
	
	if self.isOver then
		return
	end
	
	if self.timer:IsTimeOut() then
		self.isOver = true
	end
end

function DelayAction:IsOver()
	return self.isOver
end

function DelayAction:Over()
	self.isOver = true
end
