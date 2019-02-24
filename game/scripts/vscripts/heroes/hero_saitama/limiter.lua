LinkLuaModifier("modifier_saitama_limiter_autocast", "heroes/hero_saitama/limiter.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_saitama_limiter_bonus", "heroes/hero_saitama/limiter.lua", LUA_MODIFIER_MOTION_NONE)

saitama_limiter = class({
	GetIntrinsicModifierName = function() return "modifier_saitama_limiter_autocast" end
})

function saitama_limiter:GetManaCost()
	return self:GetSpecialValueFor("manacost")
end
function saitama_limiter:CastFilterResult()
	local parent = self:GetCaster()
	return parent:GetModifierStackCount("modifier_saitama_limiter", parent) == 0 and UF_FAIL_CUSTOM or UF_SUCCESS
end

function saitama_limiter:GetCustomCastError()
	local parent = self:GetCaster()
	return parent:GetModifierStackCount("modifier_saitama_limiter", parent) == 0 and "#dota_hud_error_no_charges" or ""
end

if IsServer() then
	function saitama_limiter:OnSpellStart()
		local caster = self:GetCaster()
		StartAnimation(caster, {
			duration = 1.2, -- 36 / 30
			activity = ACT_DOTA_CAST_ABILITY_6
		})
		caster:EmitSound("Arena.Hero_Saitama.Limiter")

		caster:AddNewModifier(caster, self, "modifier_saitama_limiter_unstoppable", {duration = 10})

		if not caster:HasScepter() then 
			caster:AddNewModifier(caster, self, "modifier_saitama_limiter_bonus", {duration = self:GetSpecialValueFor("duration")})
		else
			caster:AddNewModifier(caster, self, "modifier_saitama_limiter_bonus", nil)
		end
	end
end

modifier_saitama_limiter_autocast = class({
	IsHidden = function() return true end,
})

if IsServer() then
	function modifier_saitama_limiter_autocast:OnCreated()
		self:StartIntervalThink(0.1)
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_saitama_limiter") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_saitama_limiter", nil)
		end
	end

	function modifier_saitama_limiter_autocast:OnIntervalThink()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		if parent:IsAlive() then
			if ability:GetAutoCastState() and parent:GetMana() >= ability:GetManaCost() and not parent:IsChanneling() and not parent:IsInvisible() and not (parent:GetCurrentActiveAbility() and parent:GetCurrentActiveAbility():IsInAbilityPhase()) and parent:GetModifierStackCount("modifier_saitama_limiter", parent) > 0 then
				parent:CastAbilityNoTarget(ability, parent:GetPlayerID())
			end
		end
	end
end

modifier_saitama_limiter_bonus = class({
	IsPurgable = function() return false end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end
})

function modifier_saitama_limiter_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}
end

if IsServer() then
	function modifier_saitama_limiter_bonus:OnCreated()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if not self:GetParent():HasScepter() then
			self.BonusStrength = parent:GetStrength() * ability:GetSpecialValueFor("bonus_strength_pct") * parent:GetModifierStackCount("modifier_saitama_limiter", parent) * 0.01
		else
			self.BonusStrength = parent:GetStrength() * (ability:GetSpecialValueFor("bonus_strength_pct") - ability:GetSpecialValueFor("bonus_strength_pct") / 100 * ability:GetSpecialValueFor("scepter_penalization")) * parent:GetModifierStackCount("modifier_saitama_limiter", parent) * 0.01
		end
	end

	function modifier_saitama_limiter_bonus:GetModifierBonusStats_Strength()
		local bonus = self:GetAbility():GetSpecialValueFor("strength_const")
		--print(math.floor(self.BonusStrength) + bonus)
		if not self:GetParent():HasScepter() then 
			return bonus + self.BonusStrength
		else
			return self.BonusStrength
		end
	end
end