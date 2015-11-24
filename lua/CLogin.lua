
Login = {}
Login.__index = Login

function Login:new()
	
	local o = {}
	setmetatable(o, self)
	
	return o
end

function Login:Init()

	function LoginRet(result)
		
		print("login ")
		print(result)
	end
	
	--_lobbyConnector.rpc:Register("LoginRet", LoginRet)
	--todo
	_lobbyConnector.rpc:Call("Login", LoginRet, "kodo122", "a123123")	
end
