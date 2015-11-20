
MoveByAction = {}
MoveByAction.__index = MoveByAction

function MoveByAction:new(moveBy, intervalTime)
	
	local o = {}
	setmetatable(o, self)

	o.moveBy = moveBy
	o.time = time
	o.isOver = true
	o.intervalTime = intervalTime

	return o
end

function MoveByAction:Start(object)
	
	self.isOver = false
	self.object = object
	
	self.intervalTime:Start()
	self.lastMoveBy = cc.p(0, 0)
	--self.startPosition = object:GetPos()
end

function MoveByAction:Update()
	
	if self.isOver then
		return
	end
	
	local per = self.intervalTime:GetPercent()
	local nowMoveBy = cc.pMul(self.moveBy, per)
	
	local pos = cc.pAdd(self.object:GetPos(), cc.pSub(nowMoveBy, self.lastMoveBy))
	self.object:SetPos(pos)

	self.lastMoveBy = nowMoveBy
	
	if per == 1 then
		self.isOver = true
	end
end

function MoveByAction:IsOver()
	return self.isOver
end

function MoveByAction:Over()
	self.isOver = true
end
