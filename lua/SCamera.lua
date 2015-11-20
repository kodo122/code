
SCamera = {}
SCamera.__index = SCamera

function SCamera:new(regionName, pointName)
	
	local o = {}
	setmetatable(o, self)

	o.baseFieldOfView = 60
	o.fieldOfView = 60

	o.isfieldOfViewDirty = false
	o.moveFieldOfView = 0
	o.shakeFieldOfView = 0

	o.isRotationDirty = false
	o.rotationX = 0
	o.rotationY = 0
	o.rotationZ = 0
	
	o.isRotationDirty1 = false	
	o.rotationX1 = 0

	
	o.actionRunner = ActionRunner:new(o)
	
	local config = self.config
	self.posInfo = _runtime.map:GetPoint(regionName, pointName)
	local pos = self.posInfo.pos

	--_mainCameraObj.transform.forward  = posInfo.transform.forward
	--_mainCameraObj.transform.position = Vector3(pos.x, 1.3, pos.y + 0.8)

	o.rootObject = Object:new(_mainCameraObj)	
	local cameraGo = o.rootObject:FindChild("MainCamera1")
	o.object = Object:new(cameraGo)
	o.camera = Camera.main
	
	_runtime.objectManager:PushObject("common", o.rootObject)
	_runtime.objectManager:PushObject("common", o.object)	
	
	return o
end

function SCamera:Init()
	self:HangToGo(self.posInfo.transform.gameObject, self.posInfo.pos, 1.1)
end

function SCamera:AddMoveFieldOfView(val)
	self.moveFieldOfView = self.moveFieldOfView + val
	self.isfieldOfViewDirty = true
end

function SCamera:AddShakeFieldOfView(val)
	self.shakeFieldOfView = self.shakeFieldOfView + val
	self.isfieldOfViewDirty = true
end

function SCamera:HangToGo(go, pos, y)
	self.rootObject:HangToGo(go, pos, y)
end

function SCamera:ChangeFieldOfView(val, callBack)

	local action1 = ChangeValAction:new(self.AddMoveFieldOfView, val, IntervalTime:new(0.2))
	local action2 = FuncAction:new(callBack)
	local action3 = SequenceAction:new(action1, aciton2)
	
	self.actionRunner:RunAction(action3)
end

function SCamera:ShakeTo()
	
	local upSpeed = 100
	local downSpeed = 30
	local maxUp = 10
	
	self.actionRunner:StopAction(self.shakeAction)
	
	local upDis = 5 + self.rotationX1 > maxUp and maxUp - self.rotationX1 or 5
	local upTime = upDis / upSpeed
	local downDis = upDis + self.rotationX1
	local downTime = downDis / downSpeed
	
	local action1 = ChangeValAction:new(self.AddRotationX, upDis, IntervalTime:new(upTime))
	local action2 = ChangeValAction:new(self.AddRotationX, -downDis, IntervalTime:new(downTime))
	local action3 = SequenceAction:new(action1, action2)

	self.shakeAction = action3
	
	self.actionRunner:RunAction(self.shakeAction)

	print(self.object.gameObject.transform.localEulerAngles:ToString())
end

function SCamera:AddRotationX(val)
	
	self.rotationX1 = self.rotationX1 + val
	LuaHelper.AddObjectLocalEuler(self.object.gameObject, -val, 0, 0, 10, 0, 0)
end

function SCamera:Update()
	
	self.actionRunner:Update()
	
	if self.isfieldOfViewDirty then
		self.camera.fieldOfView = self.fieldOfView + self.moveFieldOfView + self.shakeFieldOfView
		self.isfieldOfViewDirty = false
	end
	
	local isRotation, dir = _runtime.stick:GetMoveByOp()
	if isRotation then
		local moveX = dir.x * _time.deltaTime * 100
		local moveY = dir.y * _time.deltaTime * 100
		--self.rotationX = self.rotationX + moveY
		--self.rotationY = self.rotationY - moveX

		LuaHelper.AddObjectLocalEuler(self.rootObject.gameObject, -moveY, moveX, 0, 30, 50, 0)
		
		self.isRotationDirty = true
	end
	
	if self.isRotationDirty then
		--LuaHelper.AddObjectLocalEuler(self.rootObject.gameObject, self.rotationX, self.rotationY, self.rotationZ, 30, 50, 0)
		--self.rootObject:SetLocalEulerAngles(self.rotationX, self.rotationY, self.rotationZ)
		self.isRotationDirty = false
	end
end
