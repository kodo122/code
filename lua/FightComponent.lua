
FightComponent = {}
FightComponent.__index = FightComponent

function FightComponent:new(object)
	
	local o = {}
	setmetatable(o, self)
	
	o.object = object
	
	return o
end

function FightComponent:Init()
	self.gunpointRotationY = 0
	self.gunShakeRotationRange = 0
end

function FightComponent:AddShakeRotationX(val)
	self.shakeRotationX = val
	self.isRotationDirty = true
end

function FightComponent:AddShakeRotationY(val)
	self.shakeRotationY = val
	self.isRotationDirty = true
end
