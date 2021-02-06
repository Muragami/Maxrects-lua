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

local function _FindPositionForNewNodeBSSF(self, width, height, scores)
	local bestNode = {}

	scores[1] = math.huge -- bestShortSideFit
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

			if shortSideFit < bestShortSideFit or (shortSideFit == bestShortSideFit and longSideFit < bestLongSideFit) then
				bestNode[1] = rect[1]
				bestNode[2] = rect[2]
				bestNode[3] = width
				bestNode[4] = height
				bestShortSideFit = shortSideFit
				bestLongSideFit = longSideFit
			end
		end

		if self.bFlip and rect[3] >= height and rect[4] >= width then
			local flippedLeftoverHoriz = math.abs(rect[3] - height);
			local flippedLeftoverVert = math.abs(rect[4] - width);
			local flippedShortSideFit = math.min(flippedLeftoverHoriz, flippedLeftoverVert);
			local flippedLongSideFit = math.max(flippedLeftoverHoriz, flippedLeftoverVert);

			if flippedShortSideFit < bestShortSideFit or (flippedShortSideFit == bestShortSideFit and flippedLongSideFit < bestLongSideFit) then
				bestNode[1] = rect[1]
				bestNode[2] = rect[2]
				bestNode[3] = width
				bestNode[4] = height
				bestShortSideFit = flippedShortSideFit;
				bestLongSideFit = flippedLongSideFit;
			end
		end
	end
	return bestNode
end

local function _FindPositionForNewNodeBLSF(self, width, height, scores)
end

local function _FindPositionForNewNodeBAF(self, width, height, scores)
end

local function _FindPositionForNewNodeBL(self, width, height, scores)
end

local function _FindPositionForNewNodeCP(self, width, height, scores)
end

-- table for our various heuristic functions
local FreeRectChoiceHeuristic = {
		RectBestShortSideFit = _FindPositionForNewNodeBSSF,
			-- -BSSF: Positions the rectangle against the short side of a free rectangle into which it fits the best.
		RectBestLongSideFit = _FindPositionForNewNodeBLSF,
			-- -BLSF: Positions the rectangle against the long side of a free rectangle into which it fits the best.
		RectBestAreaFit = _FindPositionForNewNodeBAF,
			-- -BAF: Positions the rectangle into the smallest free rect into which it fits.
		RectBottomLeftRule = _FindPositionForNewNodeBL,
			-- -BL: Does the Tetris placement.
		RectContactPointRule =  _FindPositionForNewNodeCP }
			-- -CP: Choosest the placement where the rectangle touches other rects as much as possible.

local function _CompareRectShortSide(ra,rb)
end

local function _NodeSortCmp(ra,rb)
end

local function _IsContainedIn(ra,rb)
	return ra.x >= rb.x and ra.y >= rb.y
				and ra.x+ra.width <= rb.x+rb.width
				and ra.y+ra.height <= rb.y+rb.height
end

MaxRects = { bWidth = 0, bWeight = 0, bFlip = false,
	freeRectangles = {}, usedRectangles = {},
 	algorithm = _FindPositionForNewNodeBSSF, scores = {} }

function MaxRects:Insert(width, height)
	local newNode
	self.scores[1] = math.huge
	self.scores[2] = math.huge
	newNode = self:algorithm(width, height, self.scores)
	if newNode[4] == 0 then return newNode end
	local rectToProcess = #self.freeRectangles
	local toRemove = {}
	for i=1,rectToProcess,1 do
		if self.freeRectangles[i] ~= _INVALID then
			if self:SplitFreeNode(self.freeRectangles[i], newNode) then table.insert(toRemove, i) end
		end
	end
	-- remove rectangles as needed
	for _,v in ipairs(toRemove) do
		self.freeRectangles[v] = _INVALID
	end
	self:PruneFreeList()
	table.insert(self.usedRectangles,newNode)
end

function MaxRects:Occupancy()
	local usedSurfaceArea = 0
	local count = #self.usedRectangles
	for i=1,count,1 do
		local rect = self.usedRectangles[i]
		usedSurfaceArea = usedSurfaceArea + rect[3] * rect[4]
	end
	return usedSurfaceArea / (self.bWidth * self.bHeight)
end

function MaxRects:init(width,height,canflip)
	self.bFlip = canflip
	self.bWidth = width
	self.bHeight = height
	self.freeRectangles = {}
	self.usedRectangles = {}
	table.insert(self.freeRectangles, { 0, 0, width, height })
end

function MaxRects:setAlgorithm(algo)
	if FreeRectChoiceHeuristic[algo] then
		self.algorithm = FreeRectChoiceHeuristic[algo]
	else error("MaxRects:setAlgorithm() got bad algo: " .. algo) end
end

function MaxRects:ScoreRect(width, height, scores)
	local newNode
	scores[1] = math.huge
	scores[2] = math.huge
	newNode = self:algorithm(width, height, scores)

	-- Cannot fit the current rectangle.
	if (newNode[4] == 0) then
		scores[1] = math.huge
		scores[2] = math.huge
	end

	return newNode
end

function MaxRects:PlaceRect(node)
	local rectToProcess = #self.freeRectangles
	local toRemove = {}
	for i=1,rectToProcess,1 do
		if self.freeRectangles[i] ~= _INVALID then
			if self:SplitFreeNode(self.freeRectangles[i], newNode) then table.insert(toRemove, i) end
		end
	end
	-- remove rectangles as needed
	for _,v in ipairs(toRemove) do
		self.freeRectangles[v] = _INVALID
	end
	self:PruneFreeList()
	table.insert(self.usedRectangles,node)
end

function MaxRects:ContactPointScoreNode(x, y, width, height)
	-- TODO
end

function MaxRects:SplitFreeNode(freeNode, usedNode)
	-- TODO
end

function MaxRects:PruneFreeList()
	-- TODO
end


return MaxRects
