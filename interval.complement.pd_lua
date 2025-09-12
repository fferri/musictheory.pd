--[[
Copyright (C) 2025 Federico Ferri

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, version 3.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see https://www.gnu.org/licenses/.
--]]

arg = {}
mt = require 'musictheory'

local interval_complement = pd.Class:new():register('interval.complement')

function interval_complement:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 1
    assert(#atoms <= 0, 'too many args')
    return true
end

function interval_complement:in_1_reload()
    self:dofilex(self._scriptname)
end

function interval_complement:in_1_symbol(x)
    local interval = mt.Interval(x)
    interval = interval:complement()
    self:outlet(1, "symbol", {tostring(interval)})
end
