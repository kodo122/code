
local moduleGroup = 
{
	[1] = "global",
	[2] = "loading",
	[3] = "scene",
}

ModuleManager = {}
ModuleManager.__index = ModuleManager

function ModuleManager:new()
	
	local o = {}
	setmetatable(o, self)
	
	o.modules = {}
	for _, v in ipairs(moduleGroup) do
		o.modules[v] = {}
	end
	
	return o
end

function ModuleManager:Push(m, group)
	
	--todo
	if m.Init then
		m:Init()
	end
	if m.Start then
		m:Start()
	end

	assert(self.modules[group])
	table.insert(self.modules[group], m)
end

--[[
function ModuleManager:Start()
	
	for k1, g in pairs(self.modules) do	
		for k2, val in ipairs(g) do
			if val.Start then
				val:Start()
			end
		end
	end
end
]]
function ModuleManager:Release()
	
	for k1, g in pairs(self.modules) do	
		for k2, val in ipairs(g) do
			if val.Release then
				val:Release()
			end
		end
	end
	self.modules = {}
end

function ModuleManager:Update()
	
	for k1, g in pairs(moduleGroup) do	
		for k2, val in ipairs(self.modules[g]) do
			if val.Update then
				val:Update()
			end
		end
	end	
end

function ModuleManager:OverGroup(group)
	
	for _, v in ipairs(self.modules[group]) do
		if v.Release then
			v:Release()
		end
	end
	
	self.modules[group] = {}
end

_moduleManager = ModuleManager:new()
