-- 인잭터 젝트그레이드
local s,id=GetID()
function s.initial_effect(c)
    -- 발동
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    -- 1번 효과
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetRange(LOCATION_SZONE)
    e1:SetOperation(s.ctop)
    c:RegisterEffect(e1)
    -- 필드에서 벗어나면 원래 효과 복구
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetOperation(s.restore_effect)
    c:RegisterEffect(e2)

	-- 2번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

	-- 3번 효과
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCost(s.setcost)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)

    if not s.effect_backup then 
		s.effect_backup = nil
	end
end
    -- "인잭터"의 테마명이 쓰여짐
s.listed_series = {0x56}
function s.filter(c)
	return c:IsOriginalSetCard(0x56) and c:IsMonsterCard()
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local cond = nil
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
    for c in g:Iter() do
		local effs={c:GetOwnEffects()} -- 해당 몬스터의 모든 효과 가져오기
		for _,eff in ipairs(effs) do
			if eff:GetType()&EFFECT_TYPE_IGNITION ~= 0 and eff:GetCondition() ~= aux.FALSE then

				if not s.effect_backup then s.effect_backup={} end
                
				-- 발동 조건 디폴트값
				cond = nil

				-- 만약 발동 조건이 있다면 저장
				if eff:GetCondition() then
					cond = eff:GetCondition()
				end

				local e1=eff:Clone()
				e1:SetType(EFFECT_TYPE_QUICK_O)
				e1:SetCode(EVENT_FREE_CHAIN)
				c:RegisterEffect(e1)

				
				table.insert(s.effect_backup, {c, eff, cond, e1})
				-- 원래 효과는 잠궈놓음
				eff:SetCondition(aux.FALSE)

			end
		end
	end
end

function s.restore_effect(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not s.effect_backup then return end

	-- 필드에서 벗어난 순간 해당 유발 즉시 효과는 발동할 수 없음.
	for _,data in ipairs(s.effect_backup) do
        local tc, old_eff, cond, e1 = table.unpack(data)
		-- 기동 효과를 복구
		if tc and old_eff then
			if cond == nil then
				old_eff:SetCondition(aux.TRUE)
			else
				old_eff:SetCondition(cond)
			end
        end
		-- 유발 즉시 효과는 발동 조건을 잠금
        if e1 then
			e1:SetCondition(aux.FALSE)
        end
    end
	s.effect_backup = nil
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,nil,tp)
end
function s.spcfilter(c,tp)
	return c:IsSetCard(0x56) and c:IsPreviousLocation(LOCATION_SZONE) and c:IsControler(tp) and c:IsPreviousControler(tp)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x56) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
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

function s.cfilter(c,ft)
	local loc=LOCATION_ONFIELD+LOCATION_HAND
	local flag=true
	if c:IsLocation(LOCATION_ONFIELD) and c:IsFacedown() then 
		flag=false
	end
	if ft<1 then
		loc=LOCATION_SZONE
	end
	return c:IsSetCard(SET_INZEKTOR) and c:IsAbleToGraveAsCost() and flag and c:IsLocation(loc)
end

function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil,ft)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable(true) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end