
ResourceManager = {}
ResourceManager.__index = ResourceManager

local _FrameCreate = 5

function ResourceManager:new()
	
	local o = {}
	setmetatable(o, self)
	
	o.bundles = {}
	o.prefabs = {}
	
	o.pool = GameObjectPool:new()	
	
	o.reserves = {}
	o.reserveIndex = 1
	o.lastReserveFrame = 1	
	
	return o
end

function ResourceManager:Create(objectType, name)
	
	if objectType == "role" then
		return self:_CreateRoleReal(name)
	elseif objectType == "effect" then
		return self:_CreateEffectReal(name)
	elseif objectType == "fly_word" then
		return self:_CreateFlyWordReal(name)
	end
	return nil
end

function ResourceManager:Update()

	if #self.reserves >= self.reserveIndex then
		if _time.frame - self.lastReserveFrame >= _FrameCreate then
			
			local wantReserve = self.reserves[self.reserveIndex]
			local go = self:Create(wantReserve.objectType, wantReserve.name)
			go:SetActive(false)
			go.transform.parent = nil
			
			self.pool:Record(go, true, wantReserve.objectType, wantReserve.name)
			
			self.lastReserveFrame = _time.frame
			self.reserveIndex = self.reserveIndex + 1
		end
	end
end

function ResourceManager:Init()
	self.loader = GameObject.Find("EntryObj"):GetComponent("Loader")
end

function ResourceManager:LoadBundle(bundlePath)
	
	if self.bundles[bundlePath] then
		return self.bundles[bundlePath]
	end
	
	local bundle = LuaHelper.LoadAssetBundle(bundlePath)
	self.bundles[bundlePath] = bundle
	
	return bundle
end

function ResourceManager:LoadBundlePrefab(bundlePath)
	--print("Load:" .. bundlePath)	
	self.loader:LoadBundle(bundlePath)
end

function ResourceManager:CreateGameObject(bundlePath)
	local prefab = self.loader:GetMainPrefab(bundlePath)
	--print("Create:" .. bundlePath)
	if not prefab then
		print("create " .. bundlePath .. " failed!")
		assert(nil)
	end
	return GameObject.Instantiate(prefab)
end

function ResourceManager:GetProgress()
	return self.loader:GetProgress()
end

function ResourceManager:GetIconSprite(name, id)

	local path = "icon/" .. name
	local fullName = "icon_" .. name .. "_" .. id
	
	local prefab = self.loader:GetPrefab(path, fullName)
	if not prefab then
		print("create " .. fullName .. " failed!")
		assert(nil)
	end	
	return prefab
end

function ResourceManager:GetBMFontTexture(name, fontName)

	local path = "bmfont/" .. name
	local prefab = self.loader:GetPrefab(path, fontName)
	if not prefab then
		print("create " .. fontName .. " failed!")
		assert(nil)
	end	
	return prefab
end

---------------------------------------------------

function ResourceManager:CreateMap(id)
	local path = "map/map_" .. id
	local object = self:CreateGameObject(path)
	
	local bakePath = "map/map_" .. id .. "_bake"
	local bakeData = self.loader:GetMainPrefab(bakePath)
	LuaHelper.LoadBake(bakeData)
	
	return object
end

function ResourceManager:CreateUI(name)
	local path = "ui/" .. name
	local object = self:CreateGameObject(path, name)
	LuaHelper.ResetDelay(object)
	return object
end

function ResourceManager:_CreateRoleReal(modelId)
	
	local unitConfig = GetModelConfig(modelId)
	local path = "role/role_" .. modelId
	local gameObj = self:CreateGameObject(path)

	self.pool:Record(gameObj, false, "role", modelId)
		
	return gameObj
end


function ResourceManager:CreateRole(modelId)

	local gameObj = self.pool:Pop("role", modelId)

	if not gameObj then
		gameObj = self:_CreateRoleReal(modelId)
		self.pool:Record(gameObj, false, "role", modelId)
	else
		gameObj:SetActive(true)
	end
	return gameObj
end

function ResourceManager:_CreateEffectReal(id)
	
	local path = "effect/effect_" .. id
	return self:CreateGameObject(path)
end

function ResourceManager:CreateEffect(id)
	
	local gameObj = self.pool:Pop("effect", id)
	
	if not gameObj then
		gameObj = self:_CreateEffectReal(id)
		LuaHelper.ResetDelay(gameObj)		
		self.pool:Record(gameObj, false, "effect", id)
	else
		gameObj:SetActive(true)
		LuaHelper.ResetDelay(gameObj)
		gameObj.transform.position = Vector3(0, 0, 0)
	end
	return gameObj
end

function ResourceManager:_CreateFlyWordReal(fontName)
	
	local texture = _resourceManager:GetBMFontTexture("fight_word", fontName)
	local gameObject = _resourceManager:CreateUI("fly_word")
	local bmfont = gameObject:AddComponent("BMFont")
	bmfont:SetTexture(texture)
	
	return gameObject
end

function ResourceManager:CreateFlyWord(fontName)
	
	local gameObj = self.pool:Pop("fly_word", fontName)
	
	if not gameObj then
		gameObj = self:_CreateFlyWordReal(fontName)
		self.pool:Record(gameObj, false, "fly_word", fontName)
	else
		gameObj:SetActive(true)
		gameObj.transform.position = Vector3(0, 0, 0)
	end
	return gameObj
end

function ResourceManager:CreateWeapon(id)
	local path = "weapon/weapon_" .. id
	return self:CreateGameObject(path)
end

function ResourceManager:CreateCamera(name)

	local path = "camera/" .. name
	return self:CreateGameObject(path)
end

---------------------------------------------------

function ResourceManager:Reserve(objectType, modelId, count)
	count = count or 1
	for i = 1, count do
		table.insert(self.reserves, {objectType = objectType, name = modelId})
	end
end

function ResourceManager:ReleaseObject(gameObject)
	
	local isStore, objectType = self.pool:Push(gameObject)
	if isStore then
		gameObject:SetActive(false)
		if objectType ~= "fly_word" then
			gameObject.transform.parent = nil
		end
	else
		GameObject.Destroy(gameObject)
	end
end

---------------------------------------------------
function ResourceManager:LoadUI(name)
	local path = "ui/" .. name
	_resourceManager:LoadBundlePrefab(path)	
end

function ResourceManager:LoadIcon(name)
	local path = "icon/" .. name
	_resourceManager:LoadBundlePrefab(path)	
end

function ResourceManager:LoadBMFont(name)
	local path = "bmfont/" .. name
	_resourceManager:LoadBundlePrefab(path)	
end

function ResourceManager:LoadMap(id)
	local path = "map/map_" .. id
	_resourceManager:LoadBundlePrefab(path)
	
	local bakePath = "map/map_" .. id .. "_bake"
	_resourceManager:LoadBundlePrefab(bakePath)	
end

function ResourceManager:LoadEffect(id)
	
	local path = "effect/effect_" .. id
	_resourceManager:LoadBundlePrefab(path)
end

function ResourceManager:LoadWeapon(id)
	
	local path = "weapon/weapon_" .. id
	_resourceManager:LoadBundlePrefab(path)
end

function ResourceManager:LoadRole(id)
	
	local path = "role/role_" .. id
	_resourceManager:LoadBundlePrefab(path)
end

function ResourceManager:LoadCamera(name)
	
	local path = "camera/" .. name
	_resourceManager:LoadBundlePrefab(path)
end

-------------------------------------------------------------------------------
function ResourceManager:LoadPrefab(prefabName)
	
	if not self.prefabs[prefabName] then
		self.prefabs[prefabName] = ResourcesLoad(prefabName)
	end
	return self.prefabs[prefabName]
end

-------------------------------------------------------------------------------

function ResourceManager:CreateEmptyGameObject()
	return GameObject()
end
