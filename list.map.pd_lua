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

local list_map = pd.Class:new():register('list.map')

function list_map:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 2
    assert(#atoms <= 0, 'too many args')
    return true
end

function list_map:in_1_reload()
    self:dofilex(self._scriptname)
end

function list_map:in_1_list(x)
    self._current_list = {}
    for _, xi in ipairs(x) do
        local sel = 'bang'
        if type(xi) == 'number' then
            sel = 'float'
        elseif type(xi) == 'string' then
            sel = 'symbol'
        else
            error('unknown type: ' .. type(xi))
        end
        self:outlet(2, sel, {xi})
    end
    self:outlet(1, "list", self._current_list)
end

function list_map:in_2(sel, atoms)
    for _, xi in ipairs(atoms) do
        table.insert(self._current_list, xi)
    end
end
