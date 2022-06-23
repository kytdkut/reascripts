-- description Shrink selected items to fit their regions
-- @version 1.0
-- @author kytdkut

sel_item_count = reaper.CountSelectedMediaItems(0)

function Main()

  reaper.Undo_BeginBlock()
  _, num_mrk, num_rgn = reaper.CountProjectMarkers(0)
  num_mrkrgn = num_mrk + num_rgn

  for i = 0, sel_item_count - 1 do
      item = reaper.GetSelectedMediaItem(0, i)
      take = reaper.GetActiveTake(item)
      item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      item_end = item_pos + item_len
      take_playrate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
      for i = 0, num_mrkrgn -1 do
        _, is_rgn, pos, rgn_end, _, _ = reaper.EnumProjectMarkers(i)
        if is_rgn == true then
          if pos <= item_pos and rgn_end < item_end and rgn_end > item_pos then
            new_len = item_len - (item_end - rgn_end)
            new_playrate = take_playrate * item_len / new_len
            reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE", new_playrate)
            reaper.SetMediaItemInfo_Value(item, "D_LENGTH", new_len)
          end
        end
      end
    end

  reaper.Undo_EndBlock("Shrink selected items to fit their regions",-1)
end

if sel_item_count > 0 then
  Main()
end
