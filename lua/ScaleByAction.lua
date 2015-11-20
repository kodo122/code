
ScaleByAction = {}
ScaleByAction.__index = ScaleByAction

function ScaleByAction:new(scaleBy, intervalTime)
	
	local o = {}
	setmetatable(o, self)

	o.scaleBy = scaleBy
	o.time = time
	o.isOver = true
	o.intervalTime = intervalTime

	return o
end

function ScaleByAction:Start(object)
	
	self.isOver = false
	self.object = object
	
	self.intervalTime:Start()
	self.lastScaleBy = 0
end

function ScaleByAction:Update()
	
	if self.isOver then
		return
	end
	
	local per = self.intervalTime:GetPercent()
	local nowScaleBy = self.scaleBy * per
	
	local scale = self.object:GetScale() + nowScaleBy - self.lastScaleBy
	self.object:SetScale(scale)

	self.lastScaleBy = nowScaleBy
	
	if per == 1 then
		self.isOver = true
	end
end

function ScaleByAction:IsOver()
	return self.isOver
end

function ScaleByAction:Over()
	self.isOver = true
end
