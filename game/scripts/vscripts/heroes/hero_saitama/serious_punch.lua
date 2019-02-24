LinkLuaModifier("modifier_saitama_serious_punch_stun", "heroes/hero_saitama/serious_punch.lua", LUA_MODIFIER_MOTION_NONE)

saitama_serious_punch = class({})

modifier_saitama_serious_punch_stun = class({
	IsDebuff      = function() return true end,
	IsPurgable    = function() return false end,
})

function modifier_saitama_serious_punch_stun:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true
	}
end

if IsServer() then
	function saitama_serious_punch:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local damage = caster:GetAverageTrueAttackDamage(target) * self:GetSpecialValueFor("damage_multiplier") * 0.01
		local duration =  self:GetSpecialValueFor("stun_duration")
		local permaKill = false

		if RollPercentage(self:GetSpecialValueFor("momental_kill_chance")) then
			permaKill = true
		end

		target:EmitSound("Hero_Earthshaker.EchoSlam")
		ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_fallback_mid_egset.vpcf", PATTACH_ABSORIGIN, target)

		if not permaKill then
			local cleaveDistance = self:GetSpecialValueFor("default_cleave_radius") + caster:GetAverageTrueAttackDamage(target) * self:GetSpecialValueFor("damage_in_cleave_radius_pct") * 0.01

			DoCleaveAttack(
				caster,
				target,
				self,
				damage * self:GetSpecialValueFor("damage_in_cleave_radius_pct") * 0.01,
				cleaveDistance,
				100,
				cleaveDistance,
				self.cleave_pfx
			)	
		end
		
		if caster:GetTeamNumber() == target:GetTeamNumber() then
			target:AddNewModifier(caster, self, "modifier_saitama_serious_punch_stun", {duration = ability:GetSpecialValueFor("stun_duration_for_ally")})
		elseif not permaKill then
			ApplyDamage({
				attacker = caster,
				victim = target,
				damage = damage,
				damage_type = self:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				ability = self
			})	

			target:AddNewModifier(caster, self, "modifier_saitama_serious_punch_stun", {duration = duration})
		else
			target:TrueKill(self, caster)
		end
	end
end