--=======================================================================
-- File Name    : dice_protect.bytes
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 18/08/2016 11:24:12
-- Description  : description
-- Modify       :
--=======================================================================

local Class = require("lib.class")

local Dice = Class:New(nil, "DICE_PROTECT")
local random = math.random

function Dice:_Init(odds, max_value)
    self.odds = odds
    self.max_value = max_value

    self.protect_max_count = math.ceil(max_value / odds)
    self.protect_count = 0
end

function Dice:_Uninit()
end

function Dice:Roll()
    if self.protect_count >= self.protect_max_count or random(self.max_value) <= self.odds then
        self.protect_count = 0
        return true
    else
        self.protect_count = self.protect_count + 1
        return false
    end
end


--Unit Test
if arg and arg[1] == "dice_protect.bytes" then
    math.randomseed(os.time())
    local dice = Dice()
    dice:Init(200, 1000)

    print(dice:Roll())
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
