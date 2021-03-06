-- description extend time selection to next item edge on selected tracks
-- @version 1.0
-- @author kytdkut

cursor_pos = reaper.GetCursorPosition();
time_sel_start, time_sel_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
num_current_tracks = reaper.CountSelectedTracks(0);

if num_current_tracks == 0 then
	num_current_tracks = reaper.CountTracks(0);
end

function Main()
	move_to = cursor_pos
	last_matching = cursor_pos

	-- this for loop checks all items on selected tracks to define move_to
	for track_index = 0, num_current_tracks - 1 do
	    current_track = reaper.GetSelectedTrack(0, track_index)

	    if current_track == nil then
	    	current_track = reaper.GetTrack(0, track_index)
	    end

		num_items = reaper.GetTrackNumMediaItems(current_track)

		if num_items == 0 then goto next end

	    for item_index = num_items -1, 0, -1 do
	    	current_item = reaper.GetTrackMediaItem(current_track, item_index)
	    	edge_left = reaper.GetMediaItemInfo_Value(current_item, "D_POSITION")
	    	edge_right = edge_left + reaper.GetMediaItemInfo_Value(current_item, "D_LENGTH") 
	
	    	-- check if any of the current item edges is _after_ the cursor
	    	if edge_left > cursor_pos then
	    		last_matching = edge_left
	    	elseif edge_right > cursor_pos then
	    		last_matching = edge_right
	    	else goto next end -- skip this item if it is before the cursor

			if move_to == cursor_pos or last_matching < move_to then
				move_to = last_matching
			end
		end ::next::
	end ::next::

	reaper.Undo_OnStateChange("Move edit cursor to next item edge on selected track")
	if cursor_pos == move_to then return end -- don't do anything if there is no matching edge

	if time_sel_start ~= time_sel_end and time_sel_start < cursor_pos then
		reaper.GetSet_LoopTimeRange2(0, true, false, time_sel_start, move_to, false)
	else
		reaper.GetSet_LoopTimeRange2(0, true, false, cursor_pos, move_to, false)
	end

	reaper.SetEditCurPos(move_to, 1, 0);

end

Main()
