-- 요선수 대재구풍
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_LSCALE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_PZONE,0)
	e2:SetCondition(function(e) return Duel.IsTurnPlayer(1-e:GetHandlerPlayer()) end)
	e2:SetTarget(s.scaletg)
	e2:SetValue(11)
	c:RegisterEffect(e2)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e4)
	-- 3번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(2)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)



	-- -- 3번 효과
    -- local e3=Effect.CreateEffect(c)
    -- e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    -- e3:SetCode(EVENT_PHASE+PHASE_END)
    -- e3:SetRange(LOCATION_FZONE)
    -- e3:SetCountLimit(1)
    -- e3:SetCondition(s.endcond)
	-- e3:SetTarget(s.endtg)
    -- e3:SetOperation(s.endop)
    -- c:RegisterEffect(e3)
	-- -- 패로 되돌아간 요선수 카드의 수 체크
	-- local e4=Effect.CreateEffect(c)
	-- e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	-- e4:SetCode(EVENT_TO_HAND)
	-- e4:SetRange(LOCATION_FZONE)
	-- e4:SetOperation(s.register_return)
	-- c:RegisterEffect(e4)
end
	-- "수험의 요사"의 카드명이 쓰여짐
s.listed_names = {27918963}
	-- "요선수"의 테마명이 쓰여짐
s.listed_series = {0xb3}
function s.plfilter(c,tp)
	return c:IsCode(27918963) and not c:IsForbidden()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.plfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	local sz=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	if #g>0 and sz and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if not tc then return end
		if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.splimit(e,c)
	return not c:IsSetCard(0xb3)
end
function s.filter(c,code)
	return c:IsSetCard(0xb3) and not c:IsCode(code) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:IsSetCard(0xb3) and tc:IsSummonPlayer(tp)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tc:GetCode()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.scaletg(e,c)
	return c:IsLocation(LOCATION_PZONE) and Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_PZONE,1)==c and c:IsSetCard(0xb3)
end


function s.returnfilter(c,tp)
	return c:IsMonsterCard() and c:IsSetCard(0xb3) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.register_return(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.returnfilter,nil,tp)
    if #g>0 then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,#g)
		Debug.Message(Duel.GetFlagEffect(tp,id))
    end
end

function s.endcond(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)>0
end
function s.endtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_ONFIELD)
end
function s.endop(e,tp,eg,ep,ev,re,r,rp)
    local count=Duel.GetFlagEffect(tp,id)
    if count==0 then return end

    local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g==0 then return end
    local sg=g:Select(tp,1,math.min(#g,count),nil)
	Duel.HintSelection(sg)
    Duel.SendtoHand(sg,nil,REASON_EFFECT)
end