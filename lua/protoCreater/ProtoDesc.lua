
DataType = 
{
	"common",
	"class",
}

CommonDataType = 
{
	"int8",
	"int16",
	"int32",
	
	"uint8",
	"uint16",
	"uint32",
	
	"float",
	"double",
	
	"bool",
	"string8",
	"string",
}

DataContainerType = 
{
	"single",
	"array",
	"map",
}

local data = 
{
	className = "",

	[1] = {name = "", dataType = "", dataContainerType = "", keyCommonType = "", dataCommonType = "", dataClassType = ""},


}

--[[

4个字节包长度
2个字节协议号

1个字节字段号 255结束符



]]
