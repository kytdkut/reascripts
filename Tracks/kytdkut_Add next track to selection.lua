-- description Add next track to selected tracks
-- @version 1.0
-- @author kytdkut

num_selected_tracks = reaper.CountSelectedTracks(0)

function Main()
    if num_selected_tracks > 0 then
        selected_track = reaper.GetSelectedTrack(0, 0)
        last_selected_track = reaper.GetMediaTrackInfo_Value(selected_track, "IP_TRACKNUMBER") + num_selected_tracks - 1
        next_track = reaper.GetTrack(0, last_selected_track) --GetTrack() is zero based
        if next_track ~= nil then
            reaper.SetTrackSelected(next_track, true)
        end
    end
end

Main()
