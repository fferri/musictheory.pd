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

local mt = require 'musictheory'

local scale_harmonize = pd.Class:new():register('scale.harmonize')

function scale_harmonize:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 1
    if #atoms >= 1 then
        self.root_pitch = mt.PitchClass(atoms[1])
    end
    if #atoms >= 2 then
        self.scale_name = atoms[2]
        self.scale = mt.Scale(self.root_pitch, self.scale_name)
    end
    assert(#atoms <= 2, 'too many args')
    return true
end

function scale_harmonize:in_1_reload()
    self:dofilex(self._scriptname)
end

function scale_harmonize:in_1_float(x)
    if self.scale then
        local idx = math.floor(x + 0.5)
        self:outlet(1, "symbol", {tostring(self.scale[idx])})
    end
end

function scale_harmonize:in_1_set(atoms)
    assert(#atoms == 2, 'invalid number of args')
    self.root_pitch = mt.PitchClass(atoms[1])
    self.scale_name = atoms[2]
    self.scale = mt.Scale(self.root_pitch, self.scale_name)
end
