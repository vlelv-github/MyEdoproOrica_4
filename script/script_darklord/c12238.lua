-- 타락천사의 계명
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	-- "타락천사"의 테마명이 쓰여짐
s.listed_series = {0xef}

function s.costfilter(c)
	return c:IsSetCard(0xef)
		and c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	e:SetLabelObject(g)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.stfilter(c)
	return c:IsFaceup() and c:IsSpellTrap() and c:IsNegatable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local t=Duel.GetMatchingGroup(s.stfilter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #t>0 end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(s.stfilter,tp,0,LOCATION_ONFIELD,nil)
	if #dg<=0 then return end
	local dc=dg:Select(tp,1,1,nil):GetFirst()
	if not dc then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	dc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	dc:RegisterEffect(e2)
	Duel.HintSelection(dc)
	if Duel.Draw(tp,1,REASON_EFFECT)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetLabelObject() then
		local lp=e:GetLabelObject():GetAttack()
		if lp>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Recover(tp,lp,REASON_EFFECT)
		end
		e:SetLabel(0)
		e:SetLabelObject(nil)
	end
end