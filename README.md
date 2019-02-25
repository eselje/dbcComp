# dbcComp
Compare the schemas of all the tables in two DBCs or two folders

Usage (from VFP Command Line):

SET PROCEDURE TO dbcComp
oComp=CREATEOBJECT("DBCComp", "Folder1 | DBC1", "Folder2 | DBC2")
oComp.COMPARE()

User configurable options:

Which serializer?

oSerializer = NEWOBJECT("c_FoxBin2Prg", "C:\DEV\FOX\FOXBIN2PRG\FOXBIN2PRG.PRG")
cSerializer = [This.oSerializer.Execute("%cTable", "D", '', .F., '1', '0', '1')]

Which diff tool?
cDiffTool = [C:\PROGRAM FILES\BEYOND COMPARE 4\BCOMP.EXE]
