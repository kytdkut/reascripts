-- description Float first VSTi on selected track
-- @version 1.0
-- @author kytdkut

function FloatInstrument(track, toggle)
  local vsti_id = reaper.TrackFX_GetInstrument(track)
  if vsti_id and vsti_id >= 0 then 
    if not toggle then 
      reaper.TrackFX_Show(track, vsti_id, 3) -- float
     else
      local is_float = reaper.TrackFX_GetOpen(track, vsti_id)
      if is_float == false then reaper.TrackFX_Show(track, vsti_id, 3) else reaper.TrackFX_Show(track, vsti_id, 2) end
    end
    
    return true
  end
end
  
local tr = reaper.GetSelectedTrack(0,0)
if tr then
  FloatInstrument(tr, true)
end
