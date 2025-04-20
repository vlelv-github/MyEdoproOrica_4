-- 툰 유니버스
local s,id=GetID()
function s.initial_effect(c)
    -- 발동
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    -- 1번 효과
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.aclim)
	e1:SetCondition(s.cond)
	c:RegisterEffect(e1)
    -- 2번 효과
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.toonworldcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    -- 3번 효과
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.rmvtg(s.rmvfilter1))
	e3:SetOperation(s.rmvop)
	c:RegisterEffect(e3)
end
    -- "툰 월드"의 카드명이 쓰여짐
s.listed_names = {15259703}
function s.cond(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_TOON),tp,LOCATION_MZONE,0,1,nil)
end
function s.aclim(e,re,tp)
	local rc=re:GetHandler()
	local status=STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN
	return re:IsMonsterEffect() and rc:IsLocation(LOCATION_MZONE) and rc:IsStatus(status)
end


function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
function s.toonworldcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x62) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.rmvfilter1(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_TOON) and Duel.GetMZoneCount(c:GetControler(),c)>0
end
function s.rmvtg(filter)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and filter(chkc) end
		if chk==0 then return Duel.IsExistingTarget(filter,tp,LOCATION_MZONE,0,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,filter,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	end
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Remove(tc,nil,REASON_EFFECT|REASON_TEMPORARY)>0 and tc:IsLocation(LOCATION_REMOVED)
        and not tc:IsReason(REASON_REDIRECT) then
        Duel.BreakEffect()
        Duel.ReturnToField(tc)
    end
end