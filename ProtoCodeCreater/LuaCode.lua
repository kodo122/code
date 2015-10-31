
LuaCode = {}
LuaCode.__index = LuaCode

function LuaCode:new()
	
	local o = {}
	setmetatable(o, self)

	o.content = {}
	o.stackCount = 0

	return o
end

function LuaCode:_AddTab()
	
	local tabCount = #self.currStack
	if tabCount ~= 0 then
		tab = string.sub("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t", 1, tabCount)
		table.insert(self.content, tab)
	end
end

function LuaCode:AddClass(className)
	
	self.currClassName = className
	self:AddSentense(o.className .. " = {}" )
	self:AddSentense(o.className .. ".__index = " .. o.className)	
end

function LuaCode:AddMethod(methodName, params)
	
	self:AddSentense(self.currClassName .. ":" .. methodName .. "(" .. params .. ")")
	self.stackCount = self.stackCount + 1	
end

function LuaCode:AddIf(condition)

	self:AddSentense("if " .. condition .. " then")
	self.stackCount = self.stackCount + 1
end

function LuaCode:AddWhile(condition)

	self:AddSentense("while " .. condition .. " do")
	self.stackCount = self.stackCount + 1
end

function LuaCode:AddForIpair(containerName)
	
	self:AddSentense("for k, v in ipairs(" .. containerName .. ") do")
	self.stackCount = self.stackCount + 1
end

function LuaCode:AddForPair(containerName)
	
	self:AddSentense("for k, v in pairs(" .. containerName .. ") do")
	self.stackCount = self.stackCount + 1
end

function LuaCode:AddForI(max)
	
	self:AddSentense("for i = 1, " .. max .. " do")
	self.stackCount = self.stackCount + 1
end

function LuaCode:AddSentense(sentense)

	self:_AddTab()
	table.insert(self.content, sentense)
	table.insert(self.content, "\n")
end

function LuaCode:AddOverSection()
	
	self.stackCount = self.stackCount - 1
	self:_AddTab()
	table.insert(self.content, "end\n")	
end

function LuaCode:ToString()
	return table.concat(self.content)
end
