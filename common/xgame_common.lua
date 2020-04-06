---------------------------------------
package.path = package.path .. ";common/ecs/?.lua"
package.path = package.path .. ";common/map/?.lua"

---------------------------------------
require "ecs"
require "map"
---------------------------------------
require "filereflection"

--use to import data from file( load )
ImportFileReflection = FileReflection( FileReflectionMode.IMPORT )

--use to export data into file( save )
ExportFileReflection = FileReflection( FileReflectionMode.EXPORT )

--use to dump the data( debug )
DumpReflection       = FileReflection( FileReflectionMode.EXPORT_PRINT )

---------------------------------------