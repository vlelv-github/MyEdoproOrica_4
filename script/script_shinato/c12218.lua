-- 노아의 방주
local s,id=GetID()
function s.initial_effect(c)
	-- 발동
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    -- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	c:RegisterEffect(e1)
	-- 2번 효과 적용을 위한 오버라이드
	Duel.GetRitualMaterial=(function()
		local oldfunc=Duel.GetRitualMaterial
		return function(player,check_level)
			local res=oldfunc(player,check_level)
			local g=Duel.GetMatchingGroup(Card.IsHasEffect,player,LOCATION_SZONE,LOCATION_SZONE,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
			if #g>0 then
				res:Merge(g)
			end
			return res
		end
	end)()
	Card.IsCanBeRitualMaterial=(function()
		local oldfunc=Card.IsCanBeRitualMaterial
		return function(c,sc,player)
			if c:IsLocation(LOCATION_SZONE) and c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL) then
				return true
			else
				return oldfunc(c,sc,player)
			end
		end
	end)()
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	e2:SetTarget(s.mttg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	
	-- 3번 효과
	local e3=Ritual.CreateProc({handler=c,
								lvtype=RITPROC_GREATER,
								filter=function(c) return c:IsRace(RACE_FAIRY) end,
								location=LOCATION_HAND|LOCATION_GRAVE,
								desc=aux.Stringid(id,3)})
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(2)
	e3:SetCondition(function(e,tp,eg) return eg:IsExists(s.cfilter,1,nil,tp) end)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
	-- 효과 텍스트에 "스피릿 몬스터"가 쓰여짐
s.listed_card_types={TYPE_SPIRIT}

function s.repfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:GetDestination()==LOCATION_HAND and c:IsMonster()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (r&REASON_EFFECT)~=0 and eg:IsExists(s.repfilter,1,nil) and #eg:Filter(s.repfilter,nil)==1 end
	local g=eg:Filter(s.repfilter,nil):GetFirst()
	local p=g:GetControler()
	if Duel.GetLocationCount(p,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local c=e:GetHandler()
		local g=eg:Filter(s.repfilter,nil):GetFirst()
		

		Duel.MoveToField(g,tp,p,LOCATION_SZONE,POS_FACEUP,true)
		-- 지속 마법으로 취급
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		g:RegisterEffect(e1)

		return true
	else return false end
end
function s.repval(e,c)
	return true
end
function s.cfilter(c,tp)
	return (c:IsType(TYPE_SPIRIT) and c:IsFaceup()) or (c:IsControler(1-tp))
end
function s.mttg(e,c)
	return c:IsMonsterCard() and c:IsFaceup() and c:IsLocation(LOCATION_SZONE)
end
