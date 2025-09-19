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
ol = require 'orderedlist'

local note_sequence = pd.Class:new():register('note.sequence')

function note_sequence:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 2
    self.next_note_id = 1000
    self:in_1_clear{}
    assert(#atoms <= 0, 'too many args')
    return true
end

function note_sequence:in_1_reload()
    self:dofilex(self._scriptname)
end

function note_sequence:in_1_add(atoms, notify)
    local event, id, note, start, duration
    if #atoms == 3 then
        event = 'added'
        note, start, duration = table.unpack(atoms)
        id = self.next_note_id
        self.next_note_id = self.next_note_id + 1
    elseif #atoms == 4 then
        event = 'changed'
        id, note, start, duration = table.unpack(atoms)
    else
        error('invalid number of args')
    end
    assert(type(note) == 'string', 'invalid type for note')
    note = mt.Note(note)
    assert(type(start) == 'number', 'invalid type for start time')
    assert(type(duration) == 'number', 'invalid type for duration')
    local note_entry = {
        id = id,
        note = note,
        start = start,
        duration = duration,
    }
    self.notes:add(note_entry)
    if notify ~= false then
        self:outlet(2, 'list', {event, note_entry.id, tostring(note_entry.note), note_entry.start, note_entry.duration})
    end
end

local function overlap(a_start, a_end, b_start, b_end)
    return a_start <= b_end and b_start <= a_end
end

local function note_entry_overlap(x, start, duration)
    return overlap(x.start, x.start + x.duration, start, start + duration)
end

local function note_in_range(x, notelow, notehigh)
    return x.note.number >= notelow and x.note.number <= notehigh
end

function note_sequence:in_1_remove(atoms, notify)
    if #atoms == 1 or #atoms == 2 then
        local start, duration = atoms[1], atoms[2] or 0
        assert(type(start) == 'number', 'invalid type for start time')
        assert(type(duration) == 'number', 'invalid type for duration')
        self.notes:remove_if(
            function(note_entry)
                return note_entry_overlap(note_entry, start, duration)
            end,
            nil,
            function(note_entry)
                if notify ~= false then
                    self:outlet(2, 'list', {'removed', note_entry.id, tostring(note_entry.note), note_entry.start, note_entry.duration})
                end
            end
        )
    elseif #atoms == 4 then
        local notelow, notehigh, start, duration = table.unpack(atoms)
        if type(notelow) == 'string' then notelow = mt.Note(notelow).number end
        if type(notehigh) == 'string' then notehigh = mt.Note(notehigh).number end
        assert(type(notelow) == 'number', 'invalid type for note range minimum')
        assert(type(notehigh) == 'number', 'invalid type for note range maximum')
        assert(type(start) == 'number', 'invalid type for start time')
        assert(type(duration) == 'number', 'invalid type for start time')
        self.notes:remove_if(
            function(note_entry)
                return note_entry_overlap(note_entry, start, duration) and note_in_range(note_entry, notelow, notehigh)
            end,
            nil,
            function(note_entry)
                if notify ~= false then
                    self:outlet(2, 'list', {'removed', note_entry.id, tostring(note_entry.note), note_entry.start, note_entry.duration})
                end
            end
        )
    else
        error('invalid number of args')
    end
end

function note_sequence:in_1_change(atoms, notify)
    if #atoms == 6 then
        local oldnote, oldstart, olddur, newnote, newstart, newdur = table.unpack(atoms)
        assert(type(oldnote) == 'string', 'invalid type for old note')
        assert(type(oldstart) == 'number', 'invalid type for start time')
        assert(type(olddur) == 'number', 'invalid type for duration')
        oldnote = mt.Note(oldnote).number
        local old_entry = self.notes:get_if(
            function(note_entry)
                return note_entry_overlap(note_entry, oldstart, olddur) and note_in_range(note_entry, oldnote, oldnote)
            end
        )
        assert(#old_entry > 0, 'time range doesn\'t match any note')
        assert(#old_entry == 1, 'time range matches multiple notes')
        old_entry = old_entry[1]
        self.notes:remove_if(
            function(note_entry)
                return note_entry.id == old_entry.id
            end
        )
        self:in_1_add({old_entry.id, newnote, newstart, newdur})
    elseif #atoms == 4 then
        local id, newnote, newstart, newdur = table.unpack(atoms)
        assert(type(id) == 'number', 'invalid type for old id')
        id = math.floor(id)
        self.notes:remove_if(
            function(note_entry)
                return note_entry.id == id
            end
        )
        self:in_1_add({id, newnote, newstart, newdur})
    else
        error('invalid number of args')
    end
end

function note_sequence:in_1_get(atoms)
    assert(#atoms == 2, 'invalid number of args')
    local start = atoms[1]
    local duration = atoms[2] or 0
    assert(type(start) == 'number', 'invalid type for start time')
    assert(type(duration) == 'number', 'invalid type for duration')
    local notes_in_range = self.notes:get_if(
        function(note_entry)
            return note_entry_overlap(note_entry, start, duration)
        end
    )
    for _, entry in ipairs(notes_in_range) do
        self:outlet(1, 'list', {tostring(entry.note), entry.start, entry.duration})
    end
end

function note_sequence:in_1_play(atoms)
    assert(#atoms >= 1 and #atoms <= 2, 'invalid number of args')
    local start = atoms[1]
    local duration = atoms[2] or 1
    assert(type(start) == 'number', 'invalid type for start time')
    assert(type(duration) == 'number', 'invalid type for duration')
    local notes_in_range = self.notes:get_if(
        function(note_entry)
            return note_entry.start >= start and note_entry.start < (start + duration)
        end
    )
    for _, entry in ipairs(notes_in_range) do
        self:outlet(1, 'list', {tostring(entry.note), entry.start, entry.duration})
    end
end

function note_sequence:in_1_clear(atoms, notify)
    assert(#atoms == 0, 'invalid number of args')
    if self.notes then
        for _, note_entry in ipairs(self.notes:to_table()) do
            if notify ~= false then
                self:outlet(2, 'list', {'removed', note_entry.id, tostring(note_entry.note), note_entry.start, note_entry.duration})
            end
        end
    end
    self.notes = ol.OrderedList(function(a, b)
        return a.start < b.start
    end)
end

function note_sequence:in_1_dump(atoms)
    assert(#atoms == 0, 'invalid number of args')
    pd.post('--------------------------------------------------')
    for _, note_entry in ipairs(self.notes:to_table()) do
        pd.post('' .. tostring(note_entry.note) .. ' ' .. note_entry.start .. ' ' .. note_entry.duration)
    end
    pd.post('--------------------------------------------------')
end

function note_sequence:in_2_list(atoms)
    local cmd = table.remove(atoms, 1)
    if cmd == 'add' then
        self:in_1_add(atoms, false)
    elseif cmd == 'remove' then
        self:in_1_remove(atoms, false)
    elseif cmd == 'change' then
        self:in_1_change(atoms, false)
    else
        error('invalid command: ' .. cmd)
    end
end
