Settings = {
Name = "*PSAR (Parabolic SAR)", 
round = "off",
Step = 0.02,
MaxStep = 0.2, 
line = {{
		Name = "PSAR", 
		Type = TYPE_POINT, 
		Color = RGB(0, 255, 255),
		Width = 3
		}
		}
}

function Init() 
	func = PSAR()
	return #Settings.line
end

function OnCalculate(Index) 
	return func(Index, Settings)
end

function PSAR() --Parabolic SAR ("PSAR")
	local Sar={}
return function (I, Fsettings, ds)
local Out = nil
local Fsettings=(Fsettings or {})
local Step = (Fsettings.Step or 0.02)
local MaxStep = (Fsettings.MaxStep or 0.2)
local R = (Fsettings.round or "off")
Sar[I]={Val = nil, Step = 0, Ext = 0, Long = true}
Candle={H = Value(I,"High",ds), L = Value(I,"Low",ds)}
if I==2 then
	Sar[I].Val = Value(I-1,"High",ds)
	Sar[I].Step = Step
	Sar[I].Ext = Candle.H
	Sar[I].Long = true
end
if I > 2 then
	Prev = Sar[I-1]
	Sar[I].Val = Prev.Val + Prev.Step * (Prev.Ext - Prev.Val)
	Revers = false
	Sar[I].Long = Prev.Long
	Sar[I].Ext = Prev.Ext
	Sar[I].Step = Prev.Step
	if Prev.Long then
		if Candle.L < Sar[I].Val then
			Sar[I].Long=false
			Sar[I].Val = Prev.Ext
			Sar[I].Ext = Candle.L
			Sar[I].Step = Step
			Revers = true
		end
	else
		if Candle.H > Sar[I].Val then
			Sar[I].Long=true
			Sar[I].Val = Prev.Ext
			Sar[I].Ext = Candle.H
			Sar[I].Step = Step
			Revers = true
		end
	end
	if not Revers then
		local PrevCandle = {H = Value(I-1,"High",ds), L = Value(I-1,"Low",ds)}
		local PrevPrevCandle = {H = Value(I-2,"High",ds), L = Value(I-2,"Low",ds)}
		if Prev.Long then
			if Candle.H > Prev.Ext then
				Sar[I].Ext = Candle.H
				Sar[I].Step = Prev.Step + Step
				if Sar[I].Step > MaxStep then Sar[I].Step = MaxStep end
			end
			if PrevCandle.L < Sar[I].Val then Sar[I].Val = PrevCandle.L end
			if PrevPrevCandle.L < Sar[I].Val then Sar[I].Val = PrevPrevCandle.L end
		else
			if Candle.L < Prev.Ext then
				Sar[I].Ext = Candle.L
				Sar[I].Step = Prev.Step + Step
				if Sar[I].Step > MaxStep then Sar[I].Step = MaxStep end
			end
			if PrevCandle.H > Sar[I].Val then Sar[I].Val = PrevCandle.H end
			if PrevPrevCandle.H > Sar[I].Val then Sar[I].Val = PrevPrevCandle.H end
		end
	end
end
return rounding(Sar[I].Val, R)
end
end

function rounding(num, round) 
if round and string.upper(round)== "ON" then round=0 end
if num and tonumber(round) then
	local mult = 10^round
	if num >= 0 then return math.floor(num * mult + 0.5) / mult
	else return math.ceil(num * mult - 0.5) / mult end
else return num end
end

function Value(I,VType,ds) 
local Out = nil
VType=(VType and string.upper(string.sub(VType,1,1))) or "A"
	if VType == "O" then		--Open
		Out = (O and O(I)) or (ds and ds:O(I))
	elseif VType == "H" then 	--High
		Out = (H and H(I)) or (ds and ds:H(I))
	elseif VType == "L" then	--Low
		Out = (L and L(I)) or (ds and ds:L(I))
	elseif VType == "C" then	--Close
		Out = (C and C(I)) or (ds and ds:C(I))
	elseif VType == "V" then	--Volume
		Out = (V and V(I)) or (ds and ds:V(I)) 
	elseif VType == "M" then	--Median
		Out = ((Value(I,"H",ds) + Value(I,"L",ds)) / 2)
	elseif VType == "T" then	--Typical
		Out = ((Value(I,"M",ds) * 2 + Value(I,"C",ds))/3)
	elseif VType == "W" then	--Weighted
		Out = ((Value(I,"T",ds) * 3 + Value(I,"O",ds))/4) 
	elseif VType == "D" then	--Difference
		Out = (Value(I,"H",ds) - Value(I,"L",ds))
	elseif VType == "A" then	--Any
		if ds then Out = ds[I] end
	end
return Out
end