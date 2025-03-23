-- 볼캐닉 퓨전
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_PYRO),matfilter=s.matfilter,extrafil=s.fextra,extraop=s.extraop,extratg=s.extratg})
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
	-- "볼캐닉"의 테마명이 쓰여짐
s.listed_series = {SET_VOLCANIC}
function s.matfilter(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
	-- "볼캐닉" 몬스터를 융합 소환하는 경우
function s.checkmat(tp,sg,fc)
	--Debug.Message(sg)
	return fc:IsSetCard(SET_VOLCANIC) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD)
end
	-- 상대 필드의 몬스터도 융합 소재로 가능
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.filter),tp,LOCATION_GRAVE,LOCATION_ONFIELD,nil,tp),s.checkmat
	end
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.filter),tp,0,LOCATION_ONFIELD,nil,tp),s.checkmat
end
function s.filter(c,tp)
	return (c:IsControler(tp) and c:IsAbleToRemove()) or (c:IsControler(1-tp) and c:IsDestructable())
end
function s.destfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsDestructable()
end

function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(s.destfilter,nil,1-tp)
	if #rg>0 then
		Duel.Destroy(rg,REASON_EFFECT+REASON_FUSION+REASON_MATERIAL)
		sg:Sub(rg)
	end
	Fusion.BanishMaterial(e,tc,tp,sg)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_MZONE+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,0,0,LOCATION_ONFIELD)
end


function s.tdfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsMonster() and c:IsFaceup() and c:IsAbleToDeck()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetHandler():IsAbleToHand()
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if #tg==0 or Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)==0 then return end
	local dg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	if #dg==0 then return end
	local ct=dg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>1 then
		Duel.SortDeckbottom(tp,tp,ct)
	end
	Duel.SendtoHand(c,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,c)
end