
Gun = {}
Gun.__index = Gun

function Gun:new(object)
	
	local o = {}
	setmetatable(o, self)
	
	o.object = object
	
	return o
end

function Gun:Init()
	self.gunpointRotationX = 0
	self.gunpointRotationY = 0
	self.gunShakeRotationXMax = 5
	self.gunShakeRotationYMax = 20
end

function Gun:AddGunpointRotationX(val)
	self.gunpointRotationX = val
	self.isRotationDirty = true
end

function Gun:AddGunpointRotationY(val)
	self.gunpointRotationY = val
	self.isRotationDirty = true
end

function Gun:Update()
	
	if self.isRotationDirty then
		
		
	end	
end

function Gun:Shoot()
	
	
	
end
