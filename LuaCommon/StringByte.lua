
local typeToEnum = 
{
	--["nil"] = 0,
	boolean = "1",
	number = "2",
	["string"] = "3",
	table = "4",
}
local valToString = 
{
	--["nil"] = function (val)
	--	return ""
	--end,
	1 = function(val)
		return val and 0 or 1
	end,
	2 = function(val)
		local str = tostring(number)
		return str, string.len(str)
	end,
	3 = function(val)
		return val, string.len(val)
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

function serialize1(val)
	
	local contents = {}
	WriteVal(val, contents)

	return table.concat(contents)
end

local strToVal = 
{
	1 = function(str, index)
		return string.char(str, index) == 1 and true or false, 1
	end,
	2 = function(str, index)
		local len = string.char(str, index)
		local val = tonumber(string.sub(str, index + 1, len))
		return val, index + 1 + len
	end,
	3 = function(str, index)
		local len = string.char(str, index)
		local val = string.sub(str, index + 1, len)
		return val, index + 1 + len
	end,
}
function ReadVal(str, index)
	
	local typeVal = string.char(val, index)
	index = index + 1

	if typeVal == "4" then
		
		local keyTypeVal = string.char(str, index)
		local t = {}
		while keyTypeVal == "9" do
			
			local key, index = ReadVal(str, index)
			local val, index = ReadVal(str, index)
			t[key] = val

			keyTypeVal = string.char(str, index)
		end
		
		index = index + 1
		return t, index
	else
		return strToVal[typeVal](str, index)
	end
end