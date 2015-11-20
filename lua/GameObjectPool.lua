
GameObjectPool = {}
GameObjectPool.__index = GameObjectPool

function GameObjectPool:new()
	
	local o = {}
	setmetatable(o, self)

	_FrameCreate = 5

	o.allGameObjects = {role = {}, effect = {}, fly_word = {}}
	o.freeGameObjects = {role = {}, effect = {}, fly_word = {}}
	
	return o
end

function GameObjectPool:Record(gameObject, isFree, objectType, name)
	
	self.allGameObjects[gameObject] = {objectType = objectType, name = name}
	if isFree then
		self.freeGameObjects[objectType][name] = self.freeGameObjects[objectType][name] or {}
		table.insert(self.freeGameObjects[objectType][name], gameObject)
	end
end

function GameObjectPool:Push(gameObject)
	
	local gameObjectInfo = self.allGameObjects[gameObject]
	if not gameObjectInfo then
		return false
	end
	local objectType = gameObjectInfo.objectType
	local name = gameObjectInfo.name
	self.freeGameObjects[objectType][name] = self.freeGameObjects[objectType][name] or {}
	table.insert(self.freeGameObjects[objectType][name], gameObject)	
	return true, objectType
end

function GameObjectPool:Pop(objectType, name)
	
	if self.freeGameObjects[objectType][name] then
		
		local count = #self.freeGameObjects[objectType][name]

		if count >= 1 then
			local gameObject = self.freeGameObjects[objectType][name][count]
			self.freeGameObjects[objectType][name][count] = nil
			return gameObject
		end
	end
	return nil
end
