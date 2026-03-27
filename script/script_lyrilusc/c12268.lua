-- LL-하모니우스 제이
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,1,2,nil,nil,Xyz.InfiniteMats)
    -- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c) return Duel.GetOverlayCount(0,1,1)*300 end)
	c:RegisterEffect(e1)
    -- 2번 효과
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.applycost)
	e2:SetTarget(s.applytg)
	e2:SetOperation(s.applyop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
    -- 3번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(s.negcon)
	e3:SetCost(Cost.DetachFromSelf(3,3,nil))
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end
    -- "LL"의 테마명이 쓰여짐
s.listed_series = {SET_LYRILUSC}

function s.eff_filter(c,e,tp,eg,ep,ev,re,r,rp)
    return c:IsSetCard(SET_LYRILUSC) and c:IsMonster() and s.activable(c,e,tp,eg,ep,ev,re,r,rp)
end
function s.activable(c,e,tp,eg,ep,ev,re,r,rp)
    local effs = {c:GetOwnEffects()}
    for k,eff in ipairs(effs) do
        if bit.band(eff:GetType(), EFFECT_TYPE_SINGLE) ~= 0 and eff:GetCode() == EVENT_SPSUMMON_SUCCESS then
            local tg=eff:GetTarget()
            local op=eff:GetOperation()
            if tg then
                if tg(e,tp,eg,ep,ev,re,r,rp,0) then
                    return true
                else
                    return false
                end
            end
        end
    end
    return false
end
function s.applycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_COST)
		and Duel.IsExistingMatchingCard(s.eff_filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
    Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sc=Duel.SelectMatchingCard(tp,s.eff_filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp):GetFirst()
	Duel.Remove(sc,POS_FACEUP,REASON_COST)
    local effs = {sc:GetOwnEffects()}
    for k,eff in ipairs(effs) do
        if bit.band(eff:GetType(), EFFECT_TYPE_SINGLE) ~= 0 and eff:GetCode() == EVENT_SPSUMMON_SUCCESS then
            e:SetLabelObject(eff)
        end
    end
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local te=e:GetLabelObject()
    local tg=te and te:GetTarget() or nil
    if chkc then return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc) end
    if chk==0 then return true end
    e:SetProperty(te:GetProperty())
    if tg then
        tg(e,tp,eg,ep,ev,re,r,rp,chk)
    end
    e:SetLabelObject(te)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
    local te=e:GetLabelObject()
    if not te then return end
    local op=te:GetOperation()
    if op then
        op(e,tp,eg,ep,ev,re,r,rp)
    end
    e:SetLabel(0)
    e:SetLabelObject(nil)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsSpellTrapEffect() and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local relation=rc:IsRelateToEffect(re)
	if chk==0 then return rc:IsAbleToRemove(tp)
		or (not relation and Duel.IsPlayerCanRemove(tp)) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if relation then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,0,rc:GetPreviousLocation())
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end