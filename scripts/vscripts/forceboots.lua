function onForceBoots( keys )
	local hero = keys.caster

	hero:AddNewModifier(hero, nil, "modifier_item_forcestaff_active", { push_length = 750 })
end