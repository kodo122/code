
local _btHandler = 
{
	sequence = 
	{
		Start = function(self)
			self.index = 1
		end,
		Update = function(self)
			while true do
				
				if self.index > #self.nodes then
					return "success"
				end
				local ret = self.nodes[self.index]:Excute()
				
				if ret == "running" then
					return "running"
				end
				
				self.index = self.index + 1
			end
		end,
	},
	selectorLoop = 
	{
		Update = function(self)
			if not self.currNode then
				for _, v in ipairs(self.nodes) do
					if v:Excute() == "running" then
						self.currNode = v
						return "running"
					end
				end
			else
				if self.currNode:Excute() ~= "running" then
					self.currNode = nil
				end
			end
			return "running"
		end,
	},
	parallel  = 
	{
		Update = function(self)
			for _, v in ipairs(self.nodes) do
				v:Excute()
			end
			return "running"
		end,
	},
	
	-----------------------------------------------------------------------------
	
	runBtTree = 
	{
		Start = function(self)
			self.btTree = BehaviorTree:new(self.config.name)
		end,
		Update = function(self)
			return self.btTree:Excute()
		end,
	},
	
	createModule = 
	{
		Start = function(self)
			
			local config = self.config
			local module1 = _G[config.class]:new(config.param1, config.param2)
			_moduleManager:Push(module1, config.group)
			
			local parent = config.parent and _G[config.parent] or _G
			parent[config.name] = module1
		end,
	},
	
	overModuleGroup = 
	{
		Start = function(self)
			_moduleManager:OverGroup(self.config.group)
		end
	},
	
	-----------------------------------------------------------------------------
	runOneTime = 
	{
		Judge = function(self)
			if self.isRun then
				return "failure"
			end
			self.isRun = true
			return "success"
		end
	},
}
function PushBTHandler(name, handler)
	_btHandler[name] = handler
end

BtNode = {}
BtNode.__index = BtNode

function BtNode:new(config, data)
	
	local o = {}
	setmetatable(o, self)

	o.config = config
	o.data = data
	o.preconditions = {}
	o.conditions = {}
	o.nodes = {}
	o.isStart = false
	local handler = _btHandler[config.type]
	assert(handler)
	
	if config.preconditions then
		for _, v in ipairs(config.preconditions) do
			local node = BtNode:new(v, data)
			table.insert(o.preconditions, node)
		end		
	end
	print()
	if config.conditions then
		for _, v in ipairs(config.conditions) do
			local node = BtNode:new(v, data)
			table.insert(o.conditions, node)
			print("config.conditions")
		end		
	end
	if config.children then
		for _, v in ipairs(config.children) do
			local node = BtNode:new(v, data)
			table.insert(o.nodes, node)
		end
	end
	
	o.doInit = handler.Init
	o.Start = handler.Start
	o.Update = handler.Update
	o.End = handler.End
	o.Judge = handler.Judge
	
	return o
end

function BtNode:Init()
	if self.doInit then
		self:doInit()
	end
	for _, v in ipairs(self.nodes) do
		v:Init()
	end
end

function BtNode:Excute()
	
	local result = "success"
	if not self.isStart then

		for _, v in ipairs(self.preconditions) do
			if v:Judge() == "failure" then
				return "failure"
			end
		end
		if self.Start then
			self:Start()
		end
		self.isStart = true
	end
	for _, v in ipairs(self.conditions) do
		if v:Judge() == "failure" then
			self.isStart = false
			return "failure"
		end
	end
	if self.Update then
		result = self:Update()
	end
	if result == "success" or result == "failure" then
		if self.End then
			self:End()
		end
		self.isStart = false
	end
	return result
end


BehaviorTree = {}
BehaviorTree.__index = BehaviorTree

function BehaviorTree:new(configName, data)
	
	local o = {}
	setmetatable(o, self)
	
	o.config = GetBtConfig(configName)
	assert(o.config)
	o.data = data
	o.rootNode = BtNode:new(o.config, data)
	o.isOver = false
	
	return o
end

function BehaviorTree:Init()
	self.rootNode:Init()
end

function BehaviorTree:Update()
	
	if self.isOver then
		return
	end
	
	if self.rootNode:Excute() ~= "running" then
		self.isOver = true
	end
end

function BehaviorTree:IsOver()
	return self.isOver
end
