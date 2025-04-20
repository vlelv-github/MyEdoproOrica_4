-- 툰 다크 래빗
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    -- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.atklimit)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
    -- 3번 효과
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	e6:SetCondition(s.dircon)
	c:RegisterEffect(e6)
end
    -- "툰 월드"의 카드명이 쓰여짐
s.listed_names = {15259703}

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then 
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			-- 공 2배
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
			local tc=g:Select(tp,1,1,nil):GetFirst()
			Duel.HintSelection(tc)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(tc:GetAttack()*2)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
			Duel.BreakEffect()
			local tc2=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_DARK),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			Duel.HintSelection(tc2)
			if tc2 then
				Duel.Release(tc2,REASON_EFFECT)
			end
		end
	end
end

function s.atklimit(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function s.dircon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),tp,LOCATION_ONFIELD,0,1,nil)
        and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_TOON),tp,0,LOCATION_MZONE,1,nil)
end