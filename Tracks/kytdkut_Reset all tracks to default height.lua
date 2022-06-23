-- description Reset height for all tracks
-- @version 1.0
-- @author kytdkut
-- @about tune 'height_px' to your liking

tracks_count = reaper.CountTracks(0)
height_px = 55

function main()
  for i = 0, tracks_count - 1  do
    local track = reaper.GetTrack(0, i)
    reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", height_px)

  end

end

main()

-- reaper.UpdateArrange()
reaper.TrackList_AdjustWindows(true)
