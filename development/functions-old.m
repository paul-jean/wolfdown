(* ::Package:: *)

(* ::Input::Initialization:: *)
imageName[cellIndex_Integer,nbBasename_String]:=nbBasename<>"_"<>IntegerString@cellIndex<>".gif"


(* ::Input::Initialization:: *)
exportCell[cell:Cell[_,"Input"|"Output",__],cellIndex_Integer,pageWidth_Integer,nbBasename_String,jekyllDir_String,imageDir_String,mdFileHandle_OutputStream]:=Module[{imageFilename,relativeImageDir,imageFilenameWithPath,mdImageStr},
imageFilename=imageName[cellIndex,nbBasename];
relativeImageDir=FileNameJoin[{"..","..","..",imageDir,imageFilename}];
imageFilenameWithPath=FileNameJoin[{jekyllDir,imageDir,imageFilename}];
Export[imageFilenameWithPath,Append[cell,PageWidth->pageWidth]];
mdImageStr="!["<>imageFilename<>"]("<>relativeImageDir<>")";
WriteString[mdFileHandle,"\n"];
WriteString[mdFileHandle,"\n"];
WriteString[mdFileHandle,mdImageStr];
]


(* ::Input::Initialization:: *)
exportCell[cell:Cell[text_String,"Text",__],cellIndex_Integer,pageWidth_Integer,nbBasename_String,jekyllDir_String,imageDir_String,mdFileHandle_OutputStream]:=WriteString[mdFileHandle,"\n\n"<>text]


(* ::Input::Initialization:: *)
exportCell[cell:Cell[text_String,"Section",__],cellIndex_Integer,pageWidth_Integer,nbBasename_String,jekyllDir_String,imageDir_String,mdFileHandle_OutputStream]:=WriteString[mdFileHandle,"\n\n"<>"# "<>text]


(* ::Input::Initialization:: *)
exportCell[cell:Cell[text_String,"Subsection",__],cellIndex_Integer,pageWidth_Integer,nbBasename_String,jekyllDir_String,imageDir_String,mdFileHandle_OutputStream]:=WriteString[mdFileHandle,"\n\n"<>"## "<>text]


(* ::Input::Initialization:: *)
exportCell[cell:Cell[text_String,"Subsubsection",__],cellIndex_Integer,pageWidth_Integer,nbBasename_String,jekyllDir_String,imageDir_String,mdFileHandle_OutputStream]:=WriteString[mdFileHandle,"\n\n"<>"### "<>text]


(* ::Input::Initialization:: *)
exportNotebook[nbFile_String,jekyllDir_String,screenWidth_Integer,postTitle_String]:=Module[
{nbBasename,relativeImageDir,mdFileDir,mdFileTmp,nbObject,nbExpr,cells,numCells,fd,outputCellImageFiles,imageDimensions,numPixels,maxNumPixels,coverImageFile,coverImageRelativePath,mdFile,fdTmp,line},
nbBasename=FileBaseName@nbFile;
relativeImageDir=FileNameJoin[{"assets",DateString[{"Year"}],DateString[{"Month"}],DateString[{"Day"}],nbBasename<>"-"<>IntegerString@screenWidth<>"px"}];
mdFileDir=FileNameJoin[{jekyllDir,"_posts"}];
mdFileTmp=FileNameJoin[{mdFileDir,DateString[{"Year","-","Month","-","Day","-",nbBasename}]<>".md.tmp"}];
If[!FileExistsQ[mdFileDir],
CreateDirectory@mdFileDir
];
If[!FileExistsQ[FileNameJoin[{jekyllDir,relativeImageDir}]],
CreateDirectory[FileNameJoin[{jekyllDir,relativeImageDir}]]
];
nbObject=NotebookOpen[nbFile,Visible->False];
nbExpr=NotebookGet[nbObject];
cells=Cases[nbExpr,Cell[_,"Input"|"Output"|"Text"|"Section"|"Subsection"|"Subsubsection",__],Infinity];
numCells=Length@cells;
Put@mdFileTmp;
fd=OpenAppend[mdFileTmp,PageWidth->Infinity];
(* export each cell to the .md file and the image files: *)
MapIndexed[
exportCell[#,#2[[1]],screenWidth,nbBasename,jekyllDir,relativeImageDir,fd]&,
cells
];
Close[fd];
(* find the best cover image: *)
outputCellImageFiles=FileNameJoin[{jekyllDir,relativeImageDir,imageName[#,nbBasename]}]&/@Flatten@Position[cells,Cell[_,"Output",__]];
imageDimensions={#,ImageDimensions@Import@#}&/@outputCellImageFiles;
numPixels=Times@@#[[2]]&/@imageDimensions;
maxNumPixels=Max@numPixels;
coverImageFile=Extract[outputCellImageFiles,Position[numPixels,maxNumPixels]][[1]];
(* write final md file with yaml front matter: *)
coverImageRelativePath=FileNameJoin[{relativeImageDir,FileNameTake[coverImageFile,-1]}];
mdFile=FileNameJoin[{mdFileDir,DateString[{"Year","-","Month","-","Day","-",nbBasename}]<>".md"}];
Put@mdFile;
fd=OpenAppend[mdFile,PageWidth->Infinity];
WriteString[fd,"---\n"];
WriteString[fd,"layout: post\n"];
WriteString[fd,"title: \""<>postTitle<>"\"\n"];
WriteString[fd,"gif: "<>coverImageRelativePath<>"\n"];
WriteString[fd,"date: "<>DateString[{"Year","-","Month","-","Day"}]<>"\n"];
WriteString[fd,"---\n\n"];
fdTmp=OpenRead[mdFileTmp];
SetStreamPosition[fdTmp,0];
While[(line=ReadLine[fdTmp])=!=EndOfFile,
WriteString[fd,line<>"\n\n"];
];
Close[fdTmp];
Close[fd];
DeleteFile[mdFileTmp];
mdFile
]
