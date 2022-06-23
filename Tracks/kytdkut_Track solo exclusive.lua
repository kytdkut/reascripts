-- @description Track solo exclusive
-- @version 1.0
-- @author kytdkut

num_tracks = reaper.CountTracks(0)

for i = 0, num_tracks -1 do
	current_track = reaper.GetTrack(0, i)
	is_selected = reaper.GetMediaTrackInfo_Value(current_track, "I_SELECTED")
	if is_selected == 1 then
		is_soloed = reaper.GetMediaTrackInfo_Value(current_track, "I_SOLO") 
		if is_soloed == 0 then
			is_soloed = 2
		else
			is_soloed = 0
		end
		reaper.SetMediaTrackInfo_Value(current_track, "I_SOLO", is_soloed)
	else
		reaper.SetMediaTrackInfo_Value(current_track, "I_SOLO", 0)
	end
end
