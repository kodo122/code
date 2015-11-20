
FollowAction = {}
FollowAction.__index = FollowAction

function FollowAction:new()
	
	local o = {}
	setmetatable(o, self)

	o.targetObj = nil
	o.targetGameObject = nil
	o.isOver = true

	return o
end

function FollowAction:Start(object)
	
	self.isOver = false
	self.object = object

	self.lastPos = object:GetPos()
	self.lastY = object:GetY()
end

function FollowAction:Update()

	if self.isOver then
		return
	end

	local targetPos
	local targetY
	
	if self.targetObj then
		targetPos = self.targetObj:GetPos()
		targetY = self.targetObj:GetY()
	else
		local targetVec3 = self.targetGameObject.transform.position
		targetPos = cc.vec3ToP(targetVec3)
		targetY = targetVec3.y
	end
	
	local alpha = _time.deltaTime * 20
	if alpha > 1 then
		alpha = 1
	end
	
	local nowPos = cc.pAdd(targetPos, self.offsetPos)
	--nowPos = cc.pLerp(self.lastPos, nowPos, alpha)
	self.lastPos = nowPos
	self.object:SetPos(nowPos)

	local nowY
	if self.isYFollow then
		nowY = targetY + self.offsetY
	else
		local groundY = _runtime.map:GetGroundY(targetPos)
		nowY = groundY + self.offsetY
	end
	--nowY = Lerp(self.lastY, nowY, alpha)
	self.lastY = nowY
	self.object:SetY(nowY)
end

function FollowAction:SetYFollow(b)
	self.isYFollow = b
end

function FollowAction:FollowObject(targetObj, offsetPos, offsetY)
	
	if self.targetObj == targetObj then
		return
	end
		
	self.targetGameObject = nil
	self.targetObj = targetObj
	if offsetPos then
		self.offsetPos = offsetPos
		self.offsetY = offsetY
	end
end

function FollowAction:FollowGameObject(targetGameObject, offsetPos, offsetY)

	if self.targetGameObject == targetGameObject then
		return
	end

	self.targetObj = nil
	self.targetGameObject = targetGameObject
	if offsetPos then
		self.offsetPos = offsetPos
		self.offsetY = offsetY
	end
end

function FollowAction:IsOver()
	return self.isOver
end

function FollowAction:Over()
	self.isOver = true
end

