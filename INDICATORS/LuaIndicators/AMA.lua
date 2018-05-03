Settings = {
Name = "*AMA (Adaptive Moving Average)", 
round = "off",
Period = 10, 
FAST_Period = 2, 
SLOW_Period=30, 
VType = "Close", -- Open, High, Low, Close, Volume, Median, Typical, Weighted, Difference
line = {{
		Name = "AMA", 
		Type = TYPE_LINE, 
		Color = RGB(255, 0, 0)
		}
		}
}

function Init() 
	func = AMA()
	return #Settings.line
end

function OnCalculate(Index) 
	return func(Index, Settings)
end

function AMA() --Adaptive Moving Average ("AMA")
	local AMA_TMP={}
return function (I, Fsettings, ds)
local Out = nil
local Fsettings=(Fsettings or {})
local VT = (Fsettings.VType or "Close")
local P = (Fsettings.Period or 10)
local fn = (Fsettings.FAST_Period or 2)
local sn = (Fsettings.SLOW_Period or 30)
local R = (Fsettings.round or "off")
	if I<P then
		return nil
	elseif I==P then
		AMA_TMP[I]=Value(I,VT, ds)
	elseif I>P then
		local Signal = math.abs(Value(I, VT, ds) - Value(I-P, VT, ds))
		local Noise = 0
		for i = I-P+1, I do
			Noise = Noise +math.abs(Value(i, VT, ds) - Value(i-1, VT, ds))
		end
		local ER = Signal / Noise
		local f_SC = 2 / (fn + 1)
		local s_SC = 2 / (sn + 1)
		local SSC = ER * (f_SC - s_SC) + s_SC 
		AMA_TMP[I]=AMA_TMP[I-1]+SSC*SSC*(Value(I,VT,ds)-AMA_TMP[I-1])
	end
	Out = AMA_TMP[I]
	return rounding(Out, R)
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
		if ds then Out = ds[I] else Out = nil end
	end
return Out
end