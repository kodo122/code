
local typeToEnum = 
{
	--["nil"] = 0,
	["boolean"] = "1",
	["number"] = "2",
	["string"] = "3",
	["table"] = "4",
}
local valToString = 
{
	--["nil"] = function (val)
	--	return ""
	--end,
	["1"] = function(val)
		return val and 0 or 1
	end,
	["2"] = function(val)
		--local str = tostring(number)
		return string.char(string.len(val)) .. val
	end,
	["3"] = function(val)
		local len = string.char(string.len(val))
		return string.char(string.len(len)) .. len .. val
	end,
}

function WriteVal(val, t)
	
	local typeVal = typeToEnum[type(val)]
	
	table.insert(t, typeVal)
	if typeVal == "4" then
		
		for k, v in pairs(val) do
			WriteVal(k, t)
			WriteVal(v, t)			
		end
		--type 6 meaning over this table
		table.insert(t, "9")	
	else
		table.insert(t, valToString[typeVal](val))
	end
end

function Serialize(val)
	
	local contents = {}
	WriteVal(val, contents)

	return table.concat(contents)
end


local strToVal = 
{
	["1"] = function(str, index)
		return string.char(str, index) == '1' and true or false, index + 1
	end,
	["2"] = function(str, index)
		local len = string.byte(string.sub(str, index, index))
		local val = tonumber(string.sub(str, index + 1, index + 1 + len - 1))
		return val, index + 1 + len
	end,
	["3"] = function(str, index)
		local lenlen = string.byte(string.sub(str, index, index))
		local len = string.byte(string.sub(str, index + 1, index + 1 + lenlen - 1))
		local val = string.sub(str, index + 1 + lenlen, index + 1 + lenlen + len - 1)
		return val, index + 1 + lenlen + len
	end,
}
function ReadVal(str, index)
	
	local typeVal = string.sub(str, index, index)
	index = index + 1

	if typeVal == "4" then
		
		local t = {}

		local count = 0
		local len = string.len(str)
		while index <= len do
		
			local keyTypeVal = string.sub(str, index, index)
			if keyTypeVal == "9" then
				return t, index + 1
			end
			
			local key, val
			key, index = ReadVal(str, index)
			val, index = ReadVal(str, index)
			t[key] = val
		end
	else
		return strToVal[typeVal](str, index)
	end
end
function Unserialize(str)
	return ReadVal(str, 1)
end


local testX = 
{
	a = "abc",
	b = 
	{
		c = 123,
	},
	[1] = 234,
	[2] = 456,
	[6664] = 1565464,
}
local testStr = Serialize(testX)
print(testStr)
print(string.len(testStr))
local t = Unserialize(testStr)
print(t[6664])
