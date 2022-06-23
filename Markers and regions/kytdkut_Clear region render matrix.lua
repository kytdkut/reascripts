-- description Add next track to selected tracks
-- @version 1.0
-- @author kytdkut

master_track = reaper.GetMasterTrack(0)
count_tracks = reaper.CountTracks(0)

i = 0

repeat
	iRetval, bIsrgn, iPos, iRgnend, sName, iIndex = reaper.EnumProjectMarkers(i)
	if iRetval >= 1 then
		if bIsrgn == true then
			reaper.SetRegionRenderMatrix(0, iIndex, master_track, -1)
			for j = 0 , count_tracks - 1 do
				track = reaper.GetTrack(0, j)
				reaper.SetRegionRenderMatrix(0, iIndex, track, -1)
			end
		end
		i = i + 1 
	end
until iRetval == 0
