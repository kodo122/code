
local oo = {
	--_size = 0, 
}

print(oo.__newindex)

oo.__newindex = function(t, k, v)
	print("nnn")
end

print(getmetatable(oo))
oo[1] = 3


function CreateContainerWithSize()
	
	local o = {
		--_size = 0, 
	}	
	--setmetatable(o, o)
	local mt = {
		_size = 0,
	}
	
	mt.__index = function(t, k)

		return 
	end
	
	mt.__newindex = function(t, k, v)
		if v and not t[k] then
			mt._size = mt._size + 1
		elseif not v and t[k] then
			mt._size = mt._size - 1
		end
		rawset(t, k, v)
	end
		
	mt.Size = function(t)
		
		print(mt._size)
		return mt._size
	end

	setmetatable(o, mt)	
	return o
end

local t = CreateContainerWithSize()

t[3] = 1
t[3] = 3
t.abc = "abcd"
t.abc = nil

--print("dabcd")
print(t.Size)


