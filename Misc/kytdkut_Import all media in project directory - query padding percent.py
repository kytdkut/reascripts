# description Import all media in project directory - query padding percent
# @version 1.0
# @author kytdkut

# Sound in Words - only intended for internal use
# this is useful when creating RPP files via scripting
# this script imports all the wav media contained in the media_path folder and separates it using the prompted value (kind of)

import reaper_python
from pathlib import Path
from sys import exit

media_files = []
user_input = RPR_GetUserInputs("Insert padding amount", 1, "LoSy percent amount:", 10, 100)
padding_percent = float(user_input[4]) / 100

(path, len) = RPR_GetProjectPath("", 512)
media_path = Path(path)

for file in media_path.glob("[!$._]*.wav"):
    media_files.append(file)

media_files = sorted(media_files)


def main():
    RPR_Undo_BeginBlock()
    
    for file in media_files:
        RPR_InsertMedia(file, 0)
    
    selected_track = RPR_GetSelectedTrack(0, 0)
    num_items = RPR_CountTrackMediaItems(selected_track)
    item_durs = []
    
    
    for i in range(num_items): # get item lengths
        current_item = RPR_GetTrackMediaItem(selected_track, i)
        item_durs.append(RPR_GetMediaItemInfo_Value(current_item, 'D_LENGTH'))

    for i in reversed(range(num_items)): # reposition items leaving 2 times its length in silence afterwards
        current_item = RPR_GetTrackMediaItem(selected_track, i)
        current_item_pos = RPR_GetMediaItemInfo_Value(current_item, 'D_POSITION')
        RPR_SetMediaItemInfo_Value(current_item, 'D_POSITION', current_item_pos * 3)

    item_durs_cut = item_durs # for safety?
    item_durs_cut.pop() # removing last item because we don't need its duration

    for i in reversed(range(num_items)): # get padding_percent of all previous_item_durs and add to current_item_pos
        current_item = RPR_GetTrackMediaItem(selected_track, i)
        current_item_pos = RPR_GetMediaItemInfo_Value(current_item, 'D_POSITION')
        previous_item_durs = sum(item_durs_cut)
        RPR_SetMediaItemInfo_Value(current_item, 'D_POSITION', current_item_pos + previous_item_durs * padding_percent)
        if i > 0: # this is ugly, but the list does not have any more elements to pop now
            item_durs_cut.pop() # removing last element (item dur) each loop

    for i in reversed(range(num_items)): # add 2 extra seconds between items
        current_item = RPR_GetTrackMediaItem(selected_track, i)
        current_item_pos = RPR_GetMediaItemInfo_Value(current_item, 'D_POSITION')
        RPR_SetMediaItemInfo_Value(current_item, 'D_POSITION', current_item_pos + 2 * i)

    RPR_Undo_EndBlock("Import all media in project directory", -1)


if user_input[0] == 1:
    RPR_SetEditCurPos(0, 1, 1)
    main()
    RPR_SetEditCurPos(0, 1, 1)
