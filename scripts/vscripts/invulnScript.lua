function OnStartTouch(trigger)

print(trigger.activator)
print(trigger.caller)
if trigger.activator then
trigger.activator:FindAbilityByName("invincible_damage_recoil"):SetLevel(1)
trigger.activator:FindAbilityByName("earth_spirit_boulder_smash"):SetLevel(1)
end

end