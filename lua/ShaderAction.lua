
ShaderAction = {}
ShaderAction.__index = ShaderAction

function ShaderAction:new(key, startVal, endVal, type, time)
	
	local o = {}
	setmetatable(o, self)

	o.isOver = true
	
	o.key = key
	o.startVal = startVal
	o.endVal = endVal
	o.type = type

	o.timer = STimer:new()
	o.timer:SetTimeOutTick(time)
	o.timer:Reset()
	return o
end

function ShaderAction:Start(object)
	
	self.isOver = false
	self.object = object
	
	if self.type == "color" then
		self.object:SetShaderColor(self.key, self.startVal)
	elseif self.type == "float" then
		self.object:SetShaderFloat(self.key, self.startVal)
	else
		assert(nil)
	end
end

function ShaderAction:Update()
	
	if self.isOver then
		return
	end
	
	if self.timer:IsTimeOut() then
		
		if self.endVal then
			if self.type == "color" then
				self.object:SetShaderColor(self.key, self.endVal)
			elseif self.type == "float" then
				self.object:SetShaderFloat(self.key, self.endVal)
			end
		end		
		
		self.isOver = true
		return
	end
end

function ShaderAction:IsOver()
	return self.isOver
end

function ShaderAction:Over()

	if self.isOver then
		return
	end
	
	if self.endVal then
		if self.type == "color" then
			self.object:SetShaderColor(self.key, self.endVal)
		elseif self.type == "float" then
			self.object:SetShaderFloat(self.key, self.endVal)
		end
	end
	self.isOver = true
end
