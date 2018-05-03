Settings = {
Name = "*ICHIMOKU (Ichimoku Kinko Hyo)", 
round = "off",
Tenkan = 9, 
Kijun = 26, 
Senkou = 52, 
Chinkou = 26, 
Shift = 26,
line = {{
		Name = "ICHIMOKU - Tenkan", 
		Type = TYPE_LINE, 
		Color = RGB(255, 0, 255)
		},
		{
		Name = "ICHIMOKU - Kijun", 
		Type = TYPE_LINE, 
		Color = RGB(255, 0, 0)
		},
		{
		Name = "ICHIMOKU - Senkou Span1", 
		Type = TYPE_LINE, 
		Color = RGB(0, 255, 255)
		},
		{
		Name = "ICHIMOKU - Senkou Span2", 
		Type = TYPE_LINE, 
		Color = RGB(0, 255, 0)
		},
		{
		Name = "ICHIMOKU - Chinkou", 
		Type = TYPE_LINE, 
		Color = RGB(128, 0, 0)
		}
		}
}
			
function Init() 
	func = ICHIMOKU()
	return #Settings.line
end

function OnCalculate(Index) 
	return func(Index, Settings)
end

function ICHIMOKU() --Ichimoku ("ICHIMOKU")
	local OutSenkou1 = {}
	local OutSenkou2 = {}
	local H_tmp={}
	local L_tmp={}
return function (I, Fsettings, ds)
local Fsettings=(Fsettings or {})
local Tenkan = (Fsettings.Tenkan or 9)
local Kijun = (Fsettings.Kijun or 26)
local Senkou = (Fsettings.Senkou or 52)
local Chinkou = (Fsettings.Chinkou or 26)
local Shift = (Fsettings.Shift or 26)
local R = (Fsettings.round or "off")
function sen(I,P, R)
	if I>=P then
		local mx=math.max(unpack(H_tmp,I-P+1,I)) 
		local mn=math.min(unpack(L_tmp,I-P+1,I))
		return rounding((mx+mn)/2, R)
	else return nil	end
end
H_tmp[I]=Value(I,"High",ds)
L_tmp[I]=Value(I,"Low",ds)
local OutTenkan = sen(I, Tenkan, R)
local OutKijun = sen(I, Kijun, R)
local OutChinkou = nil
if I >= math.max(Tenkan, Kijun) then
	OutSenkou1[I] = (OutTenkan + OutKijun)/2
else
	OutSenkou1[I] = nil
end
	OutSenkou2[I] = sen(I,Senkou, R)

if I<Size()-Chinkou then
	OutChinkou= Value(I+Chinkou, "Close", ds)
else
	OutChinkou=nil
	SetValue(I-Chinkou, 5, rounding(Value(I, "Close", ds), R))
end
return sen(I,Tenkan, R),sen(I,Kijun, R),rounding(OutSenkou1[I-Shift], R),rounding(OutSenkou2[I-Shift], R),rounding(OutChinkou, R)
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