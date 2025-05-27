-- LL-비비아 멜로
local s,id=GetID()
function s.initial_effect(c)
    -- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    -- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetCondition(s.condition)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.Hint(HINT_CARD,0,id) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e2)
end
    -- 자신의 카드명이 쓰여짐
s.listed_names = {id}
function s.spconfilter(c)
	return c:IsRace(RACE_WINGEDBEAST) and c:IsMonster() and (c:IsLevel(1) or c:GetRank(1)) and c:IsFaceup()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetReset(RESET_PHASE|PHASE_END)
    e1:SetOperation(s.thop)
    Duel.RegisterEffect(e1,tp)
end
function s.self(c)
    return c:IsCode(id) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.self,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.self,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
	end
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():GetRace()~=RACE_WINGEDBEAST then return false end
    if not re:IsMonsterEffect() or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	local trig_ctrl,trig_loc,trig_lv,trig_rk=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_LEVEL,CHAININFO_TRIGGERING_RANK)
	if not (trig_ctrl==1-tp and trig_loc==LOCATION_MZONE) then return false end
	local trig_lk=re:GetHandler():GetLink()
	if trig_lv>0 and trig_lv==1 then return true end
	if trig_rk>0 and trig_rk==1 then return true end
	if trig_lk>0 and trig_lk==1 then return true end
	return false
	
end