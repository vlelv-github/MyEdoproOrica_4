-- 툰 배니시
local s,id=GetID()
function s.initial_effect(c)
    -- 패에서도 발동 가능
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,3))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
    -- "툰 월드"의 카드명이 쓰여짐
s.listed_names = {15259703}

function s.handcon(e)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
		or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.toonworld(c,tp)
	return c:IsCode(15259703) and  not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.toonfilter(c)
	return c:IsType(TYPE_TOON) and c:IsMonster() and c:IsAbleToHand()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==2 and chkc:IsLocation(LOCATION_ONFIELD) end

	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)

	local b1 = ft>0 and Duel.IsExistingMatchingCard(s.toonworld,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
	local b2 = Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b3 = Duel.IsExistingMatchingCard(s.toonfilter,tp,LOCATION_DECK,0,1,nil)

	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b3,aux.Stringid(id,2)}
	)
	e:SetLabel(op)
	if op==1 then
		e:SetProperty(0)
	elseif op==2 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	elseif op==3 then
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 마함존에 놓는다
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,s.toonworld,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if tc then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	elseif op==2 then
		-- 제외
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	elseif op==3 then
		-- 서치
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.toonfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end