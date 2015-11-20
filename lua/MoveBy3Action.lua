
MoveBy3Action = {}
MoveBy3Action.__index = MoveBy3Action

function MoveBy3Action:new(moveBy, intervalTime)
	
	local o = {}
	setmetatable(o, self)

	o.moveBy = moveBy
	o.time = time
	o.isOver = true
	o.intervalTime = intervalTime

	return o
end

function MoveBy3Action:Start(object)
	
	self.isOver = false
	self.object = object
	
	self.intervalTime:Start()
	self.lastMoveBy = cc.p3(0, 0, 0)
	--self.startPosition = object:GetPos()
end

function MoveBy3Action:Update()
	
	if self.isOver then
		return
	end
	
	local per = self.intervalTime:GetPercent()
	local nowMoveBy = cc.p3Mul(self.moveBy, per)
	
	local pos = cc.p3Add(self.object:GetPos3(), cc.p3Sub(nowMoveBy, self.lastMoveBy))
	self.object:SetPos3(pos)

	self.lastMoveBy = nowMoveBy
	
	if per == 1 then
		self.isOver = true
	end
end

function MoveBy3Action:IsOver()
	return self.isOver
end

function MoveBy3Action:Over()
	self.isOver = true
end
