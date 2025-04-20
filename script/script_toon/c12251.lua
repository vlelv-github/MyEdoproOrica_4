-- 툰 디자이너
local s,id=GetID()
function s.initial_effect(c)
    -- 소생 제한
	c:EnableReviveLimit()
    -- 특소 횟수 제한
	c:SetSPSummonOnce(id)
	-- 소환 조건
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_TOON),2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
    -- 1번 효과 (패 공개)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PUBLIC)
    e1:SetCondition(s.toonworldcon)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e1)
    -- 1번 효과 (공격 대상 불가)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetValue(s.atlimit)
    c:RegisterEffect(e2)
    -- 2번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
    -- "툰 월드"의 카드명이 쓰여짐
s.listed_names = {15259703}
    -- "툰"의 테마명이 쓰여짐
s.listed_series = {0x62}
function s.contactfil(tp)
	local loc=LOCATION_MZONE|LOCATION_HAND
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,loc,0,nil)
end
function s.contactop(g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
function s.toonworldcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.atlimit(e,c)
	return c:IsType(TYPE_TOON)
end

function s.thfilter(c)
	return c:IsSetCard(0x62) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local ct = 1
    if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
        ct = 2
    end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,ct,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end