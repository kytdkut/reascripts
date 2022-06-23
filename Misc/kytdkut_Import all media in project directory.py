# @description Import all media in project directory
# @version 1.0
# @author kytdkut

# Sound in Words - only intended for internal use
#  this is useful when creating RPP files via scripting
# this script imports all the wav media contained in the media_path folder and separates it using certain criteria

import reaper_python
from pathlib import Path

media_files = []

(path, len) = RPR_GetProjectPath("", 512)
media_path = Path(path)

for file in media_path.glob("*.wav"):
    media_files.append(file)

media_files = sorted(media_files)


def main():
    RPR_Undo_BeginBlock()
    
    for file in media_files:
        RPR_InsertMedia(file, 0)
    
    selected_track = RPR_GetSelectedTrack(0, 0)
    num_items = RPR_CountTrackMediaItems(selected_track)
    item_durs = []
    
    
    for i in range(num_items):
        current_item = RPR_GetTrackMediaItem(selected_track, i)
        item_durs.append(RPR_GetMediaItemInfo_Value(current_item, 'D_LENGTH'))
    for i in reversed(range(num_items)):
        current_item = RPR_GetTrackMediaItem(selected_track, i)
        current_item_pos = RPR_GetMediaItemInfo_Value(current_item, 'D_POSITION')
        RPR_SetMediaItemInfo_Value(current_item, 'D_POSITION', current_item_pos * 3)
    for i in reversed(range(num_items)):
        current_item = RPR_GetTrackMediaItem(selected_track, i)
        current_item_pos = RPR_GetMediaItemInfo_Value(current_item, 'D_POSITION')
        RPR_SetMediaItemInfo_Value(current_item, 'D_POSITION', current_item_pos + 2 * i)
    
    RPR_Undo_EndBlock("Import all media in project directory", -1)


RPR_SetEditCurPos(0, 1, 1)
main()
RPR_SetEditCurPos(0, 1, 1)