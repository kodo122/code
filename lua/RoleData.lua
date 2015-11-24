RoleData = {}
RoleData.__index = RoleData
function RoleData:new()
	local o = {}
	setmetatable(o, self)
	o.base = RoleBaseData:new()
	o.backpack = BackpackData:new()
	o.equipBar = EquipBarData:new()
	o.task = TaskData:new()
	return o
end
function RoleData:Serialize(buffer)
	buffer:WriteUInt8(1)
	self.base:Serialize(buffer)
	buffer:WriteUInt8(2)
	self.backpack:Serialize(buffer)
	buffer:WriteUInt8(3)
	self.equipBar:Serialize(buffer)
	buffer:WriteUInt8(4)
	self.task:Serialize(buffer)
	buffer:WriteUInt8(255)
end
function RoleData:Unserialize(buffer)
	local _k
	_k = buffer:ReadUInt8()
	if _k == 255 then
		return
	end
	self.base:Unserialize(buffer)
	_k = buffer:ReadUInt8()
	if _k == 255 then
		return
	end
	self.backpack:Unserialize(buffer)
	_k = buffer:ReadUInt8()
	if _k == 255 then
		return
	end
	self.equipBar:Unserialize(buffer)
	_k = buffer:ReadUInt8()
	if _k == 255 then
		return
	end
	self.task:Unserialize(buffer)
end
RoleBaseData = {}
RoleBaseData.__index = RoleBaseData
function RoleBaseData:new()
	local o = {}
	setmetatable(o, self)
	o.lvl = 0
	return o
end
function RoleBaseData:Serialize(buffer)
	buffer:WriteUInt8(1)
	buffer:WriteInt8(self.lvl)
	buffer:WriteUInt8(255)
end
function RoleBaseData:Unserialize(buffer)
	local _k
	_k = buffer:ReadUInt8()
	if _k == 255 then
		return
	end
	self.lvl = buffer:ReadInt8()
end
BackpackData = {}
BackpackData.__index = BackpackData
function BackpackData:new()
	local o = {}
	setmetatable(o, self)
	return o
end
function BackpackData:Serialize(buffer)
	buffer:WriteUInt8(255)
end
function BackpackData:Unserialize(buffer)
	local _k
end
EquipBarData = {}
EquipBarData.__index = EquipBarData
function EquipBarData:new()
	local o = {}
	setmetatable(o, self)
	return o
end
function EquipBarData:Serialize(buffer)
	buffer:WriteUInt8(255)
end
function EquipBarData:Unserialize(buffer)
	local _k
end
TaskData = {}
TaskData.__index = TaskData
function TaskData:new()
	local o = {}
	setmetatable(o, self)
	return o
end
function TaskData:Serialize(buffer)
	buffer:WriteUInt8(255)
end
function TaskData:Unserialize(buffer)
	local _k
end
