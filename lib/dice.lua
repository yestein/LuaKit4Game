--=======================================================================
-- File Name    : dice.bytes
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 18/08/2016 11:32:09
-- Description  : description
-- Modify       :
--=======================================================================

local Class = require("lib.class")

local Dice = Class:New(nil, "DICE")
local random = math.random

function Dice:_Init(odds, max_value)
    self.odds = odds
    self.max_value = max_value
end

function Dice:_Uninit()
end

function Dice:GetResult(max_value)
    return random(max_value)
end

function Dice:Roll(odds)
    if not odds then
        odds = self.odds
    end
    local result = self:GetResult(self.max_value)
    if result <= odds then
        return true
    end
    return false
end


--Unit Test
if arg and arg[1] == "dice.bytes" then
    math.randomseed(os.time())
    local dice = Dice()
    dice:Init(200, 1000)

    print(dice:Roll())
    print(dice:Roll())
    print(dice:Roll())

    local true_count = 0
    for i = 1, 30000 do
        if dice:Roll() then
            true_count = true_count + 1
        end
    end
    print(true_count / 30000)
end

return Dice
