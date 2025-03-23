-- 볼캐닉 키메라
local s,id=GetID()
function s.initial_effect(c)
	-- 소생 제한
	c:EnableReviveLimit()
	-- 소환 조건
	Fusion.AddProcMix(c,true,true,{32543380, 63014935},s.ffilter)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
	-- "볼캐닉 데블", "볼캐닉 퀸"의 카드명이 쓰여짐
s.listed_names = {32543380, 63014935}
	-- "볼캐닉"의 테마명이 쓰여짐
s.listed_series = {SET_VOLCANIC}

function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE,fc,sumtype,tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_VOLCANIC) and c:IsLevel(8) and c:IsMonster()
	and not c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION) and rp==1-tp and c:IsPreviousControler(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc then
		local effs = {tc:GetOwnEffects()}
		for k,eff in ipairs(effs) do
			if eff:GetCode()==EFFECT_SPSUMMON_PROC then
				eff:SetLabelObject(Group.CreateGroup())
				local op = eff:GetOperation()
				if op and tc and Duel.SpecialSummonStep(tc,SUMMON_TYPE_SPECIAL+1,tp,tp,true,true,POS_FACEUP) then 
					op(eff,tp,eg,ep,ev,re,r,rp,0)
				end
				Duel.SpecialSummonComplete()
			end
		end
		--Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end