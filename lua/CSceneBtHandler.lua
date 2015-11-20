
local _sceneBtHandler = 
{
	createHero = 
	{
		Start = function(self)
		
			local config = self.config
			if _runtime.hero then
				return
			end
			
			local posInfo = _runtime.map:GetPoint(config.region, config.point)
			local pos = posInfo.pos
			local bodyObj = _resourceManager:CreateRole(102)
			bodyObj.transform.forward  = posInfo.transform.forward--Vector3(0, posInfo.forwardY, posInfo.forwardZ)
			local y = _runtime.map:GetGroundY(pos)
			bodyObj.transform.position = Vector3(pos.x, y, pos.y)
			local unit = Object:new(bodyObj, pos.x, y, pos.y)	
			unit.modelConfig = GetModelConfig(102)

			local actionRunner = ActionRunner:new(unit)
			local unitController = UnitController:new(unit)
			local ai = BehaviorTree:new("heroCommon", {unit = unit})
			ai:Init()
			
			unit:AddComponent(actionRunner, "actionRunner")
			unit:AddComponent(unitController, "unitController")
			unit:AddComponent(ai, "ai")
	
			_runtime.objectManager:PushObject("unit", unit)
			_runtime.hero = unit
		end,
	},

	createMob = 
	{
		Start = function(self, info)

			local config = self.config
			local posInfo = _runtime.map:GetPoint(config.region, config.point)			
			local pos = posInfo.pos
			local bodyObj = _resourceManager:CreateRole(102)
			bodyObj.transform.forward  = posInfo.transform.forward
			local y = _runtime.map:GetGroundY(pos)
			bodyObj.transform.position = Vector3(pos.x, y, pos.y)
			local unit = Object:new(bodyObj, pos.x, y, pos.y)	
			unit.modelConfig = GetModelConfig(102)

			local actionRunner = ActionRunner:new(unit)
			local unitController = UnitController:new(unit)
			local ai = BehaviorTree:new("mobCommon", {unit = unit})
			ai:Init()
			
			unit:AddComponent(actionRunner, "actionRunner")
			unit:AddComponent(unitController, "unitController")
			unit:AddComponent(ai, "ai")
	
			_runtime.objectManager:PushObject("unit", unit)
		end,
	},
}
for k, v in pairs(_sceneBtHandler) do
	PushBTHandler(k, v)
end	



