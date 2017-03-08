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
{nbBasename,relativeImageDir,mdFileDir,mdFileTmp,nbObject,nbExpr,cells,numCells,fd,outputCellImageFiles,imageDimensions,numPixels,maxNumPixels,coverImageFile,coverImageRelativePath,mdFile,fdTmp,line,stderr},
stderr=Streams["stderr"];
WriteString[stderr,"\n\n"];
WriteString[stderr,"[exportNotebook] Exporting file "<>nbFile<>" to jekyll directory "<>jekyllDir<>"\n"];
WriteString[stderr,"[exportNotebook] Screen width: "<>IntegerString@screenWidth<>"\n"];
WriteString[stderr,"[exportNotebook] Post title: "<>postTitle<>"\n"];
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
WriteString[stderr,"[exportNotebook] Found "<>IntegerString@numCells<>" cells to export\n"];
Put@mdFileTmp;
fd=OpenAppend[mdFileTmp,PageWidth->Infinity];
(* export each cell to the .md file and the image files: *)
MapIndexed[
With[{i=#2[[1]]},
exportCell[#,i,screenWidth,nbBasename,jekyllDir,relativeImageDir,fd];
If[Mod[i,10]==0,
WriteString[stderr,"[exportNotebook] Cell number "<>IntegerString@i<>"\n"];
];
]&,
cells
];
Close[fd];
mdFile=FileNameJoin[{mdFileDir,DateString[{"Year","-","Month","-","Day","-",nbBasename}]<>".md"}];
Put@mdFile;
fd=OpenAppend[mdFile,PageWidth->Infinity];
WriteString[fd,"---\n"];
WriteString[fd,"layout: post\n"];
WriteString[fd,"title: \""<>postTitle<>"\"\n"];
outputCellImageFiles=FileNameJoin[{jekyllDir,relativeImageDir,imageName[#,nbBasename]}]&/@Flatten@Position[cells,Cell[_,"Output",__]];
(* find the best output cell to use as a cover image ... *)
If[Length@outputCellImageFiles>0,
imageDimensions={#,ImageDimensions@Import@#}&/@outputCellImageFiles;
(* find the most square image with at least 100px on a side: *)
coverImageFile=Take[SortBy[Select[imageDimensions,#[[2,1]]>=100||#[[2,2]]>=100&],Abs@Differences@#[[2]]&],UpTo[1]];
If[MatchQ[coverImageFile,{{_String,{_Integer,_Integer}}}],
coverImageFile=coverImageFile[[1,1]];
WriteString[stderr,"[exportNotebook] Using cover image file "<>coverImageFile<>"\n"];
(* write final md file with yaml front matter: *)
coverImageRelativePath=FileNameJoin[{relativeImageDir,FileNameTake[coverImageFile,-1]}];
WriteString[fd,"gif: "<>coverImageRelativePath<>"\n"];
];
];
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
WriteString[stderr,"[exportNotebook] Finished writing markdown file: "<>mdFile<>"\n"];
WriteString[stderr,"[exportNotebook] Done.\n"];
mdFile
]


(* ::Input:: *)
(*Differences[{1,2}]*)


(* ::Input:: *)
(*SortBy*)
