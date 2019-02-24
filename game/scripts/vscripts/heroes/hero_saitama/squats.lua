LinkLuaModifier("modifier_saitama_squats_invulnerability", "heroes/hero_saitama/squats.lua", LUA_MODIFIER_MOTION_NONE)

saitama_squats = class({})

modifier_saitama_squats_invulnerability = class({
})

function modifier_saitama_squats_invulnerability:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true
	}
end

if IsServer() then
	function saitama_squats:OnSpellStart()
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_saitama_squats_invulnerability", {duration = self:GetChannelTime()})
	end
	function saitama_squats:OnChannelFinish(bInterrupted)
		if not bInterrupted then
			local caster = self:GetCaster()
			caster:ModifyStrength(self:GetSpecialValueFor("bonus_strength"))

			local modifier = caster:FindModifierByName("modifier_saitama_limiter")
			if not modifier then modifier = caster:AddNewModifier(caster, self, "modifier_saitama_limiter", nil) end
			modifier:SetStackCount(modifier:GetStackCount() + self:GetSpecialValueFor("stacks_amount"))
		end
		self:GetCaster():RemoveModifierByName("modifier_saitama_squats_invulnerability")
	end
end
