--[[
MIT License

Copyright (c) 2021 JasonP

Love2d maxrects algorithm demo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

require 'maxrects'

--
-- Runs that visualize the maxrects functions
--
BinWidth = 256
BinHeight = 256

function DrawARect(rect)
	love.graphics.setColor(rect.data[1],rect.data[2],rect.data[3],rect.data[4])
	love.graphics.rectangle('fill', ULx+rect[1], ULy+rect[2], rect[3], rect[4])
end

function DrawARun(self)
	local g = love.graphics
	-- the rectangle map shadow
	g.setColor(0,0.2,0,1.0)
	g.rectangle('fill', ULx, ULy, BinWidth, BinHeight)
	-- assigned rects
	self.mRects:iterate(DrawARect)
	-- the info text at top
	g.setColor(0.2, 0.2, 0.2, 1.0)
	g.rectangle('fill', 0, 0, ScrWidth, 17)
	g.setColor(0.8, 1.0, 0.8, 1.0)
	g.print(self.name .. ' ' .. self.status,4,1)
end

RunOne = { name = "Put 32x32 tiles into " .. BinWidth .. "x" .. BinHeight .. " bin:", done = false,
 	mRects = MaxRects.new(BinWidth,BinHeight), cnt = 0, status = '', rate = 0.2, clck = 0,
 	ColorA = {0.4,0.8,0.4,1.0}, ColorB = {0.4,0.4,0.8,1.0} }

function RunOne:Click()
	self.cnt = self.cnt + 1
	local data = self.ColorA
	if math.fmod(self.cnt,2) == 1 then data = self.ColorB end
	if not self.mRects:insert(32,32,data) then self.done = true end
	self.status = tostring(self.cnt) .. ", " .. math.floor(self.mRects:occupancy() * 100) .. "% using " .. self.mRects:algorithmName()
end

function RunOne:Update(dt)
	self.clck = self.clck + dt
	if self.clck > self.rate then
		self.clck = self.clck - self.rate
		self:Click()
	end
	ULx = ScrWidth/2-(BinWidth/2)
	ULy = ScrHeight/2-(BinHeight/2)
end

function RunOne:Draw()
	DrawARun(self)
end

RunTwo = { name = "Put 32x32 and 16x16 tiles into " .. BinWidth .. "x" .. BinHeight .. " bin:", done = false,
	mRects = MaxRects.new(BinWidth,BinHeight), cnt = 0, status = '', rate = 0.2, clck = 0,
 	ColorA = {0.4,0.8,0.4,1.0}, ColorB = {0.4,0.4,0.8,1.0} }

function RunTwo:Click()
	self.cnt = self.cnt + 1
	local sx, sy, data = 16, 16, self.ColorA
	if math.fmod(self.cnt,2) == 1 then sx, sy, data = 32, 32, self.ColorB end
	if not self.mRects:insert(sx,sy,data) then self.done = true end
	self.status = tostring(self.cnt) .. ", " .. math.floor(self.mRects:occupancy() * 100) .. "% using " .. self.mRects:algorithmName()
end

function RunTwo:Update(dt)
	self.clck = self.clck + dt
	if self.clck > self.rate then
		self.clck = self.clck - self.rate
		self:Click()
	end
	ULx = ScrWidth/2-(BinWidth/2)
	ULy = ScrHeight/2-(BinHeight/2)
end

function RunTwo:Draw()
	DrawARun(self)
end

RunThree = { name = "Put 63x31 and 10x10 tiles into " .. BinWidth .. "x" .. BinHeight .. " bin:", done = false,
	mRects = MaxRects.new(BinWidth,BinHeight), cnt = 0, status = '', rate = 0.2, clck = 0,
 	ColorA = {0.4,0.8,0.4,1.0}, ColorB = {0.4,0.4,0.8,1.0} }

function RunThree:Click()
	self.cnt = self.cnt + 1
	local sx, sy, data = 63, 31, self.ColorA
	if math.fmod(self.cnt,2) == 1 then sx, sy, data = 10, 10, self.ColorB end
	if not self.mRects:insert(sx,sy,data) then self.done = true end
	self.status = tostring(self.cnt) .. ", " .. math.floor(self.mRects:occupancy() * 100) .. "% using " .. self.mRects:algorithmName()
end

function RunThree:Update(dt)
	self.clck = self.clck + dt
	if self.clck > self.rate then
		self.clck = self.clck - self.rate
		self:Click()
	end
	ULx = ScrWidth/2-(BinWidth/2)
	ULy = ScrHeight/2-(BinHeight/2)
end

function RunThree:Draw()
	DrawARun(self)
end

RunFour = { name = "Put 63x31 and 10x10 tiles into " .. BinWidth .. "x" .. BinHeight .. " bin:", done = false,
	mRects = MaxRects.new(BinWidth,BinHeight), cnt = 0, status = '', rate = 0.2, clck = 0,
 	ColorA = {0.4,0.8,0.4,1.0}, ColorB = {0.4,0.4,0.8,1.0} }

function RunFour:Start()
	self.mRects:setAlgorithm("RectBestLongSideFit")
end

function RunFour:Click()
	self.cnt = self.cnt + 1
	local sx, sy, data = 63, 31, self.ColorA
	if math.fmod(self.cnt,2) == 1 then sx, sy, data = 10, 10, self.ColorB end
	if not self.mRects:insert(sx,sy,data) then self.done = true end
	self.status = tostring(self.cnt) .. ", " .. math.floor(self.mRects:occupancy() * 100) .. "% using " .. self.mRects:algorithmName()
end

function RunFour:Update(dt)
	self.clck = self.clck + dt
	if self.clck > self.rate then
		self.clck = self.clck - self.rate
		self:Click()
	end
	ULx = ScrWidth/2-(BinWidth/2)
	ULy = ScrHeight/2-(BinHeight/2)
end

function RunFour:Draw()
	DrawARun(self)
end

RunFive = { name = "Put 63x31 and 10x10 tiles into " .. BinWidth .. "x" .. BinHeight .. " bin:", done = false,
	mRects = MaxRects.new(BinWidth,BinHeight), cnt = 0, status = '', rate = 0.2, clck = 0,
 	ColorA = {0.4,0.8,0.4,1.0}, ColorB = {0.4,0.4,0.8,1.0} }

function RunFive:Start()
	self.mRects:setAlgorithm("RectBestAreaFit")
end

function RunFive:Click()
	self.cnt = self.cnt + 1
	local sx, sy, data = 63, 31, self.ColorA
	if math.fmod(self.cnt,2) == 1 then sx, sy, data = 10, 10, self.ColorB end
	if not self.mRects:insert(sx,sy,data) then self.done = true end
	self.status = tostring(self.cnt) .. ", " .. math.floor(self.mRects:occupancy() * 100) .. "% using " .. self.mRects:algorithmName()
end

function RunFive:Update(dt)
	self.clck = self.clck + dt
	if self.clck > self.rate then
		self.clck = self.clck - self.rate
		self:Click()
	end
	ULx = ScrWidth/2-(BinWidth/2)
	ULy = ScrHeight/2-(BinHeight/2)
end

function RunFive:Draw()
	DrawARun(self)
end

RunTable = { RunThree, RunFour, RunFive }
cRun = 1
TheRun = RunTable[cRun]

--
-- DO THE LOVE STUFF
--

function love.load()
	ScrWidth, ScrHeight = love.graphics.getDimensions()
  if TheRun.Start then TheRun:Start() end
end

function love.update(dt)
	ScrWidth, ScrHeight = love.graphics.getDimensions()
	if TheRun and TheRun.done then
		if TheRun.Stop then TheRun:Stop() end
		cRun = cRun + 1
		TheRun = RunTable[cRun]
		if TheRun == nil then
			love.event.quit(0)
		else
			TheRun:Start()
		end
	end
	if TheRun then TheRun:Update(dt) end
end

function love.draw()
	if TheRun then TheRun:Draw() end
end
