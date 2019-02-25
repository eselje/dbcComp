DEFINE CLASS dbcComp AS Session OLEPUBLIC

cOutputFolder = CURDIR()
cCompareLeft = ""
cCompareRight = ""
cCompareObjects = .null.  && Folders or DBC
cDiffTool = [C:\PROGRAM FILES\BEYOND COMPARE 4\BCOMP.EXE]
* cSerializer = [DO C:\DEV\FOX\FOXBIN2PRG\FOXBIN2PRG.PRG WITH "%cTable", "D", '', .F., '1', '0', '1']
cSerializer = [This.oSerializer.Execute("%cTable", "D", '', .F., '1', '0', '1')]
oSerializer = .null.
cMessage = ""
cOutputLeft=  ""
cOutputRight=  ""
cResultsFile = ADDBS(This.cOutputFolder)+"CompareResults.txt"

PROCEDURE Init
LPARAMETERS cCompareLeft, cCompareRight, oSerializer
* Can be a folder or DBC Name
This.cCompareLeft = cCompareLeft
This.cCompareRight = cCompareRight
This.oSerializer = NEWOBJECT("c_FoxBin2Prg", "C:\DEV\FOX\FOXBIN2PRG\FOXBIN2PRG.PRG")
ENDPROC

PROCEDURE cCompareLeft_Assign
LPARAMETERS cValue
This.cCompareLeft = cValue
This.setCompare()

PROCEDURE cCompareRight_Assign
LPARAMETERS cValue
This.cCompareRight = cValue
This.setCompare()

PROCEDURE cOutputFolder_Assign
LPARAMETERS cFolder
IF DIRECTORY(cFolder)
	This.OutputFolder = cFolder
ELSE
	This.cMessage = cFolder + " is not a folder name."
ENDIF


PROCEDURE setCompare
This.cCompareObjects = ICASE(DIRECTORY(This.cCompareLeft) and DIRECTORY(This.cCompareRight),'Folders',FILE(This.cCompareLeft) and FILE(This.cCompareRight),'DBC',.null.)


PROCEDURE Compare
LOCAL lReturn
This.cOutputLeft = ADDBS(SYS(2023))+JUSTFNAME(This.cCompareLeft)+"_Left_"+TTOC(DATETIME(),1)+".txt"
This.cOutputRight = ADDBS(SYS(2023))+JUSTFNAME(This.cCompareRight)+"_Right"+TTOC(DATETIME(),1)+".txt"
DO CASE
	CASE This.cCompareObjects = "Folders"
		lReturn = This.SerializeFolder(This.cCompareLeft, This.cOutputLeft)
		lReturn = lReturn AND This.SerializeFolder(This.cCompareRight, This.cOutputRight)
	CASE This.cCompareObjects = "DBC"
		lReturn = This.SerializeDBC(This.cCompareLeft, This.cOutputLeft)
		lReturn = lReturn AND This.SerializeDBC(This.cCompareRight, This.cOutputRight)
	OTHERWISE
		This.cMessage = "Cannot compare until left and right values are set with either folder names or DBC names"		
ENDCASE
IF lReturn
	lReturn = This.CompareResults()
	IF NOT lReturn
		This.cMessage = "Could not create comparison file " + This.cResultsFile
	ENDIF 
ENDIF
RETURN lReturn



FUNCTION CompareResults
LOCAL cDiffTool
cDiffTool = This.cDiffTool + " " + oComp.cOutputLeft + " " + oComp.cOutputRight && + " >> " + This.cResultsFile
RUN /N &cDiffTool

RETURN FILE(This.cResultsFile)


PROTECTED FUNCTION SerializeFolder
LPARAMETERS cFolderName, cOutputFile
LOCAL ARRAY aTables[1,4]
LOCAL nTables, iRow, cCurrentFolder
cCurrentFolder = CURDIR()
CD (cFolderName)
ERASE (cOutputFile)
nTables = ADIR(aTables, ADDBS(cFolderName)+"*.dbf")
FOR iRow = 1 TO nTables
	This.SerializeFile(aTables[iRow,1], cOutputFile)
NEXT
nTables = ADIR(aTables, ADDBS(cFolderName)+"*.dbc")
FOR iRow = 1 TO nTables
	This.SerializeFile(aTables[iRow,1], cOutputFile)
NEXT
CD (cCurrentFolder)
RETURN FILE(cOutputFile)  


PROTECTED FUNCTION SerializeFile
LPARAMETERS cFileName, cOutputFile
LOCAL cSerializer, cResultFile, lReturn
cResultFile = FORCEEXT(cFileName,'db2')
ERASE (cResultFile)
cSerializer = STRTRAN(This.cSerializer, "%cTable", cFileName)
&cSerializer
lReturn = FILE(cResultFile)
IF lReturn
	STRTOFILE(FILETOSTR(cResultFile), cOutputFile, 1)
ENDIF 
ERASE (cResultFile)
RETURN lReturn

FUNCTION ShowOutput
LPARAMETERS lRight
IF lRight
	MODIFY FILE (This.cOutputRight) 
ELSE
	MODIFY FILE (This.cOutputLeft) 
ENDIF 


PROTECTED FUNCTION SerializeDBC
LPARAMETERS cDBCName, cOutputFile
ERASE (cOutputFile)
This.SerializeFile(cDBCName, cOutputFile)
cCurrentFolder = CURDIR()
CD (JUSTPATH(cDBCName))
USE (cDBCName) IN 0 ALIAS dbcName
SET DELETED ON
SELECT ObjectName FROM dbcName WHERE objectType='Table' ORDER BY ObjectName INTO CURSOR crsTables
SCAN
	This.SerializeFile(ObjectName, cOutputFile)
ENDSCAN
USE IN SELECT(crsTables)
CD (cCurrentFolder)
ENDFUNC


PROCEDURE Error(nError, cMethod, nLine)
? "Error " + TRANSFORM(nError) + " in " + cMethod + ", Line " + TRANSFORM(nLine)
ENDPROC

ENDDEFINE
