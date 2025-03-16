-- 요선대등장
local s,id=GetID()
function s.initial_effect(c)
	-- 패에서도 발동 가능
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,2))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- 2번 효과
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tptg)
	e2:SetOperation(s.tpop)
	c:RegisterEffect(e2)

end
	-- "요선수"의 테마명이 쓰여짐
s.listed_series = {0xb3}
function s.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
end
function s.nsfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.cedop(e,tp,eg,ep,ev,re,r,rp)
	if eg and eg:IsExists(aux.FaceupFilter(Card.IsSetCard,0xb3),1,nil) then
		Duel.SetChainLimitTillChainEnd(s.chlimit)
	end
end
function s.cedop2(e,tp,eg,ep,ev,re,r,rp)
	local _,g=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if g and g:IsExists(aux.FaceupFilter(Card.IsSetCard,0xb3),1,nil) and Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) then
		Duel.SetChainLimitTillChainEnd(s.chlimit)
	end
end
function s.chlimit(re,rp,tp)
	return rp==tp
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- "요선수" 몬스터의 일반 소환 / 특수 소환시에 상대는 효과 발동 불가
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(s.cedop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(s.cedop2)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	-- 일반 소환 처리
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end

function s.tpfilter(c)
	return c:IsSetCard(0xb3) and c:IsType(TYPE_PENDULUM) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function s.tptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tpfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,1,nil)
	and Duel.CheckPendulumZones(tp) end
end
function s.tpop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local ct=2-Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)
	local g=Duel.SelectMatchingCard(tp,s.tpfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,1,ct,nil)
	if #g<=0 then return false end
	for sc in g:Iter() do
		Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end