modifier_weather_blizzard_debuff_heal_disable = class({
	IsPurgable = function() return false end,
	IsDebuff = function() return true end,
	GetTexture = function() return "weather/blizzard" end,
	GetEffectName = function() return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_ice.vpcf" end,

    DeclareFunctions = function() 
        return { 
            MODIFIER_PROPERTY_TOOLTIP,
            MODIFIER_PROPERTY_DISABLE_HEALING
        } 
    end,
	OnTooltip = function(self) self:GetDuration() end,
})

function modifier_weather_blizzard_debuff_heal_disable:GetDisableHealing()
	return 1
end