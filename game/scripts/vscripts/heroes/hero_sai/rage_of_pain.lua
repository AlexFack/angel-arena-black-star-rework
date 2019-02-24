LinkLuaModifier("modifier_sai_rage_of_pain", "heroes/hero_sai/rage_of_pain.lua", LUA_MODIFIER_MOTION_NONE)

sai_rage_of_pain = class({
	GetIntrinsicModifierName = function() return "modifier_sai_rage_of_pain" end,
})


modifier_sai_rage_of_pain = class({})

function modifier_sai_rage_of_pain:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_FINISHED,
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

if IsServer() then
	function modifier_sai_rage_of_pain:OnCreated()
		self:StartIntervalThink(0.1)
		self:OnIntervalThink()
	end

	function modifier_sai_rage_of_pain:OnIntervalThink()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local health_per_stack_pct = ability:GetSpecialValueFor("health_per_stack_pct") + 1
		self:SetStackCount(health_per_stack_pct - math.ceil(parent:GetHealth() / parent:GetMaxHealth() * health_per_stack_pct))
	end

	function modifier_sai_rage_of_pain:GetModifierPreAttack_CriticalStrike(keys)
		local ability = self:GetAbility()
		local stacks = self:GetStackCount()
		local chance = ability:GetSpecialValueFor("crit_chance_pct") + ability:GetSpecialValueFor("crit_chance_per_stack_pct") * stacks
		self.criticalDamage = self:GetAbility():GetSpecialValueFor("default_crit_pct")

		if RollPercentage(chance) then
			return self:GetAbility():GetSpecialValueFor("default_crit_pct") + self:GetAbility():GetSpecialValueFor("crit_mult_pre_stack_pct") * stacks
		end
	end

	--thnx Celireor for this code
	function modifier_sai_rage_of_pain:OnAttackStart(keys)
		local ability = self:GetAbility()
		local stacks = self:GetStackCount()
		local chance = ability:GetSpecialValueFor("crit_chance_pct") +
		ability:GetSpecialValueFor("crit_chance_per_stack_pct") * stacks
		self.criticalDamage = self:GetAbility():GetSpecialValueFor("default_crit_pct") + self:GetAbility():GetSpecialValueFor("crit_mult_pre_stack_pct") * stacks

		if keys.attacker == self:GetParent() and RollPercentage(chance) then
			self.GetModifierDamageOutgoing_Percentage = self.crit_procced
			self.GetModifierPreAttack_CriticalStrike = self.crit_procced_num
			self.OnAttackFinished = self.crit_cancel
		end
	end

	function modifier_sai_rage_of_pain:crit_cancel(keys)
		if keys.attacker == self:GetParent() then
			self.GetModifierDamageOutgoing_Percentage = nil
			self.GetModifierPreAttack_CriticalStrike = nil
			self.OnAttackFinished = nil
		end
	end

	function modifier_sai_rage_of_pain:crit_procced()
		return self.criticalDamage - 100
	end

	function modifier_sai_rage_of_pain:crit_procced_num()
		return 100.0001 --if it is 100 the crit indicator won't show
	end

	function modifier_sai_rage_of_pain:GetModifierBaseDamageOutgoing_Percentage(keys)
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local bonus = ability:GetSpecialValueFor("damage_per_stack_pct") * self:GetStackCount()
		--local release_of_forge_ability = parent:FindAbilityByName("sai_release_of_forge")
		local release_of_forge_modifier = parent:FindModifierByName("modifier_sai_release_of_forge")
			if release_of_forge_modifier then
			return bonus * (1 + release_of_forge_modifier:GetAbility():GetSpecialValueFor("rage_of_pain_multiplier_pct") * 0.01)
		else
			return bonus
		end
	end
end

function modifier_sai_rage_of_pain:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("damage_per_stack") * self:GetStackCount()
end