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

local scale_identify = pd.Class:new():register('scale.identify')

function scale_identify:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 2
    self.items = {}
    assert(#atoms <= 0, 'too many args')
    return true
end

function scale_identify:in_1_reload()
    self:dofilex(self._scriptname)
end

function scale_identify:in_1_add_note(atoms)
    assert(type(atoms[1]), 'note arg is required')
    self:add_weight(mt.Note(atoms[1]), atoms[2] or 1)
    self:in_1_bang()
end

function scale_identify:in_1_add_chord(atoms)
    assert(type(atoms[1]), 'chord arg is required')
    self:add_weight(mt.Chord(atoms[1]), atoms[2] or 1)
    self:in_1_bang()
end

function scale_identify:add_weight(item, weight)
    self.items[item] = (self.items[item] or 0) + weight
end

function scale_identify:in_1_fade(atoms)
    local k = atoms[1] or 0.5
    for item, weight in pairs(self.items) do
        self.items[item] = weight * k
    end
end

function scale_identify:in_1_reset(atoms)
    self.items = {}
end

function scale_identify:in_1_bang()
    local scale, score = mt.Scale:identify_wpcp(self.items)
    self:outlet(2, 'symbol', {tostring(scale.recipe)})
    self:outlet(1, 'symbol', {tostring(scale.root)})
end
