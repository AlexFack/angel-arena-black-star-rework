function PassiveCurse(keys)
    local target = keys.target
    if target:IsHero() and not target:HasModifier("modifier_item_demon_king_bar_curse") then
        target:EmitSound("Hero_VengefulSpirit.MagicMissile")
        target:AddNewModifier(keys.caster, keys.ability, "modifier_item_demon_king_bar_curse", nil)
	end
end

function RemoveCurse(keys)
    local target = keys.target
    if target:HasModifier("modifier_item_demon_king_bar_curse") then
        target:RemoveModifierByName("modifier_item_demon_king_bar_curse")
    end
end