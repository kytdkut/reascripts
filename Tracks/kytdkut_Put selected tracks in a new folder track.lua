-- description Enclose selected tracks in a new folder track
-- @version 1.0
-- @author kytdkut

num_selected_tracks = reaper.CountSelectedTracks(0)

function Main()
    if num_selected_tracks > 0 then
    	first_selected_track = reaper.GetSelectedTrack(0, 0)
    	first_selected_track_number = reaper.GetMediaTrackInfo_Value(first_selected_track, "IP_TRACKNUMBER")
    	reaper.InsertTrackAtIndex(first_selected_track_number - 1, false)
    	reaper.ReorderSelectedTracks(first_selected_track_number + 1, 1)
    end
end

Main()
