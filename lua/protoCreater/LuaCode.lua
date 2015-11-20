
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
	
	local tabCount = self.stackCount
	if tabCount ~= 0 then
		tab = string.sub("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t", 1, tabCount)
		table.insert(self.content, tab)
	end
end

function LuaCode:AddClass(className)
	
	self.currClassName = className
	self:AddSentence(className .. " = {}" )
	self:AddSentence(className .. ".__index = " .. className)	
end

function LuaCode:AddMethod(methodName, params)
	
	params = params or {}
	
	local paramStr = ""
	for k, v in ipairs(params) do
		if k ~= 1 then
			paramStr = paramStr .. ", "
		end
		paramStr = paramStr .. v 
	end
	
	self:AddSentence(self.currClassName .. ":" .. methodName .. "(" .. paramStr .. ")")
	self.stackCount = self.stackCount + 1	
end

function LuaCode:AddIf(condition)

	self:AddSentence("if " .. condition .. " then")
	self.stackCount = self.stackCount + 1
end

function LuaCode:AddWhile(condition)

	self:AddSentence("while " .. condition .. " do")
	self.stackCount = self.stackCount + 1
end

function LuaCode:AddForIpair(containerName)
	
	self:AddSentence("for k, v in ipairs(" .. containerName .. ") do")
	self.stackCount = self.stackCount + 1
end

function LuaCode:AddForPair(containerName)
	
	self:AddSentence("for k, v in pairs(" .. containerName .. ") do")
	self.stackCount = self.stackCount + 1
end

function LuaCode:AddForI(max)
	
	self:AddSentence("for i = 1, " .. max .. " do")
	self.stackCount = self.stackCount + 1
end

function LuaCode:AddSentence(sentence)

	self:_AddTab()
	table.insert(self.content, sentence)
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
