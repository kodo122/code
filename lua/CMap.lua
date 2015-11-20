
Map = {}
Map.__index = Map

function Map:new(id)
	
	local o = {}
	setmetatable(o, self)

	o.id = id

	o.regions = {}
	o.currRegion = nil

	return o
end

function Map:Init()
	
	local gameObject = _resourceManager:CreateMap(self.id)
	--gameObject.transform.position = Vector3(0, 0, 0)
	--AddToChild(gameObject, _entryObj, false)
	assert(gameObject)
	self.object = Object:new(gameObject)
	
	local rootTrans = self.object.gameObject.transform
	local regionsRootTrans = rootTrans:FindChild("regions")
	local regionsCount = regionsRootTrans.childCount
	
	for i = 0, regionsCount - 1 do
		
		local regionTrans = regionsRootTrans:GetChild(i)
		--print(regionTrans.name .. " " .. regionTrans.position.x .. " " .. regionTrans.position.z)
		
		local x = regionTrans.position.x
		local y = regionTrans.position.z
		local width = regionTrans.lossyscale.x
		local height = regionTrans.lossyscale.z
		local regionRect = cc.rect(x - width / 2, y - height / 2, width, height)
		
		local region = {rect = regionRect, pointInfo = {}, blocks = {}}
		
		local pointsCount = regionTrans.childCount
		for j = 0, pointsCount - 1 do
			local pointTrans = regionTrans:GetChild(j)
			local forward = pointTrans.forward
			local pointInfo = {transform = pointTrans, pos = cc.vec3ToP(pointTrans.position), y = pointTrans.position.y, forwardY = forward.y, forwardZ = forward.z,}
		
			region.pointInfo[tostring(pointTrans.name)] = pointInfo
		end
		self.regions[tostring(regionTrans.name)] = region
	end
	
	
	local blockRootTrans = rootTrans:FindChild("blocks")
	local blocksCount = blockRootTrans.childCount
	for i = 0, blocksCount - 1 do
		
		local blockTrans = blockRootTrans:GetChild(i)
		local name = blockTrans.name
		local region = self.regions[name]
		assert(region)
		local doorCount = blockTrans.childCount
		for j = 0, doorCount - 1 do
			local doorTrans = blockTrans:GetChild(j)
			region.blocks[doorTrans.name] = doorTrans
		end
	end
end

function Map:GetPoint(region, pointName)
	local region = self.regions[region]
	assert(region)
	local pointInfo = region.pointInfo[pointName]
	assert(pointInfo)
	return pointInfo
end

function Map:GetRegionPos(region)
	
	local region = self.regions[region]
	local rect = region.rect
	return cc.p(cc.rectGetMidX(rect), cc.rectGetMidY(rect))
end

function Map:GetCurrPoint(pointName)
	return self.currRegion.pointInfo[pointName]
end

function Map:Update()
	self.object:Update()
end

function Map:Release()
	self.object:Release()
end

function Map:Object()
	return self.object
end

function Map:GetGroundY(pos)
	
	--local origin = Vector3(pos.x, 100, pos.y)
	--local dir = Vector3(0, -1, 0)
	local dis = 200
	local layerMask = 512

	return GetRaycastY(pos.x, 100, pos.y, 0, -1, 0, dis, layerMask)
end

function Map:CanMove(pos1, pos2, layer, isGetDetail)
	
	local groundY = self:GetGroundY(pos1)
	local layerMask = 256 + (layer or 0)
	--local origin = Vector3(pos1.x, groundY, pos1.y)
	local pos3 = cc.GetDir(pos1, pos2)
	--local dir = Vector3(pos3.x, 0, pos3.y)
	local dis = cc.pGetDistance(pos1, pos2)

	if isGetDetail then
		local isBlock = Raycast(pos1.x, groundY, pos1.y, pos3.x, 0, pos3.y, dis, layerMask)
		
		if isBlock then
			local block = LuaHelper.hitInfo
			local normalVec3 = block.normal
			
			return false, cc.p(normalVec3.x, normalVec3.z)
		else
			return true
		end
	else
		return not Raycast(pos1.x, groundY, pos1.y, pos3.x, 0, pos3.y, dis, layerMask)
	end
end

function Map:GetRandomFakePos()
	local size = #_runtime.mapConfig.fakePoints
	local index = _runtime.mapConfig.fakePoints[math.random(1, size)]
	return _runtime.mapConfig.points[index]
end

function Map:EnterRegion(regionName)
	assert(not self.currRegion)
	self.currRegion = self.regions[regionName]
	assert(self.currRegion)

	if self.currRegion.blocks.enter then
		self.currRegion.blocks.enter.active = true
	end
	if self.currRegion.blocks.exit then
		self.currRegion.blocks.exit.active = true
	end
end

function Map:ExitRegion()
	if self.currRegion.blocks.exit then
		self.currRegion.blocks.exit.active = false
	end
	self.currRegion = nil
end

function Map:IsInCurrRegion(pos)
	
	local rect = self.currRegion.rect
	return cc.rectContainsPoint(rect, pos)
end

function Map:IsInRegion(regionName, pos)
	
	local rect = self.regions[regionName].rect
	--print(rect.x .. " " .. rect.y .. " " .. rect.width .. " " .. rect.height .. " " .. pos.x .. " " .. pos.y)
	return cc.rectContainsPoint(rect, pos)
end

