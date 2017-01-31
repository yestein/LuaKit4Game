--=======================================================================
-- File Name    : fraction.bytes
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 08/12/2016 22:50:39
-- Description  : description
-- Modify       :
--=======================================================================

local Class = require("lib.class")
local Util = require("lib.util")
local Fraction = Class:New(nil, "FRACTION")

function Fraction:Clone(fraction)
    return Fraction(fraction.numerator, fraction.denominator)
end

function Fraction:_OnCreate(numerator, denominator)
    -- self:SetDataByKey("numerator", numerator)
    -- self:SetDataByKey("denominator", denominator)
    local gcd = Util.GCD(numerator, denominator)
    self.numerator = numerator / gcd
    self.denominator = denominator / gcd
    self.is_fraction = true

    local mt = getmetatable(self)
    mt.__add = function(a, b)
        if type(a) == "number" and b.is_fraction then
            local _denominator = b.denominator
            local _numerator = _denominator * a + b.numerator
            return Fraction(_numerator, _denominator)
        elseif a.is_fraction and type(b) == "number" then
            local _denominator = a.denominator
            local _numerator = _denominator * b + a.numerator
            return Fraction(_numerator, _denominator)
        elseif a.is_fraction and b.is_fraction then
            if a.denominator == b.denominator then
                return Fraction(a.numerator + b.numerator, a.denominator)
            else
                local _denominator = a.denominator * b.denominator
                local _numerator = a.numerator * b.denominator + b.numerator * a.denominator
                return Fraction(_numerator, _denominator)
            end
        end
    end

    mt.__sub = function(a, b)
        if type(a) == "number" and b.is_fraction then
            local _denominator = b.denominator
            local _numerator = _denominator * a - b.numerator
            return Fraction(_numerator, _denominator)
        elseif a.is_fraction and type(b) == "number" then
            local _denominator = a.denominator
            local _numerator = _denominator * b - a.numerator
            return Fraction(_numerator, _denominator)
        elseif a.is_fraction and b.is_fraction then
            if a.denominator == b.denominator then
                return Fraction(a.numerator - b.numerator, a.denominator)
            else
                local _denominator = a.denominator * b.denominator
                local _numerator = a.numerator * b.denominator - b.numerator * a.denominator
                return Fraction(_numerator, _denominator)
            end
        end
    end

    mt.__mul = function(a, b)
        if type(a) == "number" and b.is_fraction then
            local _denominator = b.denominator
            local _numerator = a * b.numerator
            return Fraction(_numerator, _denominator)
        elseif a.is_fraction and type(b) == "number" then
            local _denominator = a.denominator
            local _numerator = b * a.numerator
            return Fraction(_numerator, _denominator)
        elseif a.is_fraction and b.is_fraction then
            local _denominator = a.denominator * b.denominator
            local _numerator = a.numerator * b.numerator
            return Fraction(_numerator, _denominator)
        end
    end

    mt.__div = function(a, b)
        if type(a) == "number" and b.is_fraction then
            local _numerator = a * b.denominator
            local _denominator = b.numerator

            return Fraction(_numerator, _denominator)
        elseif a.is_fraction and type(b) == "number" then
            local _numerator = a * a.numerator
            local _denominator = a.denominator * b

            return Fraction(_numerator, _denominator)
        elseif a.is_fraction and b.is_fraction then
            local _numerator = a.numerator * b.denominator
            local _denominator = a.denominator * b.numerator

            return Fraction(_numerator, _denominator)
        end
    end

    mt.__eq = function(a, b)
        if type(a) == "number" and b.is_fraction then
            if b.denominator ~= 1 then
                return false
            end
            return b.numerator == a

        elseif a.is_fraction and type(b) == "number" then
            if a.denominator ~= 1 then
                return false
            end
            return a.numerator == b
        elseif a.is_fraction and b.is_fraction then
            local _numerator = a.numerator * b.denominator
            local _denominator = a.denominator * b.numerator
            return b.numerator == a.numerator and a.denominator == b.denominator
        end
    end

    mt.__lt = function(a, b)
        if type(a) == "number" and b.is_fraction then
            return a < b:Value()
        elseif a.is_fraction and type(b) == "number" then
            return a:Value() < b
        elseif a.is_fraction and b.is_fraction then
            return a:Value() < b:Value()
        end
    end

    mt.__le = function(a, b)
        if type(a) == "number" and b.is_fraction then
            return a <= b:Value()
        elseif a.is_fraction and type(b) == "number" then
            return a:Value() <= b
        elseif a.is_fraction and b.is_fraction then
            return a:Value() <= b:Value()
        end
    end

    mt.__tostring = function()
        return self:Str()
    end
end

function Fraction:Value()
    return self.numerator / self.denominator
end

function Fraction:Str()
    return string.format("%d/%d", self.numerator, self.denominator)
end

--Unit Test
if arg and arg[1] == "fraction.bytes" then
    local a = Fraction(1, 3)
    local b = Fraction(1, 2)
    local c = 1

    print(a + b, type(a+b), (a+b):Value())
    print(b + c, type(b+c), (b+c):Value())
    print(a + c, type(a+c), (a+c):Value())

    print(b - b)
    print(b * b)
    print(b / b)
    print(a > b)
    print(b + b + b + b)
    print( (b / b * 2) > (b + b + b + b))
end

return Fraction
