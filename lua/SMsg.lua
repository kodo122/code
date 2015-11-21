
local typeToEnum = 
{
	--["nil"] = 0,
	["boolean"] = "1",
	["number"] = "2",
	["string"] = "3",
	["table"] = "4",
}

SMsg = {}
SMsg.__index = SMsg

function SMsg:new(buffer)
	
	local o = {}
	setmetatable(o, self)

	o.buffer = buffer

	return o
end

function SMsg:WriteVal(val)
	
	local buffer = self.buffer
	local typeVal = typeToEnum[type(val)]
	
	buffer:WriteChar(typeVal)
	if typeVal == '1' then
		buffer:WriteBool(val)
	elseif typeVal == '2' then
		buffer:WriteNumber(val)
	elseif typeVal == '3' then
		buffer:WriteString(val)
	elseif typeVal == '4' then
		if val.Serialize then
			val:Serialize(buffer)
		else
			for k, v in pairs(val) do
				SMsg:WriteVal(k)
				SMsg:WriteVal(v)
			end		
		end
		--type 9 meaning over this table
		buffer:WriteChar('9')
	else
		assert()
	end
end

function SMsg:ReadVal()

	local buffer = self.buffer
	local typeVal = buffer:ReadChar()

	if typeVal == '1' then
		return buffer:ReadBool()
	elseif typeVal == '2' then
		return buffer:ReadNumber()
	elseif typeVal == '3' then
		return buffer:ReadString()
	elseif typeVal == '4' then

		local t = {}
		while true do
			local keyTypeVal = buffer:ReadChar()
			if keyTypeVal == '9' then
				return t
			end
			local key, val
			local key = self:ReadVal()
			local val = self:ReadVal()
			t[key] = val
		end
	end
end

