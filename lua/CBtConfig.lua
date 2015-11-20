
local _btConfig = 
{
	clientStartup = 
	{
		type = "sequence",
		--{thing = "createModule", class = "Platform", name = "_platform", group = "global", parent = "" },
		--{thing = "createModule", class = "STime", name = "_time", group = "global", parent = ""},
		
		children = 
		{
			{type = "createModule", class = "ResourceManager", name = "_resourceManager", group = "global", parent = "" },
			{type = "createModule", class = "BehaviorTree", param1 = "load_copy_10101", name = "loadingController", group = "loading", parent = "_runtime" },
		}
	},
	load_copy_10101 = 
	{
		type = "sequence",
		
		children = 
		{
			{type = "loadResource", config = "loadingBar"},
			{type = "waitLoadingOver"},		
			{type = "createModule", class = "LoadingUI", name = "loadingUI", group = "loading", parent = "_runtime" },	
		
			{type = "loadResource", config = "copy_10101"},
			{type = "loadingBarProgress" },
			
			{type = "createModule", class = "EventManager", name = "_eventManager", group = "scene", parent = "" },
			{type = "createModule", class = "Map", param1 = 102, name = "map", group = "scene", parent = "_runtime" },	
			{type = "createModule", class = "ObjectManager", name = "objectManager", group = "scene", parent = "_runtime" },
			{type = "createModule", class = "BattleUI", name = "ui", group = "scene", parent = "_runtime" },
			{type = "createModule", class = "Stick", name = "stick", group = "scene", parent = "_runtime" },
			{type = "createModule", class = "FightRuntime", name = "_fightRuntime", group = "scene", parent = "" },
			
			{type = "createHero", region = "1", point = "born", },
			{type = "createModule", class = "SCamera", param1 = "1", param2 = "born",  name = "camera", group = "scene", parent = "_runtime" },	

			{type = "overModuleGroup", group = "loading"},
			
			
			{type = "createMob", region = "2", point = "0", },
		},
	},
	--------------------------------------------------------------------------------------------------------------------
	
	heroCommon = 
	{
		type = "selectorLoop",
		children = 
		{
			{
				type = "heroBorn",
				preconditions = { {type = "runOneTime"}, },
			},
			{
				type = "unitIdle",
				preconditions = { {type = "notClickMove"}, {type = "notClickAim"}, },
				conditions = { {type = "notClickMove"}, {type = "notClickAim"}, },
			},
			{
				type = "heroMove",
				preconditions = { {type = "isClickMove"}, },		
			},
			{
				type = "heroAim",
				preconditions = { {type = "isClickAim"}, },				
			},
		},
	},
	
	mobCommon = 
	{
		type = "selectorLoop",
		children = 
		{
			{
				type = "unitRest",
			},
			{
				type = "unitMoveTo",
			},
		},
	},
	
	cameraCommon = 
	{
		type = "selectorLoop",
	},
}
function GetBtConfig(name)
	return _btConfig[name]
end