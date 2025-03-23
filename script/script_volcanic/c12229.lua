-- 볼캐닉 거너
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.accost)
	e1:SetTarget(s.actg)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 2번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
	-- "브레이즈 캐논"의 테마명이 쓰여짐
s.listed_series = {0xb9}
	-- "볼캐닉 거너"의 카드명이 쓰여짐
s.listed_names = {id}
function s.acfilter(c)
	return c:IsSetCard(0xb9) and c:IsType(TYPE_CONTINUOUS) and c:IsSpellTrap() and not c:IsForbidden()
end
function s.costfilter(c,tp)
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c)
end
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and 
		Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local ag=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil):GetFirst()
	if ag then
		Duel.MoveToField(ag,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

function s.tgfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	local c=e:GetHandler()
	-- 화염족 몬스터의 공격력 500 상승
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PYRO))
	e1:SetValue(500)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
end

