
ChangeValAction = {}
ChangeValAction.__index = ChangeValAction

function ChangeValAction:new(func, changeVal, intervalTime)
	
	local o = {}
	setmetatable(o, self)

	o.func = func
	o.changeVal = changeVal
	o.isOver = true
	o.intervalTime = intervalTime

	return o
end

function ChangeValAction:Start(object)
	
	self.isOver = false
	self.object = object
	
	self.intervalTime:Start()
	self.lastChangeVal = 0
end

function ChangeValAction:Update()
	
	if self.isOver then
		return
	end
	
	local per = self.intervalTime:GetPercent()
	local nowChange = self.changeVal * per
	
	local changeVal = nowChange - self.lastChangeVal

	self.lastChangeVal = nowChange
	self.func(self.object, changeVal)
	
	if per == 1 then
		self.isOver = true
	end
end

function ChangeValAction:IsOver()
	return self.isOver
end

function ChangeValAction:Over()
	self.isOver = true
end
