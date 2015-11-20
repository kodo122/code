
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

				luaCode:AddSentence("buffer:WriteUInt16(#" .. data.name .. ")")

				luaCode:AddForIpair("self." .. data.name)
				luaCode:AddSentence(LuaDataCommonTypeFunc[data.dataCommonType].writeFunc(v))

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

				luaCode:AddSentence("local mapSizeBufferPos = buffer:GetWritePos()")
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
	
	stream =
	{
		single = 
		{
			newFunc = function(data, luaCode)
				luaCode:AddSentence("o." .. data.name .. " = " .. data.dataStreamType .. ":new()")
			end,		
			readFunc = function(data, luaCode)
				luaCode:AddSentence("self." .. data.name .. ":Unseialize(buffer)")
			end,
			writeFunc = function(data, luaCode)
				luaCode:AddSentence("self." .. data.name .. ":Seialize(buffer)")			
			end,
		},

		array = 
		{
			newFunc = function(data, luaCode)
				luaCode:AddSentence("o." .. data.name .. " = {}")
			end,
			readFunc = function(data, luaCode)
				
				luaCode:AddSentence("local count = buffer:ReadUint16()")
				
				luaCode:AddForI("count")
				luaCode:AddSentence("local v = " .. data.dataStreamType .. ":new()")
				luaCode:AddSentence("v:Unseialize(buffer)")		
				luaCode:AddSentence("self." .. data.name .. "[i] = v")
				
				luaCode:AddOverSection()			
			end,
			writeFunc = function(data, luaCode)
				
				luaCode:AddSentence("buffer:WriteUint16(#" .. data.name .. ")")

				luaCode:AddForIpair("self." .. data.name)
				luaCode:AddSentence("v:Seialize(buffer)")

				luaCode:AddOverSection()				
			end,	
		},
		
		map = 
		{
			newFunc = function(data, luaCode)
				luaCode:AddSentence("o." .. data.name .. " = {}")
			end,
			readFunc = function(data, luaCode)
				
				luaCode:AddSentence("local count = buffer:ReadUint16()")
				
				luaCode:AddForI("count")

				luaCode:AddSentence(LuaDataCommonTypeFunc[data.keyCommonType].readFunc("local key"))
				luaCode:AddSentence("local v = " .. data.dataStreamType .. ":new()")
				luaCode:AddSentence("v:Unseialize(buffer)")	
				luaCode:AddSentence("self." .. data.name .. "[key] = v")
				
				luaCode:AddOverSection()
			end,
			writeFunc = function(data, luaCode)
			
				luaCode:AddSentence("local mapSizeBufferPos = buffer:GetWritePos()")
				luaCode:AddSentence("local count = 0")
				
				luaCode:AddForPair("self." .. data.name)

				luaCode:AddSentence(LuaDataCommonTypeFunc[data.keyCommonType].writeFunc("k"))
				luaCode:AddSentence("v:Seialize(buffer)")
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
			return dataName .. " = 0"
		end,
		readFunc = function(dataName)
			return dataName .. " = buffer:ReadInt8()"
		end,
		writeFunc = function(dataName)
			return "buffer:WriteInt8(" .. dataName .. ")"
		end,
	},
	int16 = 
	{
	
	},
	int32 =
	{
	
	
	},
	
	uint8 = 
	{
	
	},
	uint16 = 
	{
	},
	uint32 =
	{
	
	},
	float =
	{
	},
	double = 
	{
	},
	
	bool = 
	{
	},
	string = 
	{
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

	for _, v in ipairs(dataDesc) do
		LuaDataTypeFunc[v.dataType][v.dataContainerType].newFunc(v, self.luaCode)
	end
	
	self.luaCode:AddOverSection()
end

function LuaCodeGenerator:GenerateDataSerializeFuncCode()
	
	local dataDesc = self.dataDesc

	self.luaCode:AddMethod("Serialize", {"buffer"})

	for k, v in ipairs(dataDesc) do
		
		assert(k < 255)
		self.luaCode:AddSentence("buffer:WriteUint8(" .. k .. ")")
		LuaDataTypeFunc[v.dataType][v.dataContainerType].writeFunc(v, self.luaCode)
	end
	
	self.luaCode:AddSentence("buffer:WriteUint8(255)")
	self.luaCode:AddOverSection()
end

function LuaCodeGenerator:GenerateDataUnserializeFuncCode()
	
	local dataDesc = self.dataDesc

	self.luaCode:AddMethod("Unserialize", {"buffer"})
	self.luaCode:AddWhile("true")

	self.luaCode:AddSentence("local _k")
	
	for k, v in ipairs(dataDesc) do
		
		self.luaCode:AddSentence("_k = buffer:ReadUint8()")
		
		self.luaCode:AddIf("not _k or _k ~= " .. k .. " or _k == 255")
		self.luaCode:AddSentence("break")
		self.luaCode:AddOverSection()
		
		LuaDataTypeFunc[v.dataType][v.dataContainerType].readFunc(v, self.luaCode)
	end
	
	self.luaCode:AddOverSection()
	self.luaCode:AddOverSection()	
end
