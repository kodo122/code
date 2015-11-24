
Platform = {}
Platform.__index = Platform

function Platform:new()
	
	local o = {}
	setmetatable(o, self)	

	return o
end

function Platform:Init()
		
	Application = luanet.import_type('UnityEngine.Application')
	Camera = luanet.import_type('UnityEngine.Camera')
	GameObject = luanet.import_type('UnityEngine.GameObject')
	AssetBundle = luanet.import_type('UnityEngine.AssetBundle')
	Input = luanet.import_type('UnityEngine.Input')
	KeyCode = luanet.import_type('UnityEngine.KeyCode')
	WrapMode = luanet.import_type('UnityEngine.WrapMode')
	Vector2 = luanet.import_type('UnityEngine.Vector2')
	Vector3 = luanet.import_type('UnityEngine.Vector3')
	Time = luanet.import_type('UnityEngine.Time')
	Physics = luanet.import_type('UnityEngine.Physics')
	Rect = luanet.import_type('UnityEngine.Rect')
	Screen = luanet.import_type('UnityEngine.Screen')
	Color = luanet.import_type('UnityEngine.Color')
	Loader = luanet.import_type('Loader')
	Resources = luanet.import_type('UnityEngine.Resources')
	ResourcesLoad = Resources.Load
	GUI = luanet.import_type('UnityEngine.GUI')
	iTween = luanet.import_type('iTween')
	iTweenShakePosition = iTween.ShakePosition
	RenderSettings = luanet.import_type('UnityEngine.RenderSettings')
	QueueMode = luanet.import_type('UnityEngine.QueueMode')
	PlayMode = luanet.import_type('UnityEngine.PlayMode')
	ForceMode = luanet.import_type('UnityEngine.ForceMode')

	UGUIEventPool = luanet.import_type('UGUIEventPool')
	EventSystem = luanet.import_type('UnityEngine.EventSystems.EventSystem')

	Sprite = luanet.import_type('UnityEngine.Sprite')
	BMFont = luanet.import_type('BMFont')
	
	NetHelper = luanet.import_type('NetHelper')

	SetObjectPosition = LuaHelper.SetObjectPosition
	SetObjectPositionWithV3 = LuaHelper.SetObjectPositionWithV3
	SetObjectDir = LuaHelper.SetObjectDir
	CameraPostionSwitch = LuaHelper.CameraPostionSwitch
	SetObjectScale = LuaHelper.SetObjectScale
	GetRaycastY = LuaHelper.GetRaycastY
	Raycast = LuaHelper.Raycast
	
	----------------------------------------------------------------
	
	_entryObj = GameObject.Find("EntryObj")
	_mainCameraObj = GameObject.Find("MainCamera")
	_mainCamera = Camera.main
	_effectCameraObj = GameObject.Find("EffectCamera")
	_effectCamera = _effectCameraObj:GetComponent("Camera")
	_uguiCameraObj = GameObject.Find("UCamera")
	_uguiCamera = _uguiCameraObj:GetComponent("Camera")
	_uguiRoot = GameObject.Find("UICanvas")
	_flyWordPanelObj = Platform.FindChild(_uguiRoot, "FlyWordPanel")
	
	self.platform = LuaHelper.platform	
	self.screen = 
	{
		width = Screen.width,
		height = Screen.height,
		
		midX = Screen.width / 2,
		midY = Screen.height / 2,
		
		midPos = cc.p(Screen.width / 2, Screen.height / 2),
	}
end

function Platform.FindChild(obj, name)
	local transform = obj.transform
	local obj = transform:FindChild(name)
	return obj.gameObject
end

function Platform.AddToChild(obj, parent, worldPositionStays)
	assert(obj)
	assert(parent)
	obj.transform:SetParent(parent.transform, worldPositionStays)
end

function Platform.CreateNetHelper(maxIoSize)
	local netHelper = NetHelper()
	--netHelper:Initialize(maxIoSize)
	return netHelper
end
