-- description Insert QA from clipboard into project
-- @version 1.01
-- @author kytdkut

-- Sound in Words - only intended for internal use
-- http://lua-users.org/wiki/StringLibraryTutorial
-- no hay forma de saber qué tipo de QA es, a menos que haya ambos QA (Audio + CL)
-- se asume que la mayoría son QA Audio

local clipboard, index = reaper.CF_GetClipboard(''), 0

function SplitStr(input_str)
  local t = {}
  for str in string.gmatch(input_str, "([^".."\t".."]+)") do
    table.insert(t, str)
  end
  return t
end

function Main()
  reaper.Undo_BeginBlock()
  
  for line in clipboard:gmatch("([^\r\n]*)[\r\n]*") do
    line_split = SplitStr(line)
    filename = line_split[1]:sub(11) -- sacar 0000audio_
    filename = filename:sub(1, -5) -- sacar .wav
    _, num_mrk, num_rgn = reaper.CountProjectMarkers(0) -- se cuenta dentro del loop porque cada vez que agregás un marker el count cambia
    num_mrkrgn = num_mrk + num_rgn
    for i = 0, num_mrkrgn - 1 do
      _, _, pos, _, name, _ = reaper.EnumProjectMarkers(i)
      if name == filename then
        if #line_split == 2 then -- es solo QA Audio...
          reaper.AddProjectMarker2(0, 0, pos, 0, line_split[2], -1, 0x17373C2)
        elseif #line_split == 3 then -- o tiene además CL?
          reaper.AddProjectMarker2(0, 0, pos, 0, line_split[2] .. " // " .. line_split[3], -1, 0x1C2A873)
        elseif #line_split == 4 then -- o tiene además CL y QA TEC?
          reaper.AddProjectMarker2(0, 0, pos, 0, line_split[2] .. " // " .. line_split[3], -1, 0x164B499)
        end
      end
    end
  end

  reaper.Undo_EndBlock("Insert QA from clipboard into project",-1)
end

Main()
