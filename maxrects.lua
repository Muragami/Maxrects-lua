--[[
MIT License

Copyright (c) 2021 JasonP

An implementation of MAXRECTS in Lua

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

local _INVALID = {}

function _clone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[_clone(orig_key)] = _clone(orig_value)
        end
        setmetatable(copy, _clone(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function _copyrect(rect)
	local ret = {}
	ret[1] = rect[1]
	ret[2] = rect[2]
	ret[3] = rect[3]
	ret[4] = rect[4]
	return ret
end

local function _FindPositionForNewNodeBSSF(self, width, height, scores)
	local bestNode = { 0, 0, 0, 0 }

	scores[1] = math.huge -- scores[1]
	scores[2] = math.huge -- bestLongSideFit

	local rectToProcess = #self.freeRectangles
	for i=1,rectToProcess,1 do
		local rect = self.freeRectangles[i]
		-- Try to place the rectangle in upright (non-flipped) orientation.
		if rect[3] >= width and rect[4] >= height then
			local leftoverHoriz = math.abs(rect[3] - width)
			local leftoverVert = math.abs(rect[4] - height)
			local shortSideFit = math.min(leftoverHoriz, leftoverVert)
			local longSideFit = math.max(leftoverHoriz, leftoverVert)

			if shortSideFit < scores[1] or (shortSideFit == scores[1] and longSideFit < scores[2]) then
				bestNode[1] = rect[1]
				bestNode[2] = rect[2]
				bestNode[3] = width
				bestNode[4] = height
				scores[1] = shortSideFit
				scores[2] = longSideFit
			end
		end

		if self.bFlip and rect[3] >= height and rect[4] >= width then
			local flippedLeftoverHoriz = math.abs(rect[3] - height)
			local flippedLeftoverVert = math.abs(rect[4] - width)
			local flippedShortSideFit = math.min(flippedLeftoverHoriz, flippedLeftoverVert)
			local flippedLongSideFit = math.max(flippedLeftoverHoriz, flippedLeftoverVert)

			if flippedShortSideFit < scores[1] or (flippedShortSideFit == scores[1] and flippedLongSideFit < scores[2]) then
				bestNode[1] = rect[1]
				bestNode[2] = rect[2]
				bestNode[3] = width
				bestNode[4] = height
				scores[1] = flippedShortSideFit
				scores[2] = flippedLongSideFit
			end
		end
	end
	return bestNode
end

local function _FindPositionForNewNodeBLSF(self, width, height, scores)
	local bestNode = { 0, 0, 0, 0 }

	scores[1] = math.huge -- bestShortSideFit
	scores[2] = math.huge -- bestLongSideFit

	local rectToProcess = #self.freeRectangles
	for i=1,rectToProcess,1 do
		local frect = self.freeRectangles[i]
		-- Try to place the rectangle in upright (non-flipped) orientation.
		if frect[3] >= width and frect[4] >= height then
			local leftoverHoriz = math.abs(frect[3] - width)
			local leftoverVert = math.abs(frect[4] - height)
			local shortSideFit = math.min(leftoverHoriz, leftoverVert)
			local longSideFit = math.max(leftoverHoriz, leftoverVert)

			if longSideFit < scores[2] or (longSideFit == scores[2] and shortSideFit < scores[1]) then
				bestNode[1] = frect[1]
				bestNode[2] = frect[2]
				bestNode[3] = width
				bestNode[4] = height
				scores[1] = shortSideFit
				scores[2] = longSideFit
			end
		end

		if self.bFlip and frect[3] >= height and frect[4] >= width then
			local leftoverHoriz = math.abs(frect[3] - height)
			local leftoverVert = math.abs(frect[4] - width)
			local shortSideFit = math.min(leftoverHoriz, leftoverVert)
			local longSideFit = math.max(leftoverHoriz, leftoverVert)

			if longSideFit < scores[2] or (longSideFit == scores[2] and shortSideFit < scores[1]) then
				bestNode[1] = frect[1]
				bestNode[2] = frect[2]
				bestNode[3] = height
				bestNode[4] = width
				scores[1] = shortSideFit
				scores[2] = longSideFit
			end
		end
	end
	return bestNode
end

local function _FindPositionForNewNodeBAF(self, width, height, scores)
	local bestNode = { 0, 0, 0, 0 }

	scores[1] = math.huge -- bestAreaFit
	scores[2] = math.huge -- bestShortSideFit

	local rectToProcess = #self.freeRectangles
	for i=1,rectToProcess,1 do
		local frect = self.freeRectangles[i]
		local areaFit = frect[3] * frect[4] - width * height

		-- Try to place the rectangle in upright (non-flipped) orientation.
		if frect[3] >= width and frect[4] >= height then
			local leftoverHoriz = math.abs(frect[3] - width)
			local leftoverVert = math.abs(frect[4] - height)
			local shortSideFit = math.min(leftoverHoriz, leftoverVert)

			if areaFit < scores[1] or (areaFit == scores[1] and shortSideFit < scores[2]) then
				bestNode[1] = frect[1]
				bestNode[2] = frect[2]
				bestNode[3] = width
				bestNode[4] = height
				scores[1] = areaFit
				scores[2] = shortSideFit
			end
		end

		if self.bFlip and frect[3] >= height and frect[4] >= width then
			local leftoverHoriz = math.abs(frect[3] - height)
			local leftoverVert = math.abs(frect[4] - width)
			local shortSideFit = math.min(leftoverHoriz, leftoverVert)

			if areaFit < scores[1] or (areaFit == scores[1] and shortSideFit < scores[2]) then
				bestNode[1] = frect[1]
				bestNode[2] = frect[2]
				bestNode[3] = height
				bestNode[4] = width
				scores[1] = areaFit
				scores[2] = shortSideFit
			end
		end
	end
	return bestNode
end

local function _CommonIntervalLength(i1start, i1end, i2start, i2end)
	if i1end < i2start or i2end < i1start then return 0 end
	return math.min(i1end, i2end) - math.max(i1start, i2start)
end

function _ContactPointScoreNode(self, x, y, width, height)
	local score = 0

	if x == 0 or (x + width == self.bWidth) then score = score + height end
	if y == 0 or (y + height == self.bHeight) then score = score + width end

	local rectToProcess = #self.usedRectangles
	for i=1,rectToProcess,1 do
		local rect = self.usedRectangles[i]
		if (rect[1] == x + width) or (rect[1] + rect[3] == x) then
			score = score + _CommonIntervalLength(rect[2], rect[2] + rect[4], y, y + height)
		end
		if (rect[2] == y + height) or (rect[2] + rect[4] == y) then
			score = score + _CommonIntervalLength(rect[1], rect[1] + rect[3], x, x + width)
		end
	end
	return score
end

local function _FindPositionForNewNodeCP(self, width, height, scores)
	local bestNode = { 0, 0, 0, 0 }

	scores[1] = -1 -- bestContactScore = -1

	local rectToProcess = #self.freeRectangles
	for i=1,rectToProcess,1 do
		local frect = self.freeRectangles[i]
		-- Try to place the rectangle in upright (non-flipped) orientation.
		if frect[3] >= width and frect[4] >= height then
			local score = _ContactPointScoreNode(self, frect[1], frect[2], width, height)
			if score > scores[1] then
				bestNode[1] = frect[1]
				bestNode[2] = frect[2]
				bestNode[3] = width
				bestNode[4] = height
				scores[1] = score
			end
		end
		if self.bFlip and frect.width >= height and frect.height >= width then
			local score = _ContactPointScoreNode(frect[1], frect[2], height, width)
			if score > scores[1] then
				bestNode[1] = frect[1]
				bestNode[2] = frect[2]
				bestNode[3] = height
				bestNode[4] = width
				scores[1] = score
			end
		end
	end
	return bestNode
end

-- table for our various heuristic functions
local FreeRectChoiceHeuristic = {
		RectBestShortSideFit = _FindPositionForNewNodeBSSF,
			-- -BSSF: Positions the rectangle against the short side of a free rectangle into which it fits the best.
		RectBestLongSideFit = _FindPositionForNewNodeBLSF,
			-- -BLSF: Positions the rectangle against the long side of a free rectangle into which it fits the best.
		RectBestAreaFit = _FindPositionForNewNodeBAF,
			-- -BAF: Positions the rectangle into the smallest free rect into which it fits.
		RectContactPointRule =  _FindPositionForNewNodeCP }
			-- -CP: Choosest the placement where the rectangle touches other rects as much as possible.

-- table for names for the heuristics
local FreeRectChoiceHeuristicName = {
		[_FindPositionForNewNodeBSSF] = "BestShortSideFit",
		[_FindPositionForNewNodeBLSF] = "BestLongSideFit",
		[_FindPositionForNewNodeBAF] = "BestAreaFit",
		[_FindPositionForNewNodeCP] = "ContactPointRule" }

local function _IsContainedIn(ra,rb)
	return ra[1] >= rb[1] and ra[2] >= rb[2]
				and ra[1]+ra[3] <= rb[1]+rb[3]
				and ra[2]+ra[4] <= rb[2]+rb[4]
end

MaxRects = { bWidth = 0, bWeight = 0, bFlip = false,
	freeRectangles = {}, usedRectangles = {},
 	algorithm = _FindPositionForNewNodeBSSF, scores = {} }

function MaxRects:insert(width, height, data)
	local newNode
	self.scores[1] = math.huge
	self.scores[2] = math.huge
	newNode = self:algorithm(width, height, self.scores)
	if newNode[4] == 0 then return false end
	local rectToProcess = #self.freeRectangles
	for i=1,rectToProcess,1 do
		if self.freeRectangles[i] ~= _INVALID then
			if self:splitFreeNode(self.freeRectangles[i], newNode) then
				-- remove this later!
				self.freeRectangles[i] = _INVALID
			end
		end
	end
	self:pruneFreeList()
	-- attach data if we have it
	if data then newNode.data = data end
	table.insert(self.usedRectangles,newNode)
	return true
end

function MaxRects:occupancy()
	local usedSurfaceArea = 0
	local count = #self.usedRectangles
	for i=1,count,1 do
		local rect = self.usedRectangles[i]
		usedSurfaceArea = usedSurfaceArea + rect[3] * rect[4]
	end
	return usedSurfaceArea / (self.bWidth * self.bHeight)
end

function MaxRects:algorithmName()
	return FreeRectChoiceHeuristicName[self.algorithm]
end

-- iterate over all contained rects with a function or a function needing self
function MaxRects:iterate(func,otherself)
	local count = #self.usedRectangles
	if otherself then
		for i=1,count,1 do
			func(otherself,self.usedRectangles[i])
		end
	else
		for i=1,count,1 do
			func(self.usedRectangles[i])
		end
	end
end

function MaxRects:init(width,height,canflip)
	self.bFlip = canflip or self.bFlip
	self.bWidth = width or self.bWidth
	self.bHeight = height or self.bHeight
	self.freeRectangles = {}
	self.usedRectangles = {}
	table.insert(self.freeRectangles, { 0, 0, width, height })
end

function MaxRects:reset() self:init() end

function MaxRects:setAlgorithm(algo)
	if FreeRectChoiceHeuristic[algo] then
		self.algorithm = FreeRectChoiceHeuristic[algo]
	else error("MaxRects:setAlgorithm() got bad algo: " .. algo) end
end

function MaxRects:splitFreeNode(freeNode, usedNode)
	-- Test with SAT if the rectangles even intersect.
	if usedNode[1] >= freeNode[1] + freeNode[3] or usedNode[1] + usedNode[3] <= freeNode[1] or
		usedNode[2] >= freeNode[2] + freeNode[4] or usedNode[2] + usedNode[4] <= freeNode[2] then
		return false
	end

	if usedNode[1] < freeNode[1] + freeNode[3] and usedNode[1] + usedNode[3] > freeNode[1] then
		-- New node at the top side of the used node.
		if usedNode[2] > freeNode[2] and usedNode[2] < freeNode[2] + freeNode[4] then
			local newNode = _copyrect(freeNode)	-- fast rect array copy
			newNode[4] = usedNode[2] - newNode[2]
			table.insert(self.freeRectangles,newNode)
		end

		-- New node at the bottom side of the used node.
		if usedNode[2] + usedNode[4] < freeNode[2] + freeNode[4] then
			local newNode = _copyrect(freeNode)	-- fast rect array copy
			newNode[2] = usedNode[2] + usedNode[4]
			newNode[4] = freeNode[2] + freeNode[4] - (usedNode[2] + usedNode[4])
			table.insert(self.freeRectangles,newNode)
		end
	end

	if usedNode[2] < freeNode[2] + freeNode[4] and usedNode[2] + usedNode[4] > freeNode[2] then
		-- New node at the left side of the used node.
		if usedNode[1] > freeNode[1] and usedNode[1] < freeNode[1] + freeNode[3] then
			local newNode = _copyrect(freeNode)	-- fast rect array copy
			newNode[3] = usedNode[1] - newNode[1]
			table.insert(self.freeRectangles,newNode)
		end

		-- New node at the right side of the used node.
		if usedNode[1] + usedNode[3] < freeNode[1] + freeNode[3] then
			local newNode = _copyrect(freeNode)	-- fast rect array copy
			newNode[1] = usedNode[1] + usedNode[3]
			newNode[3] = freeNode[1] + freeNode[3] - (usedNode[1] + usedNode[3])
			table.insert(self.freeRectangles,newNode)
		end
	end

	return true
end

-- Go through each pair and remove any rectangle that is redundant.
function MaxRects:pruneFreeList()
	local rectToProcess = #self.freeRectangles
	for i=1,rectToProcess,1 do
		local recta = self.freeRectangles[i]
		if recta ~= _INVALID then
			for j=i+1,rectToProcess,1 do
				local rectb = self.freeRectangles[j]
				if rectb ~= _INVALID then
					if _IsContainedIn(recta, rectb) then
						self.freeRectangles[i] = _INVALID
						--i
					elseif _IsContainedIn(rectb, recta) then
						self.freeRectangles[j] = _INVALID
						--j
					end
				end
			end
		end
	end
	self:compact()
end

-- remove all the empty entries, backwards to prevent having to shift them about if possible
function MaxRects:compact()
	local rectToProcess = #self.freeRectangles
	for i=rectToProcess,1,-1 do
		if self.freeRectangles[i] == _INVALID then
			table.remove(self.freeRectangles,i)
		end
	end
end

--
-- Finalize things
--

local safeMaxRects = _clone(MaxRects)

function MaxRects.new(width, height, canflip)
	local ret = _clone(safeMaxRects)
	ret:init(width,height,canflip)
	return ret
end

-- return the table in case a user expects that with = require 'maxrects'
return MaxRects
