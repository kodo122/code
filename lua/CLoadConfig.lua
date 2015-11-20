

local loadConfig = 
{
	loadingBar =
	{
		{type = "ui", name = "loading_ui"},	
	},

	copy_10101 = 
	{
		{type = "map", id = 102},
	
		{type = "ui", name = "battle_ui"},
		{type = "ui", name = "roll_tip_ui"},
		{type = "ui", name = "battle_over"},
		
		--{type = "map", id = 201},
		{type = "camera", name = "Camera2"},
		
		{type = "role", id = 102},
		{type = "role", id = 503},
		{type = "role", id = 505},	
		
		{type = "role", id = 801},	
		
		{type = "effect", id = 1001},
		{type = "effect", id = 1003},
		{type = "effect", id = 1004},
		{type = "effect", id = 1005},
		{type = "effect", id = 1006},
		{type = "effect", id = 1007},
		{type = "effect", id = 1010},
		{type = "effect", id = 1011},
		{type = "effect", id = 1012},
		{type = "effect", id = 1013},
		{type = "effect", id = 1014},
		{type = "effect", id = 1015},
		{type = "effect", id = 1016},
		{type = "effect", id = 1017},
		
		{type = "effect", id = 1018},
		{type = "effect", id = 1019},
		{type = "effect", id = 1020},
		{type = "effect", id = 1021},
		{type = "effect", id = 1022},
		{type = "effect", id = 1023},
		{type = "effect", id = 1024},

		{type = "effect", id = 1025},
		{type = "effect", id = 1026},		
		{type = "effect", id = 1027},
		{type = "effect", id = 1028},
		{type = "effect", id = 1029},
		{type = "effect", id = 1030},
		{type = "effect", id = 1031},
		{type = "effect", id = 1032},
		{type = "effect", id = 1033},
		{type = "effect", id = 1035},		
		{type = "effect", id = 1036},
		{type = "effect", id = 1037},
		{type = "effect", id = 1039},				
		{type = "effect", id = 1040},						
		{type = "effect", id = 1041},						
		{type = "effect", id = 1042},						
		{type = "effect", id = 1043},
		{type = "effect", id = 1044},						
		
		{type = "effect", id = 4004},
		{type = "effect", id = 4006},
		{type = "effect", id = 4009},
		{type = "effect", id = 4010},
		{type = "effect", id = 4011},
		{type = "effect", id = 4012},		

		{type = "effect", id = 5001},		
		
		{type = "effect", id = 6004},

		{type = "effect", id = 8001},
		
		{type = "effect", id = 9001},
		{type = "effect", id = 9003},
		{type = "effect", id = 9005},	
	
	},

}

function GetLoadConfig(name)
	return loadConfig[name]
end
