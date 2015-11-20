
local _aiBtHandler = 
{
	unitIdle = 
	{
		Init = function(self)
			self.unit = self.data.unit
		end,
		Start = function(self)
			self.unit.unitController:Idle()
		end,
		Update = function(self)
			return "running"
		end,
	},
	
	heroBorn =
	{
		Init = function(self)
			self.unit = self.data.unit
		end,
		Start = function(self)
			
			self.posInfo = _runtime.map:GetPoint("1", "1")
			local pos = self.posInfo.pos		
			self.isOver = false
			
			function moveOver()
				self.isOver = true
			end
			
			self.unit.unitController:MoveTo(pos, moveOver)
			_runtime.camera:HangToGo(self.unit.gameObject, self.unit:GetPos(), 1.1)
		end,
		End = function(self)
			_runtime.camera:HangToGo(self.posInfo.transform.gameObject, self.posInfo.pos, 1.1)
		end,
		Update = function(self)
			if self.isOver then
				return "success"
			end
			return "running"
		end,
	},
	
	heroMove = 
	{
		Init = function(self)
			self.unit = self.data.unit
		end,
		Start = function(self)
		
			if _fightRuntime.moveLeft then
				self.posInfo = _runtime.map:GetPoint("1", "1")
			else
				self.posInfo = _runtime.map:GetPoint("1", "2")			
			end
			local pos = self.posInfo.pos
			self.isOver = false
			
			function moveOver()
				self.isOver = true
			end
			self.unit.unitController:MoveTo(pos, moveOver)
			_runtime.camera:HangToGo(self.unit.gameObject, self.unit:GetPos(), 1.1)
			
			_fightRuntime.moveLeft = false
			_fightRuntime.moveRight = false	
		end,
		End = function(self)
			_runtime.camera:HangToGo(self.posInfo.transform.gameObject, self.posInfo.pos, 1.1)
		end,
		Update = function(self)
			if self.isOver then
				return "success"
			end
			return "running"
		end,
	},
	
	heroAim = 
	{
		Init = function(self)
		end,
		Start = function(self)
			
			_fightRuntime.isShoot = false
			self.isOver = false

			function aimOver()
				--self.isOver = true
			end
			_runtime.camera:ChangeFieldOfView(-40, aimOver)
		end,
		Update = function(self)
			
			if _fightRuntime.isShoot then
				_fightRuntime.isShoot = false
				_runtime.camera:ShakeTo()
			end
			
			return self.isOver and "success" or "running"
		end,	
	},
	
	unitRest = 
	{
		Init = function(self)
			self.timer = STimer:new()
		end,
		Start = function(self)
			
			self.timer:SetTimeOutTick(math.random(1, 2))
			self.timer:Reset()
		end,
		Update = function(self)
			
			return self.timer:IsTimeOut() and "success" or "running"
		end,
	},
	
	unitMoveTo = 
	{
		Init = function(self)
			self.unit = self.data.unit
		end,
		Start = function(self)
			self.posInfo = _runtime.map:GetPoint("2", "1")
			local pos = self.posInfo.pos
			self.isOver = false
			function moveOver()
				self.isOver = true
			end
			self.unit.unitController:MoveTo(pos, moveOver)
		end,
		Update = function(self)
			return self.isOver and "success" or "running"
		end,
	},
	
	unitAim = 
	{
	
	
	},
	
	
	cameraIdle = 
	{
		Init = function(self)
		end,
		Update = function(self)
		end,
	},
}
for k, v in pairs(_aiBtHandler) do
	PushBTHandler(k, v)
end



local _aiCondition = 
{
	isClickMove = 
	{
		Judge = function(self)
			if _fightRuntime.moveLeft or _fightRuntime.moveRight then
				return "success"
			end
			return "failure"
		end
	},
	notClickMove = 
	{
		Judge = function(self)
			if _fightRuntime.moveLeft or _fightRuntime.moveRight then
				return "failure"
			end
			return "success"
		end	
	},
	isClickAim = 
	{
		Judge = function(self)
			if _fightRuntime.isShoot then
				return "success"
			end
			return "failure"
		end
	},
	notClickAim = 
	{
		Judge = function(self)
			if _fightRuntime.isShoot then
				return "failure"
			end
			return "success"
		end	
	},

}
for k, v in pairs(_aiCondition) do
	PushBTHandler(k, v)
end	


