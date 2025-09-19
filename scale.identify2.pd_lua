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

local scale_identify2 = pd.Class:new():register('scale.identify2')

function scale_identify2:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 1
    self.cur_scales = {}
    assert(#atoms <= 0, 'too many args')
    return true
end

function scale_identify2:in_1_reload()
    self:dofilex(self._scriptname)
end

function scale_identify2:in_1_list(atoms)
    local notes = table.map(function(x) return mt.Note(x) end, atoms)
    local new_scales = mt.Scale:identify(notes)
    local function score(scale)
        local witems = {}
        local in_current = false
        for _, note in ipairs(notes) do
            witems[note] = 10
        end
        for _, cur_scale in ipairs(self.cur_scales) do
            witems[cur_scale] = 1
            in_current = in_current or cur_scale == scale
        end
        return scale:wpcp_score(witems) + (in_current and 100 or 0)
    end
    table.sort(new_scales, function(a, b) return score(a) > score(b) end)
    local out = {}
    for _, scale in ipairs(new_scales) do
        table.insert(out, tostring(scale.root))
        table.insert(out, scale.recipe)
        table.insert(out, score(scale))
    end
    self:outlet(1, 'list', out)
    self.cur_scales = new_scales
end

function scale_identify2:in_1_reset(atoms)
    assert(#atoms == 0, 'invalid number of args')
    self.cur_scales = 0
end
