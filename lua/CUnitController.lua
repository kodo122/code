
UnitController = {}
UnitController.__index = UnitController

function UnitController:new(object)
	
	local o = {}
	setmetatable(o, self)

	o.object = object
	o.state = "none"
	
	return o
end

function UnitController:Idle()
	self.object:Play("idle_1", true, true)
	self.state = "idle"
end

function UnitController:MoveTo(pos, callback)
	
	self.state = "move"
	self.object:Play("move_1", true, true)
	
	local moveBy = cc.pSub(pos, self.object:GetPos())
	local action1 = MoveByAction:new(moveBy, IntervalTime:new(1))
	local action2 = FuncAction:new(callback)
	self.moveAction = SequenceAction:new(action1, action2)
	self.object.actionRunner:RunAction(self.moveAction)	
end

function UnitController:Aim()
	
	self.state = "aim"
end

function UnitController:Shoot()
	
	
	
	
end

