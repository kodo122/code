
ObjectManager = {}
ObjectManager.__index = ObjectManager

function ObjectManager:new()
	
	local o = {}
	setmetatable(o, self)
	
	o.goToObject = {}

	o.objects = 
	{
		common = {},
		unit = {},
		bullet = {},
	}
	
	return o
end

function ObjectManager:PushObject(type, object)
	assert(self.objects[type])
	self.objects[type][object] = object
end

function ObjectManager:Update()

	for _, t in pairs(self.objects) do
		for key, val in pairs(t) do
			val:Update()
			if val.ai and val.ai:IsOver() then
				val:Release()
				v[key] = nil
			end
		end
	end
end

function ObjectManager:Release()

	for _, t in pairs(self.objects) do
		for key, val in pairs(t) do
			val:Release()
		end
	end
	self.objects = {}
end

function ObjectManager:GetUnitByObj(obj)
	
	return self.goToObject[obj]
end
