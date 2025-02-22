local sqrt,exp,cos,pi = math.sqrt,math.exp,math.cos,math.pi
return function (T, frequency, damping)
	T = math.clamp(T, 0, 1)

	local angularFrequency = 2 * pi * frequency
	local displacement = T - 1

	if damping >= 1 then
		local expTerm = exp(-angularFrequency * damping * T)
		return 1 - displacement * expTerm
	else
		local omegaD = angularFrequency * sqrt(1 - damping ^ 2)
		local decay = exp(-angularFrequency * damping * T)
		return 1 + displacement * decay * cos(omegaD * T)
	end

end