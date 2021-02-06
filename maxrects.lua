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

local function _FindPositionForNewNodeBSSF(width, height, scores)
end

local function _FindPositionForNewNodeBLSF(width, height, scores)
end

local function _FindPositionForNewNodeBAF(width, height, scores)
end

local function _FindPositionForNewNodeBL(width, height, scores)
end

local function _FindPositionForNewNodeCP(width, height, scores)
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
end

MaxRects = { bWidth = 0, bWeight = 0, bFlip = false,
	freeRectangles = {}, usedRectangles = {} }

function MaxRects:init(width,height,canflip)
	self.bFlip = canflip
	self.bWidth = width
	self.bHeight = height
end

function MaxRects:ScoreRect(width, height, method, scores)
end

function MaxRects:Insert(width, height, method)
end

function MaxRects:Occupancy()
end
