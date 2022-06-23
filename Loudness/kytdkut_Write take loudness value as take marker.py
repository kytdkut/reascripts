# @version 1.0
# @author kytdkut
# description Write take loudness value as take marker

import reaper_python
from sws_python import *

num_selected_items = RPR_CountSelectedMediaItems(0)

def main():
  RPR_Undo_BeginBlock()
  
  for i in range(num_selected_items):
    current_item = RPR_GetSelectedMediaItem(0, i)
    current_take = RPR_GetActiveTake(current_item)
    take_loudness =  NF_AnalyzeTakeLoudness_IntegratedOnly(current_take, 0) 
    retvals = RPR_SetTakeMarker(current_take, 0, str(round(take_loudness[2], 2)) + ' dB LUFS', 0, 0)
  
  RPR_Undo_EndBlock('Insert selected take LUFS as take marker', -1)
  
  
if num_selected_items:
  main()
else:
  RPR_ShowMessageBox('Please select at least one item.', 'Error', 0)
