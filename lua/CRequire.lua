

local luas = 
{
	-----------------------
	"C2d",
	"Type",
	-----------------------
	"ModuleManager",
	"GameObjectPool",
	"ResourceManager",
	"EventManager",
	-----------------------
	"CPlatform",
	-----------------------
	"STime",
	"STimer",
	-----------------------
	
	"BehaviorTree",
	"CAiBtHandler",
	"CSceneBtHandler",
	"CFrameBtHandler",
	-----------------------

	
	"Object",
	"Object2D",

	-----------------------

	"ActionRunner",	
	"CUnitController",

	-----------------------

	"MoveByAction",
	"MoveBy3Action",	
	"YMoveByAction",
	
	"ScaleByAction",
	
	"ChangeValAction",
	
	"FollowAction",
	"ShaderAction",
	"ShaderGraduallyAction",
	
	"FuncAction",
	"UpdateFuncAction",
	"AnimationAction",	
	
	"DelayAction",
	"SequenceAction",
	"SpawnAction",

	-----------------------
	"UI",	
	"LoadingUI",
	"BattleSkillBtn",
	"BattleUI",
	-----------------------
	"CMap",
	"CStaticStick",
	"ObjectManager",
	"CFightRuntime",
	"SCamera",
	-----------------------	

	"CLoadConfig",
	"CModelConfig",
	"CBtConfig",
	-----------------------

	"StringBuffer",
	"SMsg",
	"RPC",
	"Net",
	"Socket",
	"NetHandler",

	"CLobbyConnector",
	"CLogin",
	-----------------------
}

for i = 1, #luas do
	include(luas[i])
end
