modifier_decrease_health_for_strength = class({
	IsPurgable    = function() return false end,
	IsHidden      = function() return true end,
	RemoveOnDeath = function() return false end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_decrease_health_for_strength:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_HEALTH_BONUS
	}
end

function modifier_decrease_health_for_strength:health_for_strength()
	return 12
end

if IsServer() then
	function modifier_decrease_health_for_strength:GetModifierHealthBonus()
		local parent = self:GetParent()
		local standartHP = parent:GetStrength() * 20
		local modifiedHP = parent:GetStrength() * self:health_for_strength()
		return -(standartHP - modifiedHP)
	end
end