class('WalkingTrainer').extends(Trainer)

function WalkingTrainer:init(name, x, y, facing, combat, textIn, textAfterFought, flagID, distHoriz, distVert, isClockwise)
	WalkingTrainer.super.init(self, name, x, y, facing, combat, textIn, textAfterFought, flagID)
	if not contains(playerBeatenTrainers, self.flagID) then
		self.startTimer = 50
	else
		self.startTimer = 0
	end
	self.distMoved = 0
	self.distHoriz = distHoriz
	self.distVert = distVert
	self.clockwise = isClockwise
end

function WalkingTrainer:update()
	WalkingTrainer.super.update(self)
	if self.startTimer >= 0 then
		self.startTimer -= 1
		if self.startTimer == 0 then
			self:moveForwards()
		end
	end
end

function WalkingTrainer:onEndMove()
	WalkingTrainer.super.onEndMove(self)
	self.distMoved += 1
	if not fightStarting then
		if self.facing == 2 or self.facing == 0 and (self.distMoved == self.distVert) then
			if self.clockwise then
				if self.facing == 2 then
					self.facing = 1
				else
					self.facing = 3
				end
			else
				if self.facing == 2 then
					self.facing = 3
				else
					self.facing = 1
				end
			end
		elseif self.facing == 1 or self.facing == 3 and (self.distMoved == self.distHoriz) then
			if self.clockwise then
				if self.facing == 1 then
					self.facing = 2
				else
					self.facing = 0
				end
			else
				if self.facing == 1 then
					self.facing = 0
				else
					self.facing = 2
				end
			end
		end
		self.startTimer = 1
	end
end