
AnimationAction = {}
AnimationAction.__index = AnimationAction

function AnimationAction:new(name, fadeLength, isLoop, time)
	
	local o = {}
	setmetatable(o, self)

	o.name = name
	o.fadeLength = fadeLength or 0
	o.isLoop = isLoop
	o.time = time
	
	return o
end

function AnimationAction:Start(object)
	
	self.isOver = false
	self.object = object

	object:Play(self.name, self.isLoop, false, 1, self.fadeLength)
	if self.time then
		self.timer = STimer:new()
		self.timer:SetTimeOutTick(self.time)
		self.timer:Reset()
	end
end

function AnimationAction:Update()

	if self.isOver then
		return
	end

	--if self.timer and not self.timer:IsTimeOut() then
	--else
	---	self.isOver = true
	--end
	
	if (self.timer and self.timer:IsTimeOut()) or not self.object:IsPlaying() then
		self.isOver = true
	end
end

function AnimationAction:IsOver()
	return self.isOver
end

function AnimationAction:Over()
	self.isOver = true
end
