-- @description Track record arm exclusive
-- @version 1.0
-- @author kytdkut

num_tracks = reaper.CountTracks(0)

for i = 0, num_tracks -1 do
	current_track = reaper.GetTrack(0, i)
	is_selected = reaper.GetMediaTrackInfo_Value(current_track, "I_SELECTED")
	if is_selected == 1 then
		is_armed = reaper.GetMediaTrackInfo_Value(current_track, "I_RECARM") 
		if is_armed == 0 then
			is_armed = 1
		else
			is_armed = 0
		end
		reaper.SetMediaTrackInfo_Value(current_track, "I_RECARM", is_armed)
	else
		reaper.SetMediaTrackInfo_Value(current_track, "I_RECARM", 0)
	end
end
