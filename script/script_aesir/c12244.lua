-- 스톰 오브 라그나로크
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.damtg)
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)

	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetRange(LOCATION_FZONE)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)

	-- 복구
	local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetOperation(s.restore_effect)
    c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(id)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(1,0)
	e5:SetCondition(function(e) 
		return Duel.IsExistingMatchingCard(s.rmvfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) 
	end)
	e5:SetValue(s.repval)
	e5:SetOperation(s.repop)
	c:RegisterEffect(e5)

	-- 3번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(3,id)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)


	if not s.effect_backup then 
		s.effect_backup = nil
	end
end
	-- "극신"의 테마명이 쓰여짐
s.listed_series = {0x4b}

function s.damtg(e,c)
	return c:IsSetCard(0x4b)
end

function s.rmvfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsMonster()
end
function s.filter2(c)
	return c:IsSetCard(0x4b) and c:IsMonster() and c:IsType(TYPE_SYNCHRO)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local cond = nil
	
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_GRAVE,0,nil)

    for c in g:Iter() do
		local effs={c:GetOwnEffects()} -- 해당 몬스터의 모든 효과 가져오기
		for _,eff in ipairs(effs) do
			
			if eff:GetRange()&LOCATION_GRAVE ~= 0 and eff:GetCondition() ~= aux.FALSE then
				if not s.effect_backup then s.effect_backup={} end
				
				for _, v in ipairs(s.effect_backup) do
					if v[1] == c then  
						return 
					end
				end

				cost = eff:GetCost()

				local e1=eff:Clone()
				
				e1:SetCost(aux.CostWithReplace(cost,id))
				c:RegisterEffect(e1)
				cond = e1:GetCondition()
				table.insert(s.effect_backup, {c, eff, cond, cost, e1})
				-- 원래 효과는 잠궈놓음
				eff:SetCondition(aux.FALSE)

			end
		end
	end
end
function s.repval(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
	local c=e:GetHandler()
	return c:IsSetCard(0x4b) and c:IsMonster() and c:IsType(TYPE_SYNCHRO) and (extracon==nil or extracon(base,e,tp,eg,ep,ev,re,r,rp))
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	g=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.restore_effect(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not s.effect_backup then return end
	Debug.Message(#s.effect_backup)
	-- 필드에서 벗어난 순간 해당 유발 즉시 효과는 발동할 수 없음.
	for _,data in ipairs(s.effect_backup) do
        local tc, old_eff, cond, cost, e1 = table.unpack(data)
		-- 원래 효과를 복구
		if tc and old_eff then
			if cost then
				old_eff:SetCondition(cond)
				old_eff:SetCost(cost)
			end
        end
		-- 새로운 효과는 조건을 잠금
        if e1 then
			e1:SetCondition(aux.FALSE)
        end
    end
	s.effect_backup = nil
end


function s.scfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x4b) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.scfilter,1,nil,tp)
end
function s.thfilter(c)
	return c:IsSetCard(0x42) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

