
LuaDataTypeFunc = 
{
	common = 
	{
		single = 
		{
			newFunc = function(data, luaCode)
				luaCode:AddSentence(LuaDataCommonTypeFunc[data.dataCommonType].newFunc(data.name))
			end,
			readFunc = function(data, luaCode)
				luaCode:AddSentence(LuaDataCommonTypeFunc[data.dataCommonType].readFunc(data.name))
			end,
			writeFunc = function(data, luaCode)
				luaCode:AddSentence(LuaDataCommonTypeFunc[data.dataCommonType].writeFunc(data.name))			
			end,
		},

		array = 
		{
			newFunc = function(data, luaCode)
				luaCode:AddSentence("o." .. data.name .. " = {}")
			end,
			readFunc = function(data, luaCode)

				luaCode:AddSentence("local count = buffer:ReadUInt16()")
				
				luaCode:AddForI("count")
				luaCode:AddSentence(LuaDataCommonTypeFunc[data.dataCommonType].readFunc(data.name .. "[i]"))
				
				luaCode:AddOverSection()
			end,
			writeFunc = function(data, luaCode)

				luaCode:AddSentence("buffer:WriteUInt16(#self." .. data.name .. ")")

				luaCode:AddForIpair("self." .. data.name)
				luaCode:AddSentence(LuaDataCommonTypeFunc[data.dataCommonType].writeFunc("v"))

				luaCode:AddOverSection()			
			end,
		},
		
		map = 
		{
			newFunc = function(data, luaCode)
				luaCode:AddSentence("o." .. data.name .. " = {}")
			end,
			readFunc = function(data, luaCode)
				
				luaCode:AddSentence("local count = buffer:ReadUInt16()")
				
				luaCode:AddForI("count")

				luaCode:AddSentence(LuaDataCommonTypeFunc[data.keyCommonType].readFunc("local key"))
				luaCode:AddSentence(LuaDataCommonTypeFunc[data.dataCommonType].readFunc(data.name .. "[key]"))				
				
				luaCode:AddOverSection()
			end,
			writeFunc = function(data, luaCode)

				luaCode:AddSentence("local mapSizeBufferPos = buffer:WriteOccupy()")
				luaCode:AddSentence("local count = 0")
				
				luaCode:AddForPair("self." .. data.name)

				luaCode:AddSentence(LuaDataCommonTypeFunc[data.keyCommonType].writeFunc("k"))
				luaCode:AddSentence(LuaDataCommonTypeFunc[data.dataCommonType].writeFunc("v"))
				luaCode:AddSentence("count = count + 1")
				
				luaCode:AddOverSection()

				luaCode:AddSentence("buffer:WriteUint16ToPos(mapSizeBufferPos, count)")
			end,	
		},
	},
	
	class =
	{
		single = 
		{
			newFunc = function(data, luaCode)
				luaCode:AddSentence("o." .. data.name .. " = " .. data.dataClassType .. ":new()")
			end,		
			readFunc = function(data, luaCode)
				luaCode:AddSentence("self." .. data.name .. ":Unserialize(buffer)")
			end,
			writeFunc = function(data, luaCode)
				luaCode:AddSentence("self." .. data.name .. ":Serialize(buffer)")			
			end,
		},

		array = 
		{
			newFunc = function(data, luaCode)
				luaCode:AddSentence("o." .. data.name .. " = {}")
			end,
			readFunc = function(data, luaCode)
				
				luaCode:AddSentence("local count = buffer:ReadUInt16()")
				
				luaCode:AddForI("count")
				luaCode:AddSentence("local v = " .. data.dataClassType .. ":new()")
				luaCode:AddSentence("v:Unserialize(buffer)")		
				luaCode:AddSentence("self." .. data.name .. "[i] = v")
				
				luaCode:AddOverSection()			
			end,
			writeFunc = function(data, luaCode)
				
				luaCode:AddSentence("buffer:WriteUInt16(#self." .. data.name .. ")")

				luaCode:AddForIpair("self." .. data.name)
				luaCode:AddSentence("v:Serialize(buffer)")

				luaCode:AddOverSection()				
			end,	
		},
		
		map = 
		{
			newFunc = function(data, luaCode)
				luaCode:AddSentence("o." .. data.name .. " = {}")
			end,
			readFunc = function(data, luaCode)
				
				luaCode:AddSentence("local count = buffer:ReadUInt16()")
				
				luaCode:AddForI("count")

				luaCode:AddSentence(LuaDataCommonTypeFunc[data.keyCommonType].readFunc("local key"))
				luaCode:AddSentence("local v = " .. data.dataClassType .. ":new()")
				luaCode:AddSentence("v:Unserialize(buffer)")	
				luaCode:AddSentence("self." .. data.name .. "[key] = v")
				
				luaCode:AddOverSection()
			end,
			writeFunc = function(data, luaCode)
			
				luaCode:AddSentence("local mapSizeBufferPos = buffer:WriteOccupy()")
				luaCode:AddSentence("local count = 0")
				
				luaCode:AddForPair("self." .. data.name)

				luaCode:AddSentence(LuaDataCommonTypeFunc[data.keyCommonType].writeFunc("k"))
				luaCode:AddSentence("v:Serialize(buffer)")
				luaCode:AddSentence("count = count + 1")
				
				luaCode:AddOverSection()

				luaCode:AddSentence("buffer:WriteUint16ToPos(mapSizeBufferPos, count)")
			end,	
		},	
	},
}

LuaDataCommonTypeFunc = 
{
	int8 = 
	{
		newFunc = function(dataName)
			return "o." .. dataName .. " = 0"
		end,
		readFunc = function(dataName)
			return "self." .. dataName .. " = buffer:ReadInt8()"
		end,
		writeFunc = function(dataName)
			return "buffer:WriteInt8(self." .. dataName .. ")"
		end,
	},
	int16 = 
	{
		newFunc = function(dataName)
			return "o." .. dataName .. " = 0"
		end,
		readFunc = function(dataName)
			return "self." .. dataName .. " = buffer:ReadInt16()"
		end,
		writeFunc = function(dataName)
			return "buffer:WriteInt16(self." .. dataName .. ")"
		end,	
	},
	int32 =
	{
		newFunc = function(dataName)
			return "o." .. dataName .. " = 0"
		end,
		readFunc = function(dataName)
			return "self." .. dataName .. " = buffer:ReadInt32()"
		end,
		writeFunc = function(dataName)
			return "buffer:WriteInt32(self." .. dataName .. ")"
		end,
	},
	
	uint8 = 
	{
		newFunc = function(dataName)
			return "o." .. dataName .. " = 0"
		end,
		readFunc = function(dataName)
			return "self." .. dataName .. " = buffer:ReadUInt8()"
		end,
		writeFunc = function(dataName)
			return "buffer:WriteUInt8(self." .. dataName .. ")"
		end,
	},
	uint16 = 
	{
		newFunc = function(dataName)
			return "o." .. dataName .. " = 0"
		end,
		readFunc = function(dataName)
			return "self." .. dataName .. " = buffer:ReadUInt16()"
		end,
		writeFunc = function(dataName)
			return "buffer:WriteUInt16(self." .. dataName .. ")"
		end,
	},
	uint32 =
	{
		newFunc = function(dataName)
			return "o." .. dataName .. " = 0"
		end,
		readFunc = function(dataName)
			return "self." .. dataName .. " = buffer:ReadUInt32()"
		end,
		writeFunc = function(dataName)
			return "buffer:WriteUInt32(self." .. dataName .. ")"
		end,
	},
	float =
	{
		newFunc = function(dataName)
			return "o." .. dataName .. " = 0"
		end,
		readFunc = function(dataName)
			return "self." .. dataName .. " = buffer:ReadFloat()"
		end,
		writeFunc = function(dataName)
			return "buffer:WriteFloat(self." .. dataName .. ")"
		end,		
	},
	double = 
	{
		newFunc = function(dataName)
			return "o." .. dataName .. " = 0"
		end,
		readFunc = function(dataName)
			return "self." .. dataName .. "buffer:ReadDouble()"
		end,
		writeFunc = function(dataName)
			return "buffer:WriteDouble(self." .. dataName .. ")"
		end,
	},
	
	bool = 
	{
		newFunc = function(dataName)
			return "o." .. dataName .. " = false"
		end,
		readFunc = function(dataName)
			return "self." .. dataName .. " = buffer:ReadBool()"
		end,
		writeFunc = function(dataName)
			return "buffer:WriteBool(self." .. dataName .. ")"
		end,
	},
	
	string8 = 
	{
		newFunc = function(dataName)
			return "o." .. dataName .. " = \"\""
		end,
		readFunc = function(dataName)
			return "self." .. dataName .. " = buffer:ReadString8()"
		end,
		writeFunc = function(dataName)
			return "buffer:WriteString8(self." .. dataName .. ")"
		end,
	},
	
	["string"] = 
	{
		newFunc = function(dataName)
			return "o." .. dataName .. " = \"\""
		end,
		readFunc = function(dataName)
			return "self." .. dataName .. " = buffer:ReadString()"
		end,
		writeFunc = function(dataName)
			return "buffer:WriteString(self." .. dataName .. ")"
		end,		
	},
}



LuaCodeGenerator = {}
LuaCodeGenerator.__index = LuaCodeGenerator

function LuaCodeGenerator:new(dataDesc)
	
	local o = {}
	setmetatable(o, self)

	o.dataDesc = dataDesc
	o.luaCode = LuaCode:new()

	return o
end

function LuaCodeGenerator:GenerateDataCode()
	
	local dataDesc = self.dataDesc
	
	self.luaCode:AddClass(dataDesc.className)
	
	self:GenerateDataNewFuncCode()
	self:GenerateDataSerializeFuncCode()
	self:GenerateDataUnserializeFuncCode()
end

function LuaCodeGenerator:Code()
	return self.luaCode:ToString()
end

function LuaCodeGenerator:GenerateDataNewFuncCode()
	
	local dataDesc = self.dataDesc

	self.luaCode:AddMethod("new")

	self.luaCode:AddSentence("local o = {}")
	self.luaCode:AddSentence("setmetatable(o, self)")
	
	for _, v in ipairs(dataDesc) do
		LuaDataTypeFunc[v.dataType][v.dataContainerType].newFunc(v, self.luaCode)
	end
	
	self.luaCode:AddSentence("return o")	
	self.luaCode:AddOverSection()
end

function LuaCodeGenerator:GenerateDataSerializeFuncCode()
	
	local dataDesc = self.dataDesc

	self.luaCode:AddMethod("Serialize", {"buffer"})

	for k, v in ipairs(dataDesc) do
		
		assert(k < 255)
		self.luaCode:AddSentence("buffer:WriteUInt8(" .. k .. ")")
		LuaDataTypeFunc[v.dataType][v.dataContainerType].writeFunc(v, self.luaCode)
	end
	
	self.luaCode:AddSentence("buffer:WriteUInt8(255)")
	self.luaCode:AddOverSection()
end

function LuaCodeGenerator:GenerateDataUnserializeFuncCode()
	
	local dataDesc = self.dataDesc

	self.luaCode:AddMethod("Unserialize", {"buffer"})
	--self.luaCode:AddWhile("true")

	self.luaCode:AddSentence("local _k")
	
	for k, v in ipairs(dataDesc) do
		
		self.luaCode:AddSentence("_k = buffer:ReadUInt8()")
		
		self.luaCode:AddIf("_k == 255")
		self.luaCode:AddSentence("return")
		self.luaCode:AddOverSection()
		
		LuaDataTypeFunc[v.dataType][v.dataContainerType].readFunc(v, self.luaCode)
	end
	
	self.luaCode:AddOverSection()
end
