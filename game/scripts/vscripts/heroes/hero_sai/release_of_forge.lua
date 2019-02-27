LinkLuaModifier("modifier_sai_release_of_forge", "heroes/hero_sai/release_of_forge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sai_release_of_forge_final_regeneration", "heroes/hero_sai/release_of_forge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sai_release_of_forge_mass_debuff", "heroes/hero_sai/release_of_forge.lua", LUA_MODIFIER_MOTION_NONE)

sai_release_of_forge = class({})

if IsServer() then
	function sai_release_of_forge:OnSpellStart()
		local caster = self:GetCaster()
		caster:EmitSound("Hero_Spectre.Haunt")
		caster:AddNewModifier(caster, self, "modifier_sai_release_of_forge", {duration = self:GetSpecialValueFor("duration")})
		caster:SetHealth(math.ceil(caster:GetHealth() - self:GetSpecialValueFor("self_damage_pct") * caster:GetHealth() * 0.01))
	end
end


modifier_sai_release_of_forge = class({
	IsPurgable            = function() return false end,
	IsHidden              = function() return false end,
	GetEffectName         = function() return "particles/econ/items/invoker/glorious_inspiration/invoker_forge_spirit_ambient_esl_fire.vpcf" end,
	GetModifierModelScale = function() return 6 end,

	IsAura                = function() return true end,
	GetAuraRadius         = function() return 99999 end,
})

function modifier_sai_release_of_forge:CheckState()
	return {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true
	}
end

function modifier_sai_release_of_forge:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS
	}
end

function modifier_sai_release_of_forge:GetModifierModelChange()
	return "models/items/invoker/forge_spirit/sempiternal_revelations_forged_spirits/sempiternal_revelations_forged_spirits.vmdl"
end

function modifier_sai_release_of_forge:GetModifierAura()
	return "modifier_sai_release_of_forge_mass_debuff"
end

function modifier_sai_release_of_forge:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_sai_release_of_forge:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end

function modifier_sai_release_of_forge:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_sai_release_of_forge:GetModifierAttackRangeBonus()
	local talent = self:GetCaster():HasTalent("talent_hero_sai_release_of_forge_unlimited_attack_range")

	if talent then 
		return 99999 
	else
		return self:GetAbility():GetSpecialValueFor("attack_range_bonus")
	end
end

function modifier_sai_release_of_forge:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("movement_speed")
end

function modifier_sai_release_of_forge:GetModifierMagicalResistanceBonus()
	return -self:GetAbility():GetSpecialValueFor("magic_resistange_debuff")
end

function modifier_sai_release_of_forge:GetModifierProjectileSpeedBonus()
	return 3000
end

if IsServer() then
	function modifier_sai_release_of_forge:OnCreated()
		local caster = self:GetParent()
		self.LostHealth = self:GetAbility():GetSpecialValueFor("self_damage_pct") * caster:GetHealth() * 0.01
		caster:Purge(false, true, false, true, false)
		caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
		caster:SetRangedProjectileName("particles/base_attacks/ranged_tower_bad.vpcf")
		--caster:ChangeTrackingProjectileSpeed(self:GetAbilit(), 3000)
	end

	function modifier_sai_release_of_forge:OnAttackLanded(keys)
		local attacker = keys.attacker
		if attacker ~= self:GetParent() then return end
		local ability = self:GetAbility()
		ApplyDamage({
			victim = keys.target,
			attacker = attacker,
			damage = keys.original_damage * ability:GetSpecialValueFor("pure_damage_pct") * 0.01,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			ability = ability
		})
	end

	function modifier_sai_release_of_forge:OnDestroy()
		local parent = self:GetParent()
		local ability = self:GetAbility()

		parent:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)

		ParticleManager:CreateParticle("particles/arena/units/heroes/hero_sara/fragment_of_logic.vpcf", PATTACH_ABSORIGIN, parent)
		parent:EmitSound("Hero_Chen.HandOfGodHealHero")

		parent:AddNewModifier(parent, self, "modifier_sai_release_of_forge_final_regeneration", {duration = ability:GetSpecialValueFor("final_regeneration_duration")})
		modifier_sai_release_of_forge_final_regeneration.LostHealth = self.LostHealth
		modifier_sai_release_of_forge_final_regeneration.parent = parent
	end
end


modifier_sai_release_of_forge_mass_debuff = class({
	IsPurgable = function() return true end,
})

function modifier_sai_release_of_forge_mass_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
end

if IsServer() then
	function modifier_sai_release_of_forge_mass_debuff:OnCreated()
		local owner = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local talent = caster:HasTalent("talent_hero_sai_release_of_forge_enemy_heroes_vision")

		if talent then 
			self.truesight = owner:AddNewModifier(caster, ability, "modifier_truesight", nil)
		end
	end

	function modifier_sai_release_of_forge_mass_debuff:OnDestroy()
		local talent = self:GetCaster():HasTalent("talent_hero_sai_release_of_forge_enemy_heroes_vision")
		if talent then
			if not self.truesight:IsNull() then self.truesight:Destroy() end
		end
	end

	function modifier_sai_release_of_forge_mass_debuff:GetModifierProvidesFOWVision()
		local talent = self:GetCaster():HasTalent("talent_hero_sai_release_of_forge_enemy_heroes_vision")

		if talent then
    		return 1 
    	end
	end
end

function modifier_sai_release_of_forge_mass_debuff:GetBonusVisionPercentage()
	return -self:GetAbility():GetSpecialValueFor("aura_vision_pct")
end

function modifier_sai_release_of_forge_mass_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("aura_movement_speed_pct")
end

function modifier_sai_release_of_forge_mass_debuff:GetModifierPercentageCasttime()
	return -self:GetAbility():GetSpecialValueFor("aura_cast_time_pct")
end

function modifier_sai_release_of_forge_mass_debuff:GetModifierTurnRate_Percentage()
	return -self:GetAbility():GetSpecialValueFor("aura_turn_rate_pct")
end


modifier_sai_release_of_forge_final_regeneration= class({
	IsPurgable = function() return false end,
})

function modifier_sai_release_of_forge_final_regeneration:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end

if IsServer() then
	function modifier_sai_release_of_forge_final_regeneration:GetModifierConstantHealthRegen()
		local parent = self.parent
		if parent then
		local ability = parent:FindAbilityByName("sai_release_of_forge")
			return (modifier_sai_release_of_forge_final_regeneration.LostHealth * ability:GetSpecialValueFor("final_regeneration_multiplier") * 0.01) / ability:GetSpecialValueFor("final_regeneration_duration")
		end
	end
end