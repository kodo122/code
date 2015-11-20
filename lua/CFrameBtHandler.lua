
local _loadBtHandler = 
{
	loadResource =
	{
		Start = function(self)

			local config = GetLoadConfig(self.config.config)
			assert(config)
			
			for _, v in pairs(config) do
				if v.type == "ui" then
					_resourceManager:LoadUI(v.name)
				elseif v.type == "map" then
					_resourceManager:LoadMap(v.id)
				elseif v.type == "effect" then
					_resourceManager:LoadEffect(v.id)
				elseif v.type == "role" then
					_resourceManager:LoadRole(v.id)
				elseif v.type == "ragdoll" then
					_resourceManager:LoadRagdoll(v.id)		
				elseif v.type == "icon" then
					_resourceManager:LoadIcon(v.name)
				elseif v.type == "camera" then
					_resourceManager:LoadCamera(v.name)
				elseif v.type == "bmfont" then
					_resourceManager:LoadBMFont(v.name)			
				end
			end
		end,
	},
	waitLoadingOver = 
	{
		Update = function(self)
			return _resourceManager:GetProgress() == 1 and "success" or "running"
		end,
	},
	loadingBarProgress = 
	{
		Update = function(self)
			local process = _resourceManager:GetProgress()
			_runtime.loadingUI:SetPercent(process)
			return process == 1 and "success" or "running"
		end
	},
}

for k, v in pairs(_loadBtHandler) do
	PushBTHandler(k, v)
end



