

local modelConfig = 
{
	[102] = 
	{
		prefabName = "role_102",
		bornStyle = "fall",
		--isPaBody = true,
		
		--weapon = 101,
		--isWeaponTrail = true,
		
		bones = 
		{
			chestBone = "chest_bone",
			focusBone = "Bip001 Pelvis",
		},	
		
		attack = 
		{
			10201,
			10202,
			10203,
			10204,
			--10105,	
		},
		
		skill = 
		{
			10211,
			10212,
			10213,
			10214,		
		},
		
		skillVal = 
		{
			1,
			1021201,
			1021301,
			1021401,
		},
	}
}

function GetModelConfig(name)
	return modelConfig[name]
end