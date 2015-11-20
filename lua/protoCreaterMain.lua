
function include(path)
		
	require("protoCreater//" .. path)
	
end

local files = 
{
	"ProtoDesc",
	"LuaCode",
	"LuaCodeGenerator",

}

for _, v in ipairs(files) do
	include(v)
end

isError = false
function MainInit()
	
	xpcall(
		function()

		end,
		function()
			local msg = debug.traceback()
			MainError(msg)
		end
	) 

	return true
end

function MainUpdate()
	
	if isError then
		return
	end
	
	xpcall(
		function()

		end,
		function()
			local msg = debug.traceback()
			MainError(msg)
		end
	) 
end

function MainError(errorMsg)
	
	print(errorMsg)
	isError = true
end
