
Object2D = {}
Object2D.__index = Object2D

function Object2D:new(gameObject)
	
	local o = {}
	setmetatable(o, self)

	o.gameObject = gameObject
	o.transform = gameObject.transform
	
	local vec3 = o.transform.position
	o.pos2D = cc.p(vec3.x, vec3.y)
	o.z = vec3.z
	o.scale = 1

	o.actions = {}
	o.childs = {}

	return o
end

function Object2D:Update()
	
	for key, val in pairs(self.childs) do
		if val:IsTimeOut() then
			GameObject.Destroy(key)
			self.childs[key] = nil
		end
	end
	
	for key, val in pairs(self.actions) do
		val:Update()
		if val:IsOver() then
			self.actions[key] = nil
		end
	end
	
	-------------------------------------------------------------------------------
	if self.isPosDirty then
		--self.transform.position = Vector3(self.pos2D.x, self.pos2D.y, self.z)
		SetObjectPosition(self.gameObject, self.pos2D.x, self.pos2D.y, self.z)
		self.isPosDirty = false
	end
	-------------------------------------------------------------------------------
end

function Object2D:Release()
	GameObject.Destroy(self.gameObject)
end

function Object2D:GameObject()
	return self.gameObject
end

function Object2D:GetTransform()
	return self.transform
end

function Object2D:GetPos()
	return cc.p(self.pos2D.x, self.pos2D.y)
end

function Object2D:SetPos(p)
	self.pos2D.x = p.x
	self.pos2D.y = p.y
	
	self.isPosDirty = true
end

function Object2D:RunAction(action)
	self.actions[action] = action
	action:Start(self)
end

function Object2D:StopAction(action)

	if self.actions[action] then
		self.actions[action]:Over()
		self.actions[action] = nil
	end
end

function Object2D:Play(name, isLoop, isSave, isTrail)
	
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
	self.animationState = self.animation:CrossFadeQueued(name, 0.1, QueueMode.PlayNow, PlayMode.StopAll)
end

function Object2D:AddChild(child, objectName, worldPositionStays, time)
	
	local gameobject = nil
	if objectName then
		gameobject = self:FindChild(objectName)
	else
		gameobject = self.gameObject
	end
	AddToChild(child, gameobject, worldPositionStays)
	if time then
		local timer = STimer:new()
		timer:SetTimeOutTick(time)
		timer:Reset()
		self.childs[child] = timer
	end
end

function Object2D:RemoveChild(child)
	self.childs[child] = nil
	GameObject.Destroy(child)
end

function Object2D:GetChildPosition(slotName)
	local slot = self:FindChild(slotName)
	if not slot then
		print(slotName)
		assert(nil)
	end
	return slot.transform.position
end

function Object2D:FindChild(name)
	return LuaHelper.FindChild(self.gameObject, name)
end

function Object2D:SetVisible(b)
	self.gameObject:SetActive(b)
	for key, val in pairs(self.uiChilds) do
		val.gameObject:SetActive(b)
	end
	self.lastPlayName = nil --must clear
end
----------------------------------------------------------------
function Object2D:SetScale(scale)
	self.scale = scale
	--self.transform.localScale = Vector3(scale, scale, scale)
	SetObjectScale(self.gameObject, scale, scale, scale)
end

function Object2D:GetScale()
	return self.scale
end

