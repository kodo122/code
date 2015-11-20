
ShaderGraduallyAction = {}
ShaderGraduallyAction.__index = ShaderGraduallyAction

function ShaderGraduallyAction:new(key, startVal, endVal, intervalTime)
	
	local o = {}
	setmetatable(o, self)

	o.isOver = true
	
	o.key = key
	o.startVal = startVal
	o.endVal = endVal
	o.intervalTime = intervalTime

	return o
end

function ShaderGraduallyAction:Start(object)
	
	self.isOver = false
	self.object = object

	self.intervalTime:Start()
end

function ShaderGraduallyAction:Update()
	
	if self.isOver then
		return
	end
	
	local per = self.intervalTime:GetPercent()
		
	local val = self.startVal + (self.endVal - self.startVal) * per
	self.object:SetShaderFloat(self.key, val)
		
	if per == 1 then
		self.isOver = true
	end
end

function ShaderGraduallyAction:IsOver()
	return self.isOver
end

function ShaderGraduallyAction:Over()

	if self.isOver then
		return
	end
	
	self.isOver = true
end
