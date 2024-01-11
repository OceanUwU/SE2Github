local transitionTimer <const> = 15
fadeOutTimer = 0
fadeInTimer = 0
fadeDest = nil

local fadeCircEndpoint = math.sqrt(400^2 + 240^2)/2

function startFade(toCall)
	fadeOutTimer = transitionTimer
	fadeDest = toCall
end

function updateFade()
	if fadeOutTimer > 0 then
		fadeOutTimer -= 1
		if fadeOutTimer == 0 then
			onEndFadeOut()
			transitionImg = gfx.image.new(400, 240)
			gfx.pushContext(transitionImg)
			render()
			gfx.popContext()
			fadeInTimer = 15
		end
	elseif fadeInTimer > 0 then
		fadeInTimer -= 1
	end
end

function renderFade()
	if fadeOutTimer > 0 then
		gfx.fillCircleAtPoint(200, 120, playdate.math.lerp(0, 1, timeLeft(fadeOutTimer, transitionTimer)) * fadeCircEndpoint)
	elseif fadeInTimer > 0 then
		gfx.clear()
		transitionImg:draw(0, 0)
		gfx.fillCircleAtPoint(200, 120, playdate.math.lerp(1, 0, timeLeft(fadeInTimer, transitionTimer)) * fadeCircEndpoint)
	end
end


function onEndFadeOut()
	fadeDest()
end