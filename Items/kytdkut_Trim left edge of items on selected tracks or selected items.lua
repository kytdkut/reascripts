-- description Trim left edge of item under edit cursor on selected tracks, or all tracks if none selected
-- @version 1.0
-- @author kytdkut

cursor_pos = reaper.GetCursorPosition();
num_current_tracks = reaper.CountSelectedTracks(0);

if num_current_tracks == 0 then
  num_current_tracks = reaper.CountTracks(0); -- apply on all tracks if none selected
end

function Main()
	reaper.Undo_BeginBlock()

	for track_index = 0, num_current_tracks - 1 do
		current_track = reaper.GetSelectedTrack(0, track_index)

		if current_track == nil then
			current_track = reaper.GetTrack(0, track_index) -- no track selected variation
		end
	
		num_items = reaper.GetTrackNumMediaItems(current_track)
	
		if num_items == 0 then goto next end -- skips this track if it has no media items
	
		for item_index = 0, num_items - 1 do
			current_item = reaper.GetTrackMediaItem(current_track, item_index)
			current_item_len = reaper.GetMediaItemInfo_Value(current_item, "D_LENGTH") 
			edge_left = reaper.GetMediaItemInfo_Value(current_item, "D_POSITION")
			edge_right = edge_left + current_item_len

			-- check if the current media item is under the cursor, else skip it
			if edge_left < cursor_pos and edge_right > cursor_pos then
				current_take = reaper.GetActiveTake(current_item)
				cursor_offset = edge_left - cursor_pos;
				current_item_startoffs = reaper.GetMediaItemTakeInfo_Value(current_take, "D_STARTOFFS")
				current_item_snap = reaper.GetMediaItemTakeInfo_Value(current_take, "D_SNAPOFFSET")
		  		-- trim left edge
		  		reaper.SetMediaItemInfo_Value(current_item, "D_POSITION", cursor_pos)
		  		reaper.SetMediaItemInfo_Value(current_item, "D_LENGTH", current_item_len + cursor_offset)
		  		reaper.SetMediaItemTakeInfo_Value(current_take, "D_STARTOFFS", current_item_startoffs - cursor_offset)
		  		if current_item_snap + cursor_offset < 0 then
					reaper.SetMediaItemInfo_Value(current_item, "D_SNAPOFFSET", 0)
				else
		  			reaper.SetMediaItemInfo_Value(current_item, "D_SNAPOFFSET", current_item_snap + cursor_offset)
		  		end
			end
		end

	end ::next::

	reaper.Undo_EndBlock("Trim left edge of item under edit cursor on selected tracks",-1)
end

Main()
reaper.UpdateArrange()
