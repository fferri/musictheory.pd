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
    if #atoms == 2 then
        table.insert(self.cur_scales, mt.Scale(atoms[1], atoms[2]))
    elseif #atoms ~= 0 then
        error('too many args')
    end
    return true
end

function scale_identify2:in_1_reload()
    self:dofilex(self._scriptname)
end

function scale_identify2:in_1_list(atoms)
    local notes = table.map(function(x) return mt.Note(x) end, atoms)

    local old_scales = {}
    for i, scale in ipairs(self.cur_scales) do
        if scale:contains(notes) then
            old_scales[scale] = i
        end
    end

    local new_scales = mt.Scale:identify(notes)
    local b = #self.cur_scales + 2
    for _, scale in ipairs(new_scales) do
        local d
        for _, old_scale in ipairs(self.cur_scales) do
            local d1 = scale:distance(old_scale)
            d = math.min(d or d1, d1)
        end
        old_scales[scale] = (old_scales[scale] or b) - 1 + d
    end

    local new_scales = {}
    for scale in pairs(old_scales) do
        table.insert(new_scales, scale)
    end
    table.sort(new_scales, function(a, b) return old_scales[a] < old_scales[b] end)

    local out = {}
    for _, scale in ipairs(new_scales) do
        table.insert(out, tostring(scale.root))
        table.insert(out, scale.recipe)
        table.insert(out, 0) --score(scale))
    end
    self:outlet(1, 'list', out)
    self.cur_scales = new_scales
end

function scale_identify2:in_1_reset(atoms)
    assert(#atoms == 0, 'invalid number of args')
    self.cur_scales = {}
end
