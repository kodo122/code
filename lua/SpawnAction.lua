
SpawnAction = {}
SpawnAction.__index = SpawnAction

function SpawnAction:new(...)
	
	local o = {}
	setmetatable(o, self)

	o.actions = {...}
	
	return o
end

function SpawnAction:Start(object)
	
	self.isOver = false
	self.object = object

	for _, v in pairs(self.actions) do
		v:Start(object)
	end
end

function SpawnAction:Update()

	if self.isOver then
		return
	end
	
	self.isOver = true
	for k, v in pairs(self.actions) do
		v:Update()
		
		if v:IsOver() then
			self.actions[k] = nil
		end
		self.isOver = false
	end
end

function SpawnAction:IsOver()
	return self.isOver
end

function SpawnAction:Over()
	self.isOver = true
end

