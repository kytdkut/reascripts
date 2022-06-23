-- description position next item on track 0.25s of cursor or end of selected item (if any) - ripple all
-- @version 1.0
-- @author kytdkut

desired_distance = 0.25 -- edit!
amount_to_move = 0.0
have_first_item = false
loop_start = 0

track_count = reaper.CountTracks(0)
selected_track = reaper.GetSelectedTrack(0, 0)
selected_item = reaper.GetSelectedMediaItem(0, 0)
starting_position = reaper.GetCursorPosition()

function GetItemPos(item)
    return reaper.GetMediaItemInfo_Value(item, "D_POSITION")
end

function Main()

    if selected_item ~= nil then -- we use the right edge of selected item (if any) to measure the positioning distance
        starting_position = GetItemPos(selected_item) + reaper.GetMediaItemInfo_Value(selected_item, "D_LENGTH")
    end

    if selected_track ~= nil then
        selected_track_num = reaper.GetMediaTrackInfo_Value(selected_track, "IP_TRACKNUMBER", 0)
        loop_start = selected_track_num - 1 -- we want the loop to start on the selected track to define amount_to_move
    end

    ::start::
    for i = loop_start, track_count - 1 do 
        current_track = reaper.GetTrack(0, i)
        item_count = reaper.CountTrackMediaItems(current_track)
    	for j = 0, item_count - 1 do
    		current_item = reaper.GetTrackMediaItem(current_track, j)
    		current_item_pos = GetItemPos(current_item)
    			if current_item_pos >= starting_position then
    				if have_first_item == false then -- we get amount_to_move
                        amount_to_move = desired_distance - (current_item_pos - starting_position)
                        have_first_item = true
                        loop_start = 0 -- start again, this time looping over all tracks in project
    					goto start
    				end
    				reaper.SetMediaItemInfo_Value(current_item, "D_POSITION", current_item_pos + amount_to_move)
                end
        end
    end
end

Main()
