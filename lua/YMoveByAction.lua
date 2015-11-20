
YMoveByAction = {}
YMoveByAction.__index = YMoveByAction

function YMoveByAction:new(moveBy, intervalTime)
	
	local o = {}
	setmetatable(o, self)

	o.moveBy = moveBy
	o.isOver = true
	o.intervalTime = intervalTime
	
	return o
end

function YMoveByAction:Start(object)
	
	self.isOver = false
	self.object = object

	self.intervalTime:Start()
	self.startY = self.object:GetY()
end

function YMoveByAction:Update()

	if self.isOver then
		return
	end
	
	local per = self.intervalTime:GetPercent()
	local y = self.startY + self.moveBy * per
	self.object:SetY(y)

	if per == 1 then
		self.isOver = true
	end
end

function YMoveByAction:IsOver()
	return self.isOver
end

function YMoveByAction:Over()
	self.isOver = true
end
