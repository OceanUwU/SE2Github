local cameraHorizBuffer <const> = 6
local cameraVertBuffer <const> = 3

local gridSize <const> = 40
local gridWidth <const> = 400/40
local gridHeight <const> = 240/40

local cameraMoveTime <const> = 10

guyImgN = { gfx.image.new("img/overworld/player/guy-n1"), gfx.image.new("img/overworld/player/guy-n2"), gfx.image.new("img/overworld/player/guy-n3")}
guyImgE = { gfx.image.new("img/overworld/player/guy-e1"), gfx.image.new("img/overworld/player/guy-e2")}
guyImgS = { gfx.image.new("img/overworld/player/guy-s1"), gfx.image.new("img/overworld/player/guy-s2"), gfx.image.new("img/overworld/player/guy-s3")}
guyImgW = { gfx.image.new("img/overworld/player/guy-w1"), gfx.image.new("img/overworld/player/guy-w2") }
playerImg = guyImgN
playerImgIndex = 1

camWidth = 400/40
camHeight = 240/40
movingCam = false

isMenuUp = false
menuTimer = 0
showingMenu = false

playerRenderPosX = 200
playerRenderPosY = 80
playerPrevRenderPosX = playerRenderPosX
playerPrevRenderPosY = playerRenderPosY
playerDestRenderPosX = playerRenderPosX
playerDestRenderPosY = playerRenderPosY
playerFooting = 1

objs = {}

function swapPlayerFooting()
	if playerFooting == 1 then
		playerFooting = 2
	else
		playerFooting = 1
	end
end

function openMainScreen()
	curScreen = 0
end

function hardSetupCameraOffsets()
	cameraOffsetGridX = math.max(0, math.min(mapWidth - camWidth, playerX - cameraHorizBuffer))
	cameraOffsetGridY = math.max(0, math.min(mapHeight - camHeight, playerY - cameraVertBuffer))
	cameraOffsetX = cameraOffsetGridX * -40
	cameraOffsetY = cameraOffsetGridY * -40
	cameraPrevOffsetX = cameraOffsetX
	cameraPrevOffsetY = cameraOffsetY
	cameraDestOffsetX = cameraOffsetX
	cameraDestOffsetY = cameraOffsetY
	if (playerX < cameraHorizBuffer) then
		playerDestRenderPosX = (playerX-1) * 40
	elseif playerX > (mapWidth - (camWidth - cameraHorizBuffer)) then
		playerDestRenderPosX = (playerX - mapWidth + (camWidth) - 1) * 40
	else
		playerDestRenderPosX = (cameraHorizBuffer - 1) * 40
	end
	playerRenderPosX = playerDestRenderPosX

	if (playerY < cameraVertBuffer) then
		playerDestRenderPosY = (playerY - 1) * 40
	elseif playerY > (mapHeight - (camHeight - cameraVertBuffer)) then
		playerDestRenderPosY = (playerY - mapHeight + (camHeight) - 1) * 40
	else
		playerDestRenderPosY = (cameraVertBuffer- 1) * 40
	end
	playerRenderPosY = playerDestRenderPosY
	playerPrevRenderPosX = playerRenderPosX
	playerPrevRenderPosY = playerRenderPosY
	cameraTimer = 0
end

function setupCameraOffset()
	cameraPrevOffsetX = cameraOffsetX
	cameraPrevOffsetY = cameraOffsetY
	playerPrevRenderPosX = playerRenderPosX
	playerPrevRenderPosY = playerRenderPosY
	if (playerX < cameraHorizBuffer or (playerX == cameraHorizBuffer and playerFacing == 1)) then
		playerDestRenderPosX = (playerX-1) * 40
	elseif playerX > (mapWidth - (camWidth - cameraHorizBuffer)) or (playerX == (mapWidth - (camWidth - cameraHorizBuffer)) and playerFacing == 3) then
		playerDestRenderPosX = (playerX - mapWidth + (camWidth) - 1) * 40
	else
		cameraOffsetGridX = (playerX - cameraHorizBuffer)
		cameraDestOffsetX = cameraOffsetGridX * -40
	end


	if (playerY < cameraVertBuffer or (playerY == cameraVertBuffer and playerFacing == 2)) then
		playerDestRenderPosY = (playerY - 1) * 40
	elseif playerY > (mapHeight - (camHeight - cameraVertBuffer)) or (playerY == (mapHeight - (camHeight - cameraVertBuffer)) and playerFacing == 0) then
		playerDestRenderPosY = (playerY - mapHeight + (camHeight) - 1) * 40
	else
		cameraOffsetGridY = (playerY - cameraVertBuffer)
		cameraDestOffsetY = cameraOffsetGridY * -40
	end

	movingCam = true
	if playerFacing == 0 or playerFacing == 2 then
		playerImgIndex = 1 + playerFooting
	else
		playerImgIndex = 2
	end
	cameraTimer = cameraMoveTime
end

function setPlayerFacing(facing)
	playerFacing = facing
	if facing == 0 then
		playerImg = guyImgN
	elseif facing == 1 then
		playerImg = guyImgE
	elseif facing == 2 then
		playerImg = guyImgS
	elseif facing == 3 then
		playerImg = guyImgW
	end
end

function updateOverworld()
	if (textBoxShown) then
		updateTextBox()
	else
		for i, v in ipairs(objs) do
			v:update()
		end

		if (movingCam) then
			updateCameraOffset()
		elseif (menuTimer > 0) then
			updateMenuTimer()
		elseif (isMenuUp) then
			updateInMenu()
		else
			checkMovement()
		end
	end
end

function drawInOverworld()
	currentTileset:draw(cameraOffsetX, cameraOffsetY)

	for i, v in ipairs(objs) do
		v:render()
	end

	--gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
	gfx.fillEllipseInRect(playerRenderPosX, playerRenderPosY + 40 - 13, 40, 10)
	--gfx.setColor(gfx.kColorBlack)
	playerImg[playerImgIndex]:draw(playerRenderPosX, playerRenderPosY - 8)

	if menuTimer > 0 or isMenuUp then
		drawMenu()
	end

	if textBoxShown then
		drawTextBox()
	end
end

function canMoveThere(x, y) 
	if x < 1 or y < 1 or x > mapWidth or y > mapHeight then
		return false
	end
	local result = currentTileset:getTileAtPosition(x, y)
	if (contains(impassables, result)) then
		return false
	end
	for i, v in ipairs(objs) do
		if (v.posX == x and v.posY == y and not v:canMoveHere()) then
			return false
		end
	end
	return true
end

function checkMovement() 
	if (playdate.buttonIsPressed(playdate.kButtonUp)) then
		setPlayerFacing(0)
		if (canMoveThere(playerX, playerY-1)) then
			playerMoveBy(0, -1)
			return
		end
	end
	if (playdate.buttonIsPressed(playdate.kButtonDown)) then
		setPlayerFacing(2)
		if (canMoveThere(playerX, playerY+1)) then
			playerMoveBy(0, 1)
			return
		end
	end
	if (playdate.buttonIsPressed(playdate.kButtonLeft)) then
		setPlayerFacing(3)
		if (canMoveThere(playerX - 1, playerY)) then
			playerMoveBy(-1, 0)
			return
		end
	end
	if (playdate.buttonIsPressed(playdate.kButtonRight)) then
		setPlayerFacing(1)
		if (canMoveThere(playerX + 1, playerY)) then
			playerMoveBy(1, 0)
			return
		end
	end
	if (playdate.buttonJustPressed(playdate.kButtonA)) then
		local tarX, tarY = getPlayerPointCoord()
		for i, v in ipairs(objs) do
			if (v.posX == tarX and v.posY == tarY) then
				v:onInteract()
			end
		end
	end
	if not playdate.isCrankDocked() and not isCrankUp then
		isCrankUp = true
		openMenu()
	end
end

function playerMoveBy(x, y)
	if (x ~= 0 or y ~= 0) then
		swapPlayerFooting()
		playerX += x
		playerY += y
		setupCameraOffset()
	end
end

function getPlayerPointCoord()
	if (playerFacing == 0) then
		return playerX, playerY-1
	elseif (playerFacing == 1) then
		return playerX+1, playerY
	elseif (playerFacing == 2) then
		return playerX, playerY+1
	elseif (playerFacing == 3) then
		return playerX-1, playerY
	end
	return playerX, playerY-1
end

function randomEncounterChance()
	if math.random(0, encounterChance) == 0 then
		return true
	end
	return false
end

function mapRandomEncounter()
	local maxSum = 0
	for k, v in pairs(randomEncounters) do
		maxSum += v[3]
	end

	local result = math.random(maxSum)

	for k, v in pairs(randomEncounters) do
		result -= v[3]
		if result <= 0 then
			addScript(RandomEncounterScript(v[1], v[2]))
			nextScript()
			break
		end
	end
end

function onMoveEnd()
	local landedTile = currentTileset:getTileAtPosition(playerX, playerY)
	movingCam = false
	allowImmediateMovementCheck = true
	for k, v in ipairs(objs) do
		if v.posX == playerX and v.posY == playerY then
			v:onOverlap()
			if not v:allowImmediateMovementAfterStep() then
				allowImmediateMovementCheck = false
			end
		end
	end
	if contains(encounterTiles, landedTile) then
		if randomEncounterChance() then
			allowImmediateMovementCheck = false
			mapRandomEncounter()
		end
	end
	if allowImmediateMovementCheck then
		checkMovement()
	end
end

function updateCameraOffset()
	if cameraTimer > 0 then
		cameraTimer -= 1
		if playerRenderPosX == playerDestRenderPosX and playerRenderPosY == playerDestRenderPosY then
			cameraOffsetX = playdate.math.lerp(cameraPrevOffsetX, cameraDestOffsetX, timeLeft(cameraTimer, cameraMoveTime))
			cameraOffsetY = playdate.math.lerp(cameraPrevOffsetY, cameraDestOffsetY, timeLeft(cameraTimer, cameraMoveTime))
		elseif playerRenderPosX ~= playerDestRenderPosX or playerRenderPosY ~= playerDestRenderPosY then
			playerRenderPosX = playdate.math.lerp(playerPrevRenderPosX, playerDestRenderPosX, timeLeft(cameraTimer, cameraMoveTime))
			playerRenderPosY = playdate.math.lerp(playerPrevRenderPosY, playerDestRenderPosY, timeLeft(cameraTimer, cameraMoveTime))
		end

		if cameraTimer == cameraMoveTime * 0.4 then
			playerImgIndex = 1
		end

		if cameraTimer == 0 then
			onMoveEnd()
		end
	end
end