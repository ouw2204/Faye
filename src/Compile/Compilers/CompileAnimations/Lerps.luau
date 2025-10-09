local ipairs = ipairs
local c3new,nrnew,nskp,ppn,rnew,udmnew,rectnew,r3new,nsnew,cskp,csnew = Color3.new, NumberRange.new, NumberSequenceKeypoint.new,
	PhysicalProperties.new,Ray.new,UDim.new,Rect.new,Region3.new,
		NumberSequence.new,ColorSequenceKeypoint.new,ColorSequence.new
local BLACK_COLOR3 = c3new()
-- Generic Roblox DataType lerp function.
local function RobloxLerp(V0, V1)
	return function(Alpha)
		return V0:Lerp(V1, Alpha)
	end
end

local function Lerp(Start, Finish, Alpha)
	return Start + Alpha * (Finish - Start)
end
local mc = math.clamp
local function Color3Lerp(C0, C1)
	return function(Alpha)
		Alpha = mc(Alpha,0,1)
		return C0:Lerp(C1,Alpha)
	end
end

function GetNumberSequenceValueAtTime(time, keypoints,Count)
	time = mc(time, 0, 1)

	for i = 2, Count do
		local a = keypoints[i - 1]
		local b = keypoints[i]
		if time <= b.Time then
			local alpha = (time - a.Time) / (b.Time - a.Time)
			local value = a.Value + (b.Value - a.Value) * alpha
			local envelope = a.Envelope + (b.Envelope - a.Envelope) * alpha
			return value, envelope
		end
	end

	local last = keypoints[Count]
	return last.Value, last.Envelope
end
function GetColorSequenceValueAtTime(time, keypoints)
	time = mc(time, 0, 1)

	for i = 2, #keypoints do
		local a = keypoints[i - 1]
		local b = keypoints[i]
		if time <= b.Time then
			local alpha = (time - a.Time) / (b.Time - a.Time)
			return a.Value:Lerp(b.Value, alpha)
		end
	end

	return keypoints[#keypoints].Value
end

local Lerps = setmetatable({
	boolean = function(V0, V1)
		return function(Alpha)
			if Alpha < 0.5 then
				return V0
			else
				return V1
			end
		end
	end;

	number = function(V0, V1)
		local Delta = V1 - V0
		return function(Alpha)
			return V0 + Delta * Alpha
		end
	end;

	string = function(V0, V1)
		local RegularString = false

		local N0, D do
			local Sign0, H0, M0, S0 = string.match(V0, "^([+-]?)(%d*):[+-]?(%d*):[+-]?(%d*)$")
			local Sign1, H1, M1, S1 = string.match(V1, "^([+-]?)(%d*):[+-]?(%d*):[+-]?(%d*)$")
			if Sign0 and Sign1 then
				N0 = 3600 * (tonumber(H0) or 0) + 60 * (tonumber(M0) or 0) + (tonumber(S0) or 0)
				local N1 = 3600 * (tonumber(H1) or 0) + 60 * (tonumber(M1) or 0) + (tonumber(S1) or 0)
				if Sign0 == "-" then
					N0 = -N0
				end

				D = (43200 + (Sign1 ~= "-" and N1 or -N1) - N0) % 86400 - 43200
			else
				RegularString = true
			end
		end

		if RegularString then
			local Length = #V1
			return function(Alpha)
				Alpha = 1 + Length * Alpha
				return string.sub(V1, 1, Alpha < Length and Alpha or Length)
			end
		else
			return function(Alpha)
				local FS = (N0 + D * Alpha) % 86400
				local S = math.abs(FS)
				return string.format(
					FS < 0 and "-%.2u:%.2u:%.2u" or "%.2u:%.2u:%.2u",
					(S - S % 3600) / 3600,
					(S % 3600 - S % 60) / 60,
					S % 60
				)
			end
		end
	end;

	CFrame = RobloxLerp;
	Color3 = Color3Lerp;
	NumberRange = function(V0, V1)
		local Min0, Max0 = V0.Min, V0.Max
		local DeltaMin, DeltaMax = V1.Min - Min0, V1.Max - Max0

		return function(Alpha)
			return nrnew(Min0 + Alpha * DeltaMin, Max0 + Alpha * DeltaMax)
		end
	end;

	NumberSequenceKeypoint = function(V0, V1)
		local T0, Value0, E0 = V0.Time, V0.Value, V0.Envelope
		local DT, DV, DE = V1.Time - T0, V1.Value - Value0, V1.Envelope - E0

		return function(Alpha)
			return nskp(T0 + Alpha * DT, Value0 + Alpha * DV, E0 + Alpha * DE)
		end
	end;

	PhysicalProperties = function(V0, V1)
		local D0, E0, EW0, F0, FW0 =
			V0.Density, V0.Elasticity,
			V0.ElasticityWeight, V0.Friction,
			V0.FrictionWeight

		local DD, DE, DEW, DF, DFW =
			V1.Density - D0, V1.Elasticity - E0,
			V1.ElasticityWeight - EW0, V1.Friction - F0,
			V1.FrictionWeight - FW0

		return function(Alpha)
			return ppn(
				D0 + Alpha * DD,
				E0 + Alpha * DE, EW0 + Alpha * DEW,
				F0 + Alpha * DF, FW0 + Alpha * DFW
			)
		end
	end;

	Ray = function(V0, V1)
		local O0, D0, O1, D1 = V0.Origin, V0.Direction, V1.Origin, V1.Direction
		local OX0, OY0, OZ0, DX0, DY0, DZ0 = O0.X, O0.Y, O0.Z, D0.X, D0.Y, D0.Z
		local DOX, DOY, DOZ, DDX, DDY, DDZ = O1.X - OX0, O1.Y - OY0, O1.Z - OZ0, D1.X - DX0, D1.Y - DY0, D1.Z - DZ0

		return function(Alpha)
			return rnew(
				vector.Create(OX0 + Alpha * DOX, OY0 + Alpha * DOY, OZ0 + Alpha * DOZ),
				vector.Create(DX0 + Alpha * DDX, DY0 + Alpha * DDY, DZ0 + Alpha * DDZ)
			)
		end
	end;

	UDim = function(V0, V1)
		local SC, OF = V0.Scale, V0.Offset
		local DSC, DOF = V1.Scale - SC, V1.Offset - OF

		return function(Alpha)
			return udmnew(SC + Alpha * DSC, OF + Alpha * DOF)
		end
	end;

	UDim2 = RobloxLerp;
	Vector2 = RobloxLerp;
	Vector3 = RobloxLerp;
	Rect = function(V0, V1)
		return function(Alpha)
			return rectnew(
				V0.Min.X + Alpha * (V1.Min.X - V0.Min.X), V0.Min.Y + Alpha * (V1.Min.Y - V0.Min.Y),
				V0.Max.X + Alpha * (V1.Max.X - V0.Max.X), V0.Max.Y + Alpha * (V1.Max.Y - V0.Max.Y)
			)
		end
	end;

	Region3 = function(V0, V1)
		return function(Alpha)
			local imin = Lerp(V0.CFrame * (-V0.Size / 2), V1.CFrame * (-V1.Size / 2), Alpha)
			local imax = Lerp(V0.CFrame * (V0.Size / 2), V1.CFrame * (V1.Size / 2), Alpha)

			local iminx = imin.X
			local imaxx = imax.X
			local iminy = imin.Y
			local imaxy = imax.Y
			local iminz = imin.Z
			local imaxz = imax.Z

			return r3new(
				vector.Create(iminx < imaxx and iminx or imaxx, iminy < imaxy and iminy or imaxy, iminz < imaxz and iminz or imaxz),
				vector.Create(iminx > imaxx and iminx or imaxx, iminy > imaxy and iminy or imaxy, iminz > imaxz and iminz or imaxz)
			)
		end
	end;

	NumberSequence = function(V0: NumberSequence, V1: NumberSequence)
		local K0, K1 = V0.Keypoints, V1.Keypoints
		local K0Count, K1Count = #K0, #K1

		-- Collect all unique times from both sequences
		local TimesSet = {}
		for i = 1, K0Count do TimesSet[K0[i].Time] = true end
		for i = 1, K1Count do TimesSet[K1[i].Time] = true end

		-- Convert to sorted array
		local Times = {}
		for t in pairs(TimesSet) do
			table.insert(Times, t)
		end
		table.sort(Times)

		-- Precompute base values and differences
		local Base, Diff = {}, {}
		for i, t in ipairs(Times) do
			local v0, e0 = GetNumberSequenceValueAtTime(t, K0, K0Count)
			local v1, e1 = GetNumberSequenceValueAtTime(t, K1, K1Count)

			Base[i] = {Time = t, Value = v0, Envelope = e0}
			Diff[i] = {Value = v1 - v0, Envelope = e1 - e0}
		end

		-- Return interpolator
		return function(Alpha)
			if Alpha <= 0 then return V0 end
			if Alpha >= 1 then return V1 end

			local New = {}
			for i = 1, #Times do
				local b, d = Base[i], Diff[i]
				New[i] = nskp(
					b.Time,
					b.Value + d.Value * Alpha,
					b.Envelope + d.Envelope * Alpha
				)
			end
			return nsnew(New)
		end
	end;


	ColorSequence = function(V0: ColorSequence, V1: ColorSequence)
		local K0, K1 = V0.Keypoints, V1.Keypoints
		local K0Count, K1Count = #K0, #K1

		-- Collect all unique times from both sequences
		local TimesSet = {}
		for i = 1, K0Count do TimesSet[K0[i].Time] = true end
		for i = 1, K1Count do TimesSet[K1[i].Time] = true end

		-- Convert to sorted array
		local Times = {}
		for t in pairs(TimesSet) do
			table.insert(Times, t)
		end
		table.sort(Times)

		-- Precompute base values and differences (per channel)
		local Base, Diff = {}, {}
		for i, t in ipairs(Times) do
			local c0 = GetColorSequenceValueAtTime(t, K0)
			local c1 = GetColorSequenceValueAtTime(t, K1)

			Base[i] = {Time = t, R = c0.R, G = c0.G, B = c0.B}
			Diff[i] = {R = c1.R - c0.R, G = c1.G - c0.G, B = c1.B - c0.B}
		end

		-- Return interpolator
		return function(Alpha)
			if Alpha <= 0 then return V0 end
			if Alpha >= 1 then return V1 end

			local New = {}
			for i = 1, #Times do
				local b, d = Base[i], Diff[i]
				New[i] = cskp(
					b.Time,
					c3new(
						b.R + d.R * Alpha,
						b.G + d.G * Alpha,
						b.B + d.B * Alpha
					)
				)
			end
			return csnew(New)
		end
	end;

}, {
	__index = function(_, Index)
		error("No lerp function is defined for type " .. tostring(Index) .. ".", 4)
	end;

	__newindex = function(_, Index)
		error("No lerp function is defined for type " .. tostring(Index) .. ".", 4)
	end;
})

return Lerps