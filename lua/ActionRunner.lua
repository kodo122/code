
ActionRunner = {}
ActionRunner.__index = ActionRunner

function ActionRunner:new(object)
	
	local o = {}
	setmetatable(o, self)
	
	o.actions = {}
	o.object = object
	
	return o
end

function ActionRunner:RunAction(action)
	self.actions[action] = action
	action:Start(self.object)
end

function ActionRunner:StopAction(action)
	if self.actions[action] then
		self.actions[action]:Over()
		self.actions[action] = nil
	end
end

function ActionRunner:Update()
	for key, val in pairs(self.actions) do
		val:Update()
		if val:IsOver() then
			self.actions[key] = nil
		end
	end
end

function ActionRunner:StopAllAction()
	self.actions = {}
end

