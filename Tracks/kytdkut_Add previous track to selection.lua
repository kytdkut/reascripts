-- @description Add previous track to selected tracks
-- @version 1.0
-- @author kytdkut

num_selected_tracks = reaper.CountSelectedTracks(0)

function Main()
    if num_selected_tracks > 0 then
        selected_track = reaper.GetSelectedTrack(0, 0)
        selected_track_number = reaper.GetMediaTrackInfo_Value(selected_track, "IP_TRACKNUMBER")
        previous_track = reaper.GetTrack(0, selected_track_number - 2) --GetTrack() is zero based
        if previous_track ~= nil then
            reaper.SetTrackSelected(previous_track, true)
        end

    end
end

Main()
