
function include(path)
		
	require("lua/protoCreater/" .. path)
	
end

local files = 
{
	"ProtoDesc",
	"LuaCode",
	"LuaCodeGenerator",

	"RoleDataDesc",
}
for _, v in ipairs(files) do
	include(v)
end

local data = 
{
	className = "Test",

	[1] = {name = "name", dataType = "common", dataContainerType = "single", keyCommonType = "", dataCommonType = "int8", dataClassType = "", },
	[2] = {name = "pwd", dataType = "common", dataContainerType = "array", keyCommonType = "", dataCommonType = "int8", dataClassType = "", },
	[3] = {name = "age", dataType = "common", dataContainerType = "map", keyCommonType = "string", dataCommonType = "int8", dataClassType = "", },
}

local data1 = 
{
	className = "Fucker",

	[1] = {name = "taotao", dataType = "class", dataContainerType = "map", keyCommonType = "string", dataCommonType = "int8", dataClassType = "Test", },
}

isError = false
function MainInit()
		
	xpcall(
		function()
			
			io.output("./lua/RoleData.lua")
			for _, v in ipairs(playerDataDesc)  do
				local code = LuaCodeGenerator:new(v)
				code:GenerateDataCode()
				local str = code:Code()
				io.write(str)
			end
			io.flush()
			io.close()
		end,
		function(errorMsg)
			local errorStack = debug.traceback()
			MainError(errorMsg, errorStack)
		end
	)

	return true
end

function MainUpdate()
	
end

function MainLateUpdate()

end

function MainError(errorMsg, errorStack)
	print(errorMsg)
	print(errorStack)
	isError = true	
end
