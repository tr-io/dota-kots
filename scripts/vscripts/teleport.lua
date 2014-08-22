function OnStartTouch(trigger)
	trigger.activator:ForceKill(true)
	local point = Entities:FindByName(nil, "point_teleport_location"):GetAbsOrigin()
	FindClearSpaceForUnit(trigger.activator, point, false)
	trigger.activator:Stop()
	SendToConsole("dota_camera_center")
end