-- 원죄의 타락천사 그리고리
local s,id=GetID()
function s.initial_effect(c)
	-- 소생 제한
	c:EnableReviveLimit()
	-- 융합 소재
	Fusion.AddProcMix(c,true,true,35306215,s.ffilter)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	--copy effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetCost(s.cpcost)
	e3:SetTarget(s.cptg)
	e3:SetOperation(s.cpop)
	c:RegisterEffect(e3)
end
	-- "타락천사"의 테마명이 쓰여짐
s.listed_series = {0xef}
	-- "실락의 타락천사"의 카드명이 쓰여짐
s.listed_names = {35306215}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp) and c:IsRace(RACE_FAIRY,fc,sumtype,tp)
end
function s.thspfilter(c,e,tp,sp_chk)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY)
	 	and (c:IsAbleToHand() or (sp_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sp_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,sp_chk) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local sp_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local g=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,sp_chk):GetFirst()
	if g then
		aux.ToHandOrElse(g,tp,
		function(sc) return g:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end,
		function(sc) Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,3)
	)
	end
end
function s.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end

function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.filter(c)
	return c:IsSpellTrap() and c:IsSetCard(0xef) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(false,true,true)~=nil
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end

-- function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
-- 	e:SetLabel(1)
-- 	return true
-- end
-- function s.cpfilter(c)
-- 	return c:IsSetCard(0xef) and c:IsSpellTrap()
-- 		and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(false,true,false)~=nil
-- end
-- function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
-- 	if chk==0 then
-- 		if e:GetLabel()~=1 then return false end
-- 		e:SetLabel(0)
-- 		return Duel.CheckLPCost(tp,1000) 
-- 			and Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_DECK,0,1,nil)
-- 	end
-- 	e:SetLabel(0)
-- 	Duel.PayLPCost(tp,1000)
-- 	local g=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
-- 	Duel.SendtoGrave(g,REASON_COST)
-- 	e:SetLabelObject(g)
	
-- 	local te=g:CheckActivateEffect(true,true,false)
-- 	local tg=te:GetTarget()
-- 	local te=Duel.GetChainInfo(Duel.GetCurrentChain()-1,CHAININFO_TRIGGERING_EFFECT)
-- 	Debug.Message(te)
-- 	if tg then
-- 		tg(e,tp,eg,ep,ev,te,r,rp,1)
-- 	end
-- 	Duel.ClearOperationInfo(0)
-- end
-- function s.cpop(e,tp,eg,ep,ev,re,r,rp)
-- 	local tc=e:GetLabelObject()
-- 	if not tc then return end
-- 	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
-- 	if not te then return end
-- 	local op=te:GetOperation()
-- 	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
-- 	if g then
-- 		for etc in aux.Next(g) do
-- 			etc:CreateEffectRelation(te)
-- 		end
-- 	end
-- 	if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
-- 	tc:ReleaseEffectRelation(te)
-- 	if g then 
-- 		for etc in aux.Next(g) do
-- 			etc:ReleaseEffectRelation(te)
-- 		end
-- 	end
-- end
