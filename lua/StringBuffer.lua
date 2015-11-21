
StringBuffer = {}
StringBuffer.__index = StringBuffer

function StringBuffer:new(str)
	
	local o = {}
	setmetatable(o, self)

	o.isError = false
	if str then
		o.str = str
		o.strLen = string.len(str)
		o.readIndex = 1
	else
		o.writeTable = {}
	end
	
	return o
end

function StringBuffer:ToString()
	return str or table.concat(self.writeTable)
end

function StringBuffer:ReadNumber()
	
	local readIndex = self.readIndex
	local str = self.str
	local strTotalLen = self.strLen

	local len = string.byte(str, readIndex)
	local val = tonumber(string.sub(str, readIndex + 1, readIndex + len))
	
	self.readIndex = readIndex + 1 + len
	
	return val		
end

function StringBuffer:ReadChar()
	readIndex = readIndex + 1
	return string.char(str, readIndex - 1)
end

function StringBuffer:ReadInt8()
	self:ReadNumber()
end

function StringBuffer:ReadInt16()
	self:ReadNumber()
end

function StringBuffer:ReadInt32()
	self:ReadNumber()
end

function StringBuffer:ReadUInt8()
	self:ReadNumber()
end

function StringBuffer:ReadUInt16()
	self:ReadNumber()
end

function StringBuffer:ReadUInt32()
	self:ReadNumber()
end

function StringBuffer:ReadFloat()
	self:ReadNumber()
end

function StringBuffer:ReadDouble()
	self:ReadNumber()
end

function StringBuffer:ReadBool()
	
	local readIndex = self.readIndex
	local str = self.str
	local strTotalLen = self.strLen
	
	local val = string.char(str, readIndex) == '1'
	self.readIndex = readIndex + 1
	
	return val
end

function StringBuffer:ReadString8()

	local readIndex = self.readIndex
	local str = self.str
	local strTotalLen = self.strLen

	--can't be 0
	local len = string.byte(str, readIndex) - 1
	local val = string.sub(str, readIndex + 1, readIndex + len)
	
	self.readIndex = readIndex + 1 + len
	
	return val			
end

function StringBuffer:ReadString()
	
	local readIndex = self.readIndex
	local str = self.str
	local strTotalLen = self.strLen
	
	local lenlen = string.byte(str, readIndex))
	readIndex = readIndex + 1
	local len = tonumber(string.sub(str, readIndex, readIndex + lenlen - 1))
	readIndex = readIndex + lenlen
	local val = string.sub(str, readIndex, readIndex + len - 1)

	self.readIndex = readIndex + len
	
	return val
end

function StringBuffer:WriteNumber(val)
	local writeTable = self.writeTable
	table.insert(writeTable, string.char(string.len(val)) .. val)
end

function StringBuffer:WriteChar(val)
	table.insert(self.writeTable, val)	
end

function StringBuffer:WriteInt8(val)
	self:WriteNumber(val)
end

function StringBuffer:WriteInt16(val)
	self:WriteNumber(val)
end

function StringBuffer:WriteInt32(val)
	self:WriteNumber(val)	
end

function StringBuffer:WriteUInt8(val)
	self:WriteNumber(val)
end

function StringBuffer:WriteUInt16(val)
	self:WriteNumber(val)
end

function StringBuffer:WriteUInt32(val)
	self:WriteNumber(val)
end

function StringBuffer:WriteFloat(val)
	self:WriteNumber(val)
end

function StringBuffer:WriteDouble(val)
	self:WriteNumber(val)
end

function StringBuffer:WriteBool(val)
	table.insert(writeTable, val and '1' or '0')
end

function StringBuffer:WriteString8(val)
	local writeTable = self.writeTable
	local len = string.char(string.len(val))
	table.insert(writeTable, len)
	table.insert(writeTable, val)	
end

function StringBuffer:WriteString(val)
	local writeTable = self.writeTable
	local len = string.len(val)
	table.insert(writeTable, string.char(string.len(len)))
	table.insert(writeTable, len)
	table.insert(writeTable, val)	
end

function StringBuffer:WriteUint16ToPos(pos, val)
	self.writeTable[pos] = string.char(string.len(val)) .. val
end

function StringBuffer:WriteOccupy()
	table.insert(self.writeTable, '1')
	return #writeTable
end
