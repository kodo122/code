
ReadBuffer = {}
ReadBuffer.__index = ReadBuffer

function ReadBuffer:new(content)
	
	local o = {}
	setmetatable(o, self)
	
	o.content = content
	o.size = string.len(content)
	
	return o
end

function ReadBuffer:ReadInt8()
	
	
end

