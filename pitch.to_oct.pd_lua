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

local pitch_to_oct = pd.Class:new():register('pitch.to_oct')

function pitch_to_oct:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 1
    assert(#atoms == 1, 'argument is required')
    self:in_2_float(atoms[1])
    return true
end

function pitch_to_oct:in_1_reload()
    self:dofilex(self._scriptname)
end

function pitch_to_oct:in_1_symbol(x)
    local pitch = mt.PitchClass(x)
    pitch = pitch:to_octave(self.octave)
    self:outlet(1, "symbol", {tostring(pitch)})
end

function pitch_to_oct:in_2_float(x)
    self.octave = math.floor(x + 0.5)
    assert(math.abs(self.octave - x) < 1e-5, 'octave must be integer')
end
