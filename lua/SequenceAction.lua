
SequenceAction = {}
SequenceAction.__index = SequenceAction

function SequenceAction:new(...)
	
	local o = {}
	setmetatable(o, self)

	o.actions = {...}
	
	return o
end

function SequenceAction:new1(actions)
	
	local o = {}
	setmetatable(o, self)

	o.actions = actions
	
	return o
end

function SequenceAction:Start(object)
	
	self.isOver = false
	self.object = object

	self.currActionIndex = 1
	self.actions[1]:Start(object)
end

function SequenceAction:Update()

	if self.isOver then
		return
	end
	
	self.actions[self.currActionIndex]:Update()
	
	if self.actions[self.currActionIndex]:IsOver() then
		self.currActionIndex = self.currActionIndex + 1
	
		if self.actions[self.currActionIndex] then
			self.actions[self.currActionIndex]:Start(self.object)
		else
			self.isOver = true
		end
	end
end

function SequenceAction:IsOver()
	return self.isOver
end

function SequenceAction:Over()
	self.isOver = true
end

