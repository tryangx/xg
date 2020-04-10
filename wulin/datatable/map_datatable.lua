--------------------------------------------------
--------------------------------------------------
local MAP_DATATABLE =
{
	[1] =
	{
		name   = "testmap",
		width  = 20,
		height = 20,
		plotTypes = 
	    {
	       { type="LAND",  terrain="PLAINS",    feature="",      prob=1000 },
	       { type="LAND",  terrain="GRASSLAND", feature="",      prob=1000 },
	       { type="LAND",  terrain="GRASSLAND", feature="MARSH", prob=1000 },
	       --{ type="HILLS", terrain="PLAINS",    feature="WOODS", prob=1000 },
	    },
	    cities = 
	    {
			{ id=1, name="北京", x=8,  y=2,  lv=1, adjacents = { 2,3,4 } },
			{ id=2, name="南京", x=11, y=17, lv=1, adjacents = { 1,3,4 } },
			{ id=3, name="东京", x=18, y=9,  lv=1, adjacents = { 1,2,4 } },
			{ id=4, name="西京", x=2,  y=11, lv=1, adjacents = { 1,2,3 } },
		},
	}
}

--------------------------------------------------
--------------------------------------------------
function MAP_DATATABLE_Get( id )
	return MAP_DATATABLE[id]
end


--------------------------------------------------
--------------------------------------------------
function MAP_DATATABLE_Foreach( fn )
end