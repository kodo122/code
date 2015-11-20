
Object = {}
Object.__index = Object

function Object:new(gameObject, x, y, z)
	
	local o = {}
	setmetatable(o, self)
	
	o.components = {}

	o.gameObject = gameObject
	o.transform = gameObject.transform
	
	o.x = x or o.transform.position.x
	o.y = y or o.transform.position.y
	o.z = z or o.transform.position.z
	o.moveLayer = 0
	
	o.bones = {}
	o.childs = {}
	o.materials = {}

	return o
end

function Object:AddComponent(component, name)
	assert(not self[name])
	self[name] = component
	table.insert(self.components, component)
end

function Object:Update()

	for key, val in pairs(self.childs) do
		if val.timer and val.timer:IsTimeOut() then
			_resourceManager:ReleaseObject(key)
			self.childs[key] = nil
		end
	end
	
	for _, v in ipairs(self.components) do
		if v.Update then
			v:Update()
		end
	end
	
	-------------------------------------------------------------------------------
	if self.isPosDirty then
		SetObjectPosition(self.gameObject, self.x, self.y, self.z)
		self.isPosDirty = false
	end
end

function Object:Release()
	_resourceManager:ReleaseObject(self.gameObject)
	for key, val in pairs(self.childs) do
		_resourceManager:ReleaseObject(key)
	end
	self.childs = nil
end

function Object:GameObject()
	return self.gameObject
end

function Object:GetTransform()
	return self.transform
end

function Object:GetEulerAngles()
	return self.transform.eulerAngles
end

function Object:SetEulerAngles(x, y, z)
	self.transform.eulerAngles = Vector3(x, y, z)
end

function Object:SetLocalEulerAngles(x, y, z)
	self.transform.localEulerAngles = Vector3(x, y, z)
end

function Object:SetEulerAnglesWithVec3(vec3)
	self.transform.eulerAngles = vec3
end

function Object:GetPos()
	return cc.p(self.x, self.z)
end

function Object:GetY()
	return self.y
end

function Object:GetDir()
	return cc.p(self.dir2D.x, self.dir2D.y)
end

function Object:Forward(dir2D)
	
	dir2D = cc.pNormalize(dir2D)
	self.dir2D.x = dir2D.x
	self.dir2D.y = dir2D.y
	
	self.isDirDirty = true
end

function Object:SetPos(p)
	self.x = p.x
	self.z = p.y
	self.isPosDirty = true
end

function Object:SetY(y)
	self.y = y
	self.isPosDirty = true
end

function Object:SetPos3(pos3)
	self.x = pos3.x
	self.z = pos3.z
	self.y = pos3.y
	self.isPosDirty = true
end

function Object:GetPos3()
	return cc.p3(self.pos2D.x, self.y, self.pos2D.y)
end

function Object:Play(name, isLoop, isSave, speed, fadeLength)
	if isSave then
		if self.lastPlayName == name then
			return
		end
		self.lastPlayName = name
	else
		self.lastPlayName = "unknown"
	end
	
	if not self.animation then
		self.animation = self.gameObject.animation
		assert(self.animation)
	end
	
	if isLoop then
		self.animation.wrapMode = WrapMode.Loop
	else
		self.animation.wrapMode = WrapMode.Once
	end
	--self.animation:Stop(name)
	fadeLength = fadeLength or 0.1
	self.animationState = self.animation:CrossFadeQueued(name, fadeLength, QueueMode.PlayNow, PlayMode.StopAll)
	self.animationState.speed = speed or 1
end

function Object:IsPlaying()
	
	--todo what the fuck bug!
	if self.animation then
		return LuaHelper.IsPlaying(self.animation)
	else
		return false
	end
	--return self.gameObject.animation.isPlaying
	--return self.animation.isPlaying
end

function Object:Stop()
	self.lastPlayName = "unknown"
	self.animation:Stop()
end

function Object:AddChild(child, objectName, worldPositionStays, time)
	
	local gameobject = nil
	if objectName then
		gameobject = self.bones[objectName]
	else
		gameobject = self.gameObject
	end
	AddToChild(child, gameobject, worldPositionStays or false)
	self.childs[child] = {}
	
	if time then
		local timer = STimer:new()
		timer:SetTimeOutTick(time)
		timer:Reset()
		self.childs[child].timer = timer
	end
end

function Object:HangToGo(go, pos, y)
	_platform.AddToChild(self.gameObject, go, true)
	self:SetPos(pos)
	self:SetY(y)
	self.transform.localEulerAngles = Vector3(0, 0, 0)
end

function Object:RemoveChild(child)
	
	if self.childs[child] then
		self.childs[child] = nil
		_resourceManager:ReleaseObject(child)
	end
end

function Object:GetChildPosition(slotName)
	local slot = self:FindChild(slotName)
	if not slot then
		print(slotName)
		assert(nil)
	end
	return slot.transform.position
end

function Object:FindChild(name)
	return LuaHelper.FindChild(self.gameObject, name)
end

function Object:SetVisible(b)
	self.gameObject:SetActive(b)
	self.lastPlayName = nil --must clear
end
----------------------------------------------------------------
function Object:SetScale(scale)
	self.scale = scale
	self.transform.localScale = Vector3(scale, scale, scale)
end

function Object:GetScale()
	return self.scale
end

function Object:InitMaterials(names)
		
	for _, val in pairs(names) do
		local gameObj = self:FindChild(val)
		assert(gameObj.renderer.material)
		table.insert(self.materials, gameObj.renderer.material)
	end
end

function Object:SetShaderColor(key, val)
	for _, v in pairs(self.materials) do
		v:SetColor(key, val)
	end
end

function Object:SetShaderFloat(key, val)
	for _, v in pairs(self.materials) do
		v:SetFloat(key, val)
	end
end
----------------------------------------------------------------

function Object:InitBone(name, boneName)
	self.bones[name] = self:FindChild(boneName)
end

function Object:GetBone(name)
	return self.bones[name]
end
