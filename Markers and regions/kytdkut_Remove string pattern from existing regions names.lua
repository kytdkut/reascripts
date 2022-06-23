-- description Remove string pattern from existing regions names
-- @version 1.0
-- @author kytdkut

count_retval, num_markers, num_regions = reaper.CountProjectMarkers(0)

retval, user_input_csv = reaper.GetUserInputs("Insert string patterns to remove", 2, "First pattern:,Second pattern:,extrawidth=10", "%d+audio_,%.wav$")

user_input_csv =  user_input_csv .. ","
string_patterns = {}
array_index = 1

for i in user_input_csv:gmatch("(.-),") do
   string_patterns[array_index] = i
   array_index = array_index + 1
end

function Main()
	reaper.Undo_BeginBlock()
    for i = 0, num_regions - 1 do
        exists, is_region, region_pos, region_end, region_name, region_index = reaper.EnumProjectMarkers(i)
       	-- note: EnumProjectMarkers always loops from 0, not from user-editable region ID
       	if is_region == true then
       		for _, pattern in ipairs(string_patterns) do
       			-- replace string pattern with an empty string
				region_name = region_name:gsub(pattern, "", 1) -- ':' passes receiver as first argument
			end
			reaper.SetProjectMarker(region_index, is_region, region_pos, region_end, region_name)
		end
	end
	reaper.Undo_EndBlock("Remove string pattern from existing region names", -1)
end

if retval == true then
	Main()
end
