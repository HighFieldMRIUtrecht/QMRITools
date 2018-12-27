(* ::Package:: *)

(* ::Title:: *)
(*QMRITools GeneralTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["QMRITools`GeneralTools`", {"Developer`"}];

$ContextPath=Union[$ContextPath,System`$QMRIToolsContextPaths];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection::Closed:: *)
(*Functions*)


FileSelect::usage = 
"FileSelect[action] creates a systemdialog wicht returs file/foldername action can be \"FileOpen\", \"FileSave\" or \"Directory\".
FileSelect[action, {type}] same but allows the definition of filetypes for \"FileOpen\" and \"FileSave\" e.g. \"jpg\" or \"pdf\"."

TransData::usage = 
"TransData[data,dir] Rotates the dimesions of the data to left or rigthg. For example {z,x,y} to {x,y,z} dir is \"l\" or \"r\"."

SaveImage::usage = 
"SaveImage[image] exports graph to image, ImageSize, FileType and ImageResolution can be given as options.
SaveImage[image, \"filename\"] exports graph to image with \"filname\", ImageSize, FileType and ImageResolution can be given as options."


PadToDimensions::usage = 
"PadToDimensions[data, dim] pads the data to dimensions dim." 

RescaleData::usage = 
"RescaleData[data,dim] rescales image/data to given dimensions.
RescaleData[data,{vox1, vox2}] rescales image/data from size vox1 to size vox2."

GridData::usage = 
"GridData[{data1,data2,...}, part] makes a grid of multiple datasets with part sets on each row"

Data2DToVector::usage = 
"Data2DToVector[data] converst the data to vector.
Data2DToVector[data,mask] converst the data within the mask to vector.

the data can be reconstructed using VectorToData.

output is the vecotrized data and a list contining the original data dimensions and a list with the data coordinates. {vec, {dim,pos}}."

Data3DToVector::usage = 
"Data3DToVector[data] converst the data to vector..
Data3DToVector[data,mask] converst the data within the mask to vector.

the data can be reconstructed using VectorToData.

output is the vecotrized data and a list contining the original data dimensions and a list with the data coordinates. {vec, {dim,pos}}."

VectorToData::usage = 
"VectorToData[vec, {dim,pos}] converts the vectroized data, using Data2DToVector or Data3DToVector, back to its original Dimensoins"

TensMat::usage=
"TensMat[tensor] transforms tensor form vector format {xx,yy,zz,xy,xz,yz} to matrix format {{xx,xy,xz},{xy,yy,yz},{xz,yz,zz}}."

TensVec::usage=
"TensVec[tensor] transforms tensor form matrix format {{xx,xy,xz},{xy,yy,yz},{xz,yz,zz}} to vector format {xx,yy,zz,xy,xz,yz}."


CropData::usage =
"CropData[data] creates a dialog window to crop the data (assumes voxsize (1,1,1)).
CropData[data,vox] creates a dialog window to crop the data."

FindCrop::usage = 
"FindCrop[data] finds the crop values of the data by removing all zeros surrounding the data."

AutoCropData::usage = 
"AutoCropData[data] crops the data by removing all background zeros.
AutoCropData[data,pad] crops the data by removing all background zeros with padding of pad."

ReverseCrop::usage = 
"ReverseCrop[data,dim,crop] reverses the crop on the cropped data with crop values crop to the original size dim.
ReverseCrop[data,dim,crop,{voxorig,voxnew}] reverses the crop on the cropped data with crop values crop to the original size dim."

ApplyCrop::usage =
"ApplyCrop[data,crop] aplies the corpped region obtained form CropData to the data.
ApplyCrop[data,crop,{voxorig,voxnew}] aplies the corpped region obtained form CropData to the data." 


CutData::usage = 
"CutData[data] splits the data in two equal sets left and right."

StichData::usage =
"StichData[datal,datar] joins left and right part of the data generated by CutData."


QMRIToolsPackages::usage =
"QMRIToolsPackages[] give list of all the QMRITools pacakges."

QMRIToolsFunctions::usage = 
"QMRIToolsFunctions[] give list of all the QMRITools packages, functions and options.
QMRIToolsFunctions[p] print a table with length p of all the QMRITools functions and options.
QMRIToolsFunctions[\"toobox\"] gives a list of all the functions and options in toolbox.
QMRIToolsFunctions[\"toobox\", p] gives a table op length p of all the functions and options in toolbox. If toolbox is \"All\" it will list all toolboxes."

QMRIToolsFuncPrint::usage = 
"QMRIToolsFuncPrint[] gives a list of all the QMRITools functions with their usage infomation."

CompilebleFunctions::usage = 
"CompilebleFunctions[] generates a list of all compilable functions."


DevideNoZero::usage = 
"DevideNoZero[a, b] devides a/b but when b=0 the result is 0. a can be a number or vector."

MeanNoZero::usage = 
"MeanNoZero[data] calculates the mean of the data ignoring the zeros."

MedianNoZero::usage = 
"MedianNoZero[data] calculates the Median of the data ignoring the zeros."

LogNoZero::usage = 
"LogNoZero[val] return the log of the val which can be anny dimonsion array. if val=0 the output is 0."

ExpNoZero::usage = 
"ExpNoZero[val] return the Exp of the val which can be anny dimonsion array. if val=0 the output is 0."

RMSNoZero::usage = 
"RMSNoZero[vec] return the RMS error of the vec which can be anny dimonsion array. if vec={0...} the output is 0. Zeros are ignored"

MADNoZero::usage = 
"MADNoZero[vec] return the MAD error of the vec which can be anny dimonsion array. if vec={0...} the output is 0. Zeros are ignored"


MemoryUsage::usage = 
"MemoryUsage[] gives a table of which definitions use up memory.
MemoryUsage[n] gives a table of which definitions use up memory, where n is the amout of definitions to show."

ClearTemporaryVariables::usage = 
"ClearTemporaryVariables[] Clear temporary variables."


SumOfSquares::usage = 
"SumOfSquares[{data1, data2, .... datan}] calculates the sum of squares of the datasets.
Output is the SoS and the weights, or just the SoS."

NNLeastSquares::usage = 
"NNLeastSquares[A, y] performs a Non Negative Linear Least Squares fit.
finds an x that solves the linear least-squares problem for the matrix equation A.x==y.

output is the solution x."

LapFilter::usage = 
"LapFilter[data] Laplacian filter of data with kernel size 0.8.
LapFilter[data, ker] Laplacian filter of data with kernel ker."

StdFilter::usage =
"StdFilter[data] StandardDeviation filter of data using gaussian kernel 2. 
StdFilter[data, ker] StandardDeviation filter of data using kernel with size ker."


(* ::Subsection::Closed:: *)
(*General Options*)


PadValue::usage = 
"PadValue is an option for PadToDimensions. It specifies the value of the padding."

PadDirection::usage = 
"PadDirection is an option for PadToDimensions. It specifies the direction of padding, \"Center\", \"Left\" or \"Right\"."


CropOutput::usage = 
"CropOutput is an option for CropData, can be \"All\",\"Data\" or \"Crop\"."

CropInit::usage = 
"CropInit is an option for CropData. By default the crop is not initialized bu can be with {{xmin,xmax},{ymin,ymax},{zmin,zmax}}. "

CropPadding::usage = 
"CropPadding is an option for AutoCropData or FindCrop. It specifies how much padding to use around the data."


OutputWeights::usage = 
"OutputWeights is an option for SumOfSqares. If True it also output the SoS weights."


(* ::Subsection::Closed:: *)
(*Error Messages*)


RescaleData::dim = "Given dimensions `1` not the same depth as that of the given data `2`."

RescaleData::data = "Error: Inpunt must be 2D with {xdim,ydim} input or 3D dataset with {xdim,ydim} or {zdim, xdim, ydim} input."


Data2DToVector::dim = "Data should be 2D or 3D, data is `1`D."

Data2DToVector::mask = "Data and mask should have the same dimensions: data `1` and mask `2`"

Data3DToVector::dim = "Data should be 3D or 4D, data is `1`D."

Data3DToVector::mask = "Data and mask should have the same dimensions: data `1` and mask `2`"


ApplyCrop::dim = "Crop region lies outside data range."


(* ::Section:: *)
(*Functions*)


Begin["`Private`"]


(* ::Subsection:: *)
(*General Functions*)


(* ::Subsubsection::Closed:: *)
(*File Select*)


Options[FileSelect]={WindowTitle -> Automatic};

SyntaxInformation[FileSelect] = {"ArgumentsPattern" -> {_, _.,_., OptionsPattern[]}};

FileSelect[action_, opts:OptionsPattern[]] := FileSelect[action, {""}, "*" ,opts]

FileSelect[action_, type:{_String ..}, opts:OptionsPattern[]] := FileSelect[action, type, "*", opts]

FileSelect[action_String, type : {_String ..}, name_String, opts:OptionsPattern[]] := Module[{input},
  If[!Element[action, {"FileOpen", "FileSave", "Directory"}], Return[]];
  input = If[(action == "FileOpen" || action == "FileSave"),
  	  	SystemDialogInput[action, {Directory[], {name ->type}},opts],
  	  	SystemDialogInput["Directory", Directory[],opts]
    ];
  If[input === $Canceled, 
  	Print["Canceled!"], 
  	If[action == "Directory",
  		StringDrop[input,-1],
  		input
  		]
  	]
]


(* ::Subsubsection::Closed:: *)
(*TransData*)


SyntaxInformation[TransData] = {"ArgumentsPattern" -> {_, _}};

TransData[data_,dir_]:=Block[{ran,dep,fun},
	ran=Range[dep=ArrayDepth[data]];
	fun=Switch[dir,"r",RotateLeft[ran],"l",RotateRight[ran]];
	Transpose[data,fun]
]


(* ::Subsubsection::Closed:: *)
(*SaveImage*)


Options[SaveImage] = {ImageSize -> 6000, FileType -> ".jpg", ImageResolution -> 300};

SyntaxInformation[SaveImage] = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

SaveImage[exp_, opts : OptionsPattern[]] := Module[{input, type},
 	type = OptionValue[FileType];
 	type = If[StringTake[type, 2] === "*.", StringDrop[type,1], If[StringTake[type, 1] === ".",type, "."<>type]];
 	
 	input = FileSelect["FileSave", {"*"<>type}];
 	
 	If[input != "Canceled!",
 		input=If[StringTake[input,-4]===type,input,input<>type];
 		SaveImage[exp, input, opts]
  	];
  ]

SaveImage[exp_, filei_String, OptionsPattern[]] := Module[{file,imsize,res,type},
	type = OptionValue[FileType];
 	type = If[StringTake[type, 2] === "*.", StringDrop[type,1], If[StringTake[type, 1] === ".",type, "."<>type]];
	
	file=If[StringTake[filei,-4]===type||StringTake[filei,-5]===type,filei,filei<>type];
	
	imsize=OptionValue[ImageSize];
	res=OptionValue[ImageResolution];
	
	If[OptionValue[FileType]===".tiff"||OptionValue[FileType]===".tif",
  	  Export[file, exp(*Rasterize[exp, ImageResolution -> 2*res],RasterSize -> imsize,*) , ImageSize->imsize, ImageResolution -> res,"ImageEncoding"->"LZW"],
  	  Export[file, exp(*Rasterize[exp, ImageResolution -> 2*res],RasterSize -> imsize,*) , ImageSize->imsize, ImageResolution -> res]
	];
	
	Print["File was saved to: " <> file];
  ]


(* ::Subsection:: *)
(*Reshaping and Resizing*)


(* ::Subsubsection::Closed:: *)
(*PadToDimensions*)


Options[PadToDimensions]={PadValue->0., PadDirection -> "Center"}

SyntaxInformation[PadToDimensions] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

PadToDimensions[data_, dim_, OptionsPattern[]] := Block[{diffDim, padval, pad,dir,zer},
  padval = OptionValue[PadValue];
  diffDim = dim - Dimensions[data];
  
  dir = OptionValue[PadDirection];
  dir = If[StringQ[dir], ConstantArray[dir, Length[dim]], dir];
  zer = ConstantArray[0, Length[dim]];
  
  pad = MapThread[
  Switch[#1, "Left", #2, "Right", #3, _, #4] &, {dir, 
   Transpose@{zer, diffDim}, Transpose@{diffDim, zer}, 
   Transpose@{Floor[diffDim/2], Ceiling[diffDim/2]}}];
  
  ArrayPad[data,pad,padval]
	 
  ]


(* ::Subsubsection::Closed:: *)
(*RescaleData*)


Options[RescaleData] = {InterpolationOrder -> 3};

SyntaxInformation[RescaleData] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

RescaleData[data_?ArrayQ, {v1_?VectorQ, v2_?VectorQ}, opts : OptionsPattern[]] := RescaleDatai[data, v1/v2, "v", opts]

RescaleData[data_?ArrayQ, dim_?VectorQ, opts : OptionsPattern[]] := RescaleDatai[data, dim, "d", opts]

Options[RescaleDatai] = {InterpolationOrder -> 3};

RescaleDatai[data_?ArrayQ, sc_?VectorQ, met_, opts : OptionsPattern[]] := Block[{type, dim, int, dataOut},
  dim = Dimensions[data];
  int = OptionValue[InterpolationOrder];
  
  dataOut = Switch[ArrayDepth[data],
   (*rescale an image*)
   2,
   If[Length[sc] != 2,
    Return[Message[RescaleData::dim, sc, Dimensions[data]]];,
    RescaleImgi[data, {sc, met}, int]
    ],
   3(*rescale a 3D dataset*),
   Switch[Length[sc],
    2(*rescale a stac of 2D images*),
    RescaleImgi[#, {sc, met}, int] & /@ data
    ,
    3(*rescale 3D data*),
    RescaleImgi[data, {sc, met}, int],
    _,
    Return[Message[RescaleData::dim, sc, Dimensions[data]]];
    ],
   4(*rescale a 4D dataset, treat data as multiple 3D sets*),
   Transpose[RescaleDatai[#, sc, met, opts] & /@ Transpose[data]],
   _,
   Return[Message[RescaleData::data]];
   ];
   
   Chop[Clip[dataOut,MinMax[data]]]
  ]


RescaleImgi[dat_, {sc_, met_}, n_] := Block[{type, im, dim},
  (*data type*)
  type = If[ArrayQ[dat, _, IntegerQ], "Bit16", "Real32"];
  dim = If[met == "v", Round[sc Dimensions[dat]], sc];
  (*convert to 2D or 3D image*)
  im = Switch[ArrayDepth[dat], 2, Image[dat, type], 3, Image3D[dat, type]];
  ImageData[ImageResize[im, Reverse[dim], Resampling ->{"Spline", n},Padding->0], type]
  ]


(* ::Subsubsection::Closed:: *)
(*GridData*)


SyntaxInformation[GridData] = {"ArgumentsPattern" -> {_, _}};

GridData[data_, part_] := Block[{dim, temp, adepth},
	adepth = ArrayDepth[data[[1]]];
	dim = Dimensions[data];
	dim[[1]] = dim[[1]] + (part - (Mod[Length[data], part] /. 0 -> part));
	temp = Transpose[Partition[PadRight[data, dim], part]];
	temp = MapThread[Join, #, adepth - 2] & /@ temp;
	temp = MapThread[Join, temp, adepth - 1]
  ]


(* ::Subsubsection::Closed:: *)
(*Data2DToVector*)


SyntaxInformation[Data2DToVector] = {"ArgumentsPattern" -> {_, _.}};

Data2DToVector[datai_]:=Data2DToVector[datai,1]
Data2DToVector[datai_, maski_]:=Block[{data,depth,mask,pos,vecdata,dimd,dimm},

depth = ArrayDepth[datai];
If[!(depth==2||depth==3), Return@Message[Data2DToVector::dim,depth]];

dimd = If[depth==2,Dimensions[datai],Drop[Dimensions[datai],1]];
dimm = Dimensions[maski];
If[!(mask===1) && dimm!=dimd, Return@Message[Data2DToVector::mask,dimd,dimm]];

data = N@If[depth==3, maski #&/@datai, maski datai];

mask = Unitize@If[depth==3, Total[data], data];
pos = Position[mask,1];

vecdata = If[depth==3,
	DeleteCases[Flatten[TransData[data,"l"], 1], ConstantArray[0., Length[datai]]],
	DeleteCases[Flatten[data], 0.]
];

{vecdata, {dimd,pos}}
];


(* ::Subsubsection::Closed:: *)
(*Data3DToVector*)


SyntaxInformation[Data3DToVector] = {"ArgumentsPattern" -> {_, _.}};

Data3DToVector[datai_]:=Data3DToVector[datai,1]
Data3DToVector[datai_, maski_]:=Module[{data,depth,mask,pos,vecdata,dimd,dimm},

depth=ArrayDepth[datai];
If[!(depth==3||depth==4), Message[Data3DToVector::dim,depth]];

dimd = If[depth==3, Dimensions[datai], Drop[Dimensions[datai],1]];
dimm = Dimensions[maski];
If[!(mask===1) && dimm!=dimd, Return@Message[Data3DToVector::mask,dimd,dimm]];

data = N@If[depth==4,maski #&/@datai,maski datai];

mask = Unitize@If[depth==4,Total[data],data];
pos = Position[mask,1];

vecdata = If[depth==4,
	DeleteCases[Flatten[TransData[data,"l"], 2], ConstantArray[0., Length[datai]]],
	DeleteCases[Flatten[data], 0.]
];

{vecdata, {dimd,pos}}
];


(* ::Subsubsection::Closed:: *)
(*VectorToData*)


SyntaxInformation[VectorToData] = {"ArgumentsPattern" -> {_, {_, _}}};

VectorToData[vec_,{dim_, pos_}]:=Block[{output,len},
len=Length@First@vec;
output=Switch[len,
0,ConstantArray[0.,dim],
_,ConstantArray[ConstantArray[0.,len],dim]
];
Switch[
Length[dim],
2,MapThread[(output[[#2[[1]],#2[[2]]]]=#1)&,{vec,pos}],
3,MapThread[(output[[#2[[1]],#2[[2]],#2[[3]]]]=#1)&,{vec,pos}]
];
Switch[len,0,output,_,TransData[output,"r"]]
]


(* ::Subsubsection::Closed:: *)
(*TensMat*)


SyntaxInformation[TensMat] = {"ArgumentsPattern" -> {_}};

TensMat[tens:{_?ArrayQ..}]:=
Transpose[{{tens[[1]],tens[[4]],tens[[5]]},{tens[[4]],tens[[2]],tens[[6]]},{tens[[5]],tens[[6]],tens[[3]]}},{4,5,1,2,3}];

TensMat[tens_?ListQ]:=
	{{tens[[1]],tens[[4]],tens[[5]]},{tens[[4]],tens[[2]],tens[[6]]},{tens[[5]],tens[[6]],tens[[3]]}};


(* ::Subsubsection::Closed:: *)
(*TensVec*)


SyntaxInformation[TensVec] = {"ArgumentsPattern" -> {_}};

TensVec[tens:{{_,_,_},{_,_,_},{_,_,_}}]:=
	{tens[[1,1]],tens[[2,2]],tens[[3,3]],tens[[1,2]],tens[[1,3]],tens[[2,3]]};

TensVec[tens:{_?ArrayQ..}]:=
Transpose[Map[{#[[1,1]],#[[2,2]],#[[3,3]],#[[1,2]],#[[1,3]],#[[2,3]]}&,tens,{3}],{2,3,4,1}];


(* ::Subsection:: *)
(*Cropping*)


(* ::Subsubsection::Closed:: *)
(*CropData*)


Options[CropData] = {CropOutput -> "All", CropInit -> Automatic};

SyntaxInformation[CropData] = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

CropData[data_, opts:OptionsPattern[]] := CropData[data, {1,1,1}, opts]

CropData[data_, vox:{_?NumberQ, _?NumberQ, _?NumberQ}, OptionsPattern[]] := Block[
	{a, b, c, d, e, f, clipall, dd, dataout, output, init},
	
	NotebookClose[cropwindow];
	dd = ArrayDepth[data];

	DynamicModule[{dat, zd, xd, yd, outp, size,  r1, r2, r3},
		
		dat = Switch[dd, 4,  Mean@Transpose@data, 3, dat = data, _, Return[]];
		{zd, xd, yd} = Dimensions[dat];
		
		clipall = Ceiling[{0.5, zd - 0.5, 0.5, xd - .5, 0.5, yd - .5}];
    
	    r1 = (vox[[2]]*xd)/(vox[[3]]*yd);
	    r2 = (vox[[1]]*zd)/(vox[[3]]*yd);
	    r3 = (vox[[1]]*zd)/(vox[[2]]*xd);
    
  		size = Min[{r1, r2, r3}] 400;
  		
  		init = OptionValue[CropInit];
  		init = If[ListQ[init] && Length[init]==6,
  			{0, 0, xd+1, xd+1, 0, 0} + {1, 1, -1, -1, 1, 1} init[[{1,2,4,3,5,6}]],
  			{1,zd,1,xd,1,yd}
  			];
     
    cropwindow = DialogInput[
      {
       DefaultButton[],

       Manipulate[
        outp = Ceiling[{zmin, zmax, xd - xmax, xd - xmin, ymin, ymax}];
        
        Grid[
         {
         	{Dynamic[Row[{"size: ", Ceiling[{zmax-zmin,xmax-xmin,ymax-ymin}]},"   "]]},
         	{
     		LocatorPane[Dynamic[{{ymin, xmax}, {ymax, xmin}}],
                Show[ArrayPlot[dat[[z]], ColorFunction -> "GrayTones", Frame -> False, AspectRatio -> r1, ImageSize -> size/r2],
            	Graphics[{
            		Red, Thick, Dynamic[Line[{{ymin, xmin}, {ymin, xmax}, {ymax, xmax}, {ymax, xmin}, {ymin, xmin}}]], 
            		Green, Line[{{y - 0.5, -10}, {y - 0.5, xd + 10}}], 
            		Blue, Line[{{-10, xd - x + 0.5}, {yd + 10, xd - x + 0.5}}], 
            		Red, Dynamic[Circle[Mean[{{ymin, xmin}, {ymax, xmax}}], 2]]
            		}], 
        		PlotRange -> {{0, yd}, {0, xd}}
            	], {{0.5, 0.5}, {yd - 0.5, xd - 0.5}}, Appearance -> Graphics[{Red, Disk[]}, ImageSize -> 10]
             ]
			}, {
			LocatorPane[Dynamic[{{ymin, zmax}, {ymax, zmin}}],
				Show[ArrayPlot[Reverse[dat[[All, x]]], ColorFunction -> "GrayTones", Frame -> False, AspectRatio -> r2, ImageSize -> size/r2], 
				Graphics[{
					Blue, Thick, Dynamic[Line[{{ymin, zmin}, {ymin, zmax}, {ymax, zmax}, {ymax, zmin}, {ymin, zmin}}]], 
					Green, Line[{{y - 0.5, -10}, {y - 0.5, zd + 10}}], 
					Red, Line[{{-10, z - 0.5}, {yd + 10, z - 0.5}}], 
					Blue,  Dynamic[Circle[Mean[{{ymin, zmin}, {ymax, zmax}}], 2]]
					}], 
				PlotRange -> {{0, yd}, {0, zd}}
				], {{0.5, 0.5}, {yd - 0.5, zd - 0.5}}, Appearance -> Graphics[{Blue, Disk[]}, ImageSize -> 10]]
			,
			LocatorPane[Dynamic[{{xmin, zmax}, {xmax, zmin}}],
				Show[ArrayPlot[Reverse /@ Reverse[dat[[All, All, y]]], ColorFunction -> "GrayTones", Frame -> False, AspectRatio -> r3, ImageSize -> size/r3], 
				Graphics[{
					Green, Thick, Dynamic[ Line[{{xmin, zmin}, {xmin, zmax}, {xmax, zmax}, {xmax, zmin}, {xmin, zmin}}]],
					Blue, Line[{{x - 0.5, -10}, {x - 0.5, zd + 10}}], 
					Red, Line[{{-10, z - 0.5}, {xd + 10, z - 0.5}}], 
					Green, Dynamic[Circle[Mean[{{xmin, zmin}, {xmax, zmax}}], 2]]
					}], 
				PlotRange -> {{0, xd}, {0, zd}}
				], {{0.5, 0.5}, {xd - 0.5, zd - 0.5}}, Appearance -> Graphics[{Green, Disk[]}, ImageSize -> 10]]
			}}, Spacings -> 0]
			
			,
        {{z, Round[zd/2], "slice"}, 1, zd, 1},
        {{x, Round[xd/2], "row"}, 1, xd, 1},
        {{y, Round[yd/2], "column"}, 1, yd, 1},
        {{xmin, init[[3]] - 0.5}, 1, xmax - 1, ControlType -> None},
        {{xmax, init[[4]] - 0.5}, xmin + 1, xd, ControlType -> None},
        {{ymin, init[[5]] - 0.5}, 1, ymax - 1, ControlType -> None},
        {{ymax, init[[6]] - 0.5}, ymin + 1, yd, ControlType -> None},
        {{zmin, init[[1]] - 0.5}, 1, zmax - 1, ControlType -> None},
        {{zmax, init[[2]] - 0.5}, zmin + 1, zd, ControlType -> None},
        SynchronousUpdating->True
        
        ]
       
       }, WindowTitle -> "Crop the data and press done", 
      WindowFloating -> True, Modal -> True
      ];

dataout =If[!(OptionValue[CropOutput] === "Clip"),
{a, b, c, d, e, f} = outp;
 If[dd == 3, 
data[[a ;; b, c ;; d, e ;; f]], 
data[[a ;; b, All, c ;; d, e ;; f]]
]
];
output=Switch[OptionValue[CropOutput],
"All",{dataout, outp},
"Data",dataout,
"Clip",outp];
];
Return[output]
]


(* ::Subsubsection::Closed:: *)
(*FindCrop*)


SyntaxInformation[FindCrop] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

FindCrop[data_, OptionsPattern[]] := Block[{unit, crp, p, dim, add},
	add= OptionValue[CropPadding];
	unit = Unitize[Total[Total[data, {#[[1]]}], {#[[2]]}] & /@ {{2, 2}, {1, 2}, {1, 1}}];
	dim = Dimensions[data];
	crp = (p = Position[#, 1]; Flatten@{First[p] - add, Last[p] + add}) & /@ unit;
	Flatten[MapThread[Clip[#1, {1, #2}] &, {crp, dim}]]
]


(* ::Subsubsection::Closed:: *)
(*AutoCropData*)


Options[AutoCropData] = {CropPadding->5}

SyntaxInformation[AutoCropData] = {"ArgumentsPattern" -> {_, OptionsPattern[]}}

AutoCropData[data_, opts:OptionsPattern[]] := Module[{datac,crp, add},
	add= OptionValue[CropPadding];
	datac = Switch[ArrayDepth[data],
		3, data,
		4, data[[All, 1]],
		_, Return[$Failed]
    ];
  
  crp=Flatten@{
    FindCrop[datac, opts],
    FindCrop[TransData[datac, "l"], opts],
    FindCrop[TransData[datac, "r"], opts]
    };
    
    {ApplyCrop[data,crp],crp}
  ]


(* ::Subsubsection::Closed:: *)
(*ReverseCrop*)


SyntaxInformation[ReverseCrop] = {"ArgumentsPattern" -> {_, _, _, _.}};

ReverseCrop[data_, dim_, crop_] := ReverseCrop[data, dim, crop, {0, 0}]

ReverseCrop[data_, dim_, crop_, {v1_, v2_}] := Module[{datac, pad},
  
  pad = If[v1 === 0 && v2 === 0,
    (*use original crop*)
    Partition[Abs[{1, dim[[1]], 1, dim[[2]], 1, dim[[3]]} - crop], 2]
    ,
    (*use other voxel size*)
    Floor[(v1/v2) Partition[
       Abs[{1, dim[[1]], 1, dim[[2]], 1, dim[[3]]} - crop], 2]]
    ];

  datac = Switch[ArrayDepth[data],
    3, ArrayPad[data, pad],
    4, Transpose[ArrayPad[#, pad] & /@ Transpose[data]],
    _, Return[$Failed, Module]
    ]
]


(* ::Subsubsection::Closed:: *)
(*ApplyCrop*)


SyntaxInformation[ApplyCrop] = {"ArgumentsPattern" -> {_, _, _.}};

ApplyCrop[data_, crop_] := ApplyCrop[data, crop , {0,0}]

ApplyCrop[data_, crop_ , {v1_,v2_}] := Module[{z1, z2, x1, x2, y1, y2,dim},
	
	dim=Dimensions[data];
	dim=If[Length[dim]==4,dim[[{1,3,4}]],dim];
	
	{z1, z2, x1, x2, y1, y2} = If[v1===0&&v2===0,
		crop,
		Round[(crop - 1) Flatten[Transpose[ConstantArray[v1/v2, 2]]] + 1]
	];
	
	If[z1<1||z2>dim[[1]]||x1<1||x2>dim[[2]]||y1<1||y2>dim[[3]],Return[Message[ApplyCrop::dim]]];
		
  If[ArrayDepth[data] === 4,
   data[[z1 ;; z2, All, x1 ;; x2, y1 ;; y2]],
   If[ArrayDepth[data] === 3,
    data[[z1 ;; z2, x1 ;; x2, y1 ;; y2]],
    If[ArrayDepth[data] === 2,
     data[[x1 ;; x2, y1 ;; y2]]
     ]]]]



(* ::Subsection:: *)
(*Split and merge*)


(* ::Subsubsection::Closed:: *)
(*CutData*)


SyntaxInformation[CutData] = {"ArgumentsPattern" -> {_,_.}}

CutData[data_]:=CutData[data,FindMiddle[data]]

CutData[data_,cut_] := Switch[ArrayDepth[data],
		4,{data[[All, All, All, ;; cut]],data[[All, All, All, (cut + 1) ;;]],cut},
		3,{data[[All, All, ;; cut]], data[[All, All, (cut + 1) ;;]],cut}]

FindMiddle[dati_] := Module[{dat, fdat, len, datf,peaks,mid,peak,center,mask,ran},
  
	(*flatten mean and normalize data*)
	dat=dati;
	fdat = Flatten[dat];
	dat = Clip[dat, {0, Quantile[Pick[fdat, Unitize[fdat], 1], .95]}];
	dat = N@Nest[Mean, dat, ArrayDepth[dat] - 1];
	len = Length[dat];
	dat = len dat/Max[dat];
	mask = UnitStep[dat - .1 len];
	ran = Flatten[Position[mask, 1][[{1, -1}]]];
	
	(*smooth the data a bit*)
	datf = len - GaussianFilter[mask dat, len/20];
	(*find the peaks*)
	peaks = FindPeaks[datf];
	peaks = If[Length[peaks] >= 3, peaks[[2 ;; -2]], peaks];
	peaks = Select[peaks, (ran[[1]] < #[[1]] < ran[[2]]) &];
	
	(*find the most middle peak*)
	mid = Round[Length[dat]/2];
	center = {mid, .75 len};
	peak = Nearest[peaks, center];
	
	Print[Show[
	ListLinePlot[{len-dat,datf}, PlotStyle->{Black,Orange}],
	ListPlot[{peaks,peak,{center}},PlotStyle->(Directive[{PointSize[Large],#}]&/@{Blue,Red,Green})]
	,ImageSize->100]];
	
	(*output*)
	Round[First@First@peak]
  ]



(* ::Subsubsection::Closed:: *)
(*StichData*)


SyntaxInformation[StichData] = {"ArgumentsPattern" -> {_,_}}

StichData[datal_, datar_] := TransData[Join[TransData[datal, "r"], TransData[datar, "r"]], "l"];


(* ::Subsection:: *)
(*Package Functions*)


(* ::Subsubsection::Closed:: *)
(*QMRIToolsPackages*)


SyntaxInformation[QMRIToolsPackages] = {"ArgumentsPattern" -> {}};

QMRIToolsPackages[] := DeleteDuplicates[(StringSplit[#, "`"] & /@ Contexts["QMRITools`*`"])[[All, 2]]]


(* ::Subsubsection::Closed:: *)
(*QMRIToolsFunctions*)


SyntaxInformation[QMRIToolsFunctions] = {"ArgumentsPattern" -> {_.,_.}};

QMRIToolsFunctions[]:=QMRIToolsFunctions[""];

QMRIToolsFunctions[toolb_String]:= Block[{packages,names,functions,options,allNames,output},
	packages = If[toolb === "", QMRIToolsPackages[], {toolb}];
	allNames = Sort[Flatten[Names["QMRITools`" <> # <> "`*"]]] & /@ packages;
		
	{functions, options} = Transpose[(names = #;
		options = ToString /@ Sort[DeleteDuplicates[Flatten[Options[ToExpression[#]][[All, 1]] & /@ names]]];
		functions = Complement[names, options];
		{functions, options}) & /@ allNames];
	
	output = Transpose[{packages, functions, options}];
	
	If[toolb === "", output, First@output]
]

QMRIToolsFunctions[p_Integer]:=Block[{toolbox,functions,options},
	{toolbox,functions,options}=Transpose[QMRIToolsFunctions[]];
	
	functions = Sort@Flatten[functions];
	options = Sort@Flatten[options];
	
	functions = If[Length[functions]<=p,{functions},Partition[functions, p, p, 1, ""]];
	options = If[Length[options]<=p,{options},Partition[options, p, p, 1, ""]];
	
	Print[Column[{"",Style["Functions", Bold, 16], "",functions // Transpose // TableForm,""}]];
	Print[Column[{"",Style["Options", Bold, 16], "",options // Transpose // TableForm,""}]];
]

QMRIToolsFunctions[toolb_String,p_Integer]:=Block[{toolbox,functions,options, output},
	If[toolb == "All",
		QMRIToolsFunctions[#, p] & /@ QMRIToolsPackages[];
		,
		{toolbox,functions,options}=QMRIToolsFunctions[toolb];
		
		functions = If[Length[functions]<=p,{functions},Partition[functions, p, p, 1, ""]];
		options = If[Length[options]<=p,{options},Partition[options, p, p, 1, ""]];
	
		output = Column[{"",
			Style[toolbox, Bold, 24], "",
			Style["Functions", Bold, 16], functions // Transpose// TableForm,"",
			Style["Options", Bold, 16], options// Transpose // TableForm,""}];
		
		Print[output];
	]
]


(* ::Subsubsection::Closed:: *)
(*QMRIToolsFuncPrint*)


SyntaxInformation[QMRIToolsFuncPrint] = {"ArgumentsPattern" -> {_.}};

QMRIToolsFuncPrint[]:=QMRIToolsFuncPrint[""]

QMRIToolsFuncPrint[toolb_String]:=If[toolb=="",PrintAll/@QMRIToolsFunctions[];,PrintAll[QMRIToolsFunctions[toolb]]]

PrintAll[{name_, functions_, options_}]:=(Print[Style[name, Bold, 24]];
		Print[Style["Functions", Bold, 16]];
		Information /@ functions;
		Print[Style[Options, Bold, 16]];
		Information /@ options;)


(* ::Subsubsection::Closed:: *)
(*Compilable functions*)


SyntaxInformation[CompilebleFunctions] = {"ArgumentsPattern" -> {}};

CompilebleFunctions[]:=(Partition[Compile`CompilerFunctions[] // Sort, 50, 50, 1, 1] // Transpose) /. 1 -> {} // TableForm


(* ::Subsection:: *)
(*NoZeroFunctions*)


(* ::Subsubsection::Closed:: *)
(*DevideNoZero*)


SyntaxInformation[DevideNoZero] = {"ArgumentsPattern" -> {_,_}};

DevideNoZero[num_,den_]:=DevideNoZeroi[Chop[num],Chop[den]]

DevideNoZeroi = Compile[{{num, _Real, 1}, {den, _Real, 0}}, If[den == 0., num 0., num/den], RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed", Parallelization -> True];
DevideNoZeroi = Compile[{{num, _Real, 0}, {den, _Real, 0}}, If[den == 0., 0., num/den], RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed", Parallelization -> True];


(* ::Subsubsection::Closed:: *)
(*MeanNoZero*)


SyntaxInformation[MeanNoZero] = {"ArgumentsPattern" -> {_, _.}};

MeanNoZero[datai_] := Block[{data},
  data = N@Chop@TransData[datai, "l"];
  N@Chop@Map[Mean[Pick[#, Unitize[#], 1] /. {} -> {0.}] &, data, {ArrayDepth[data] - 1}]
  ]


(* ::Subsubsection::Closed:: *)
(*MedianNoZero*)


SyntaxInformation[MedianNoZero] = {"ArgumentsPattern" -> {_, _.}};

MedianNoZero[datai_] := Block[{data},
  data = N@Chop@TransData[datai, "l"];
  N@Chop@Map[Median[Pick[#, Unitize[#], 1] /. {} -> {0.}] &, data, {ArrayDepth[data] - 1}]
  ]


(* ::Subsubsection::Closed:: *)
(*LogNoZero*)


SyntaxInformation[LogNoZero] = {"ArgumentsPattern" -> {_}};

LogNoZero[val_] := LogNoZeroi[Chop[val]]

LogNoZeroi = Compile[{{val, _Real, 0}},If[val == 0., 0., Log[val]],RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed", Parallelization -> True]


(* ::Subsubsection::Closed:: *)
(*ExpNoZero*)


SyntaxInformation[ExpNoZero] = {"ArgumentsPattern" -> {_}};

ExpNoZero[val_] := ExpNoZeroi[Chop[val]]

ExpNoZeroi = Compile[{{val, _Real, 0}},If[val == 0., 0., Exp[val]],RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed", Parallelization -> True]


(* ::Subsubsection::Closed:: *)
(*RMSNoZero*)


SyntaxInformation[RMSNoZero] = {"ArgumentsPattern" -> {_}};

RMSNoZero[vec_] := RMSNoZeroi[If[ArrayDepth[vec] > 1, TransData[vec, "l"], vec]]

RMSNoZeroi = Compile[{{vec, _Real, 1}}, If[AllTrue[vec, # === 0. &], 0., RootMeanSquare[Pick[vec, Unitize[vec], 1]]], RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"];


(* ::Subsubsection::Closed:: *)
(*MADNoZero*)


SyntaxInformation[MADNoZero] = {"ArgumentsPattern" -> {_}};

MADNoZero[vec_] := MADNoZeroi[If[ArrayDepth[vec] > 1, TransData[vec, "l"], vec]]

MADNoZeroi = Compile[{{vec, _Real, 1}}, If[AllTrue[vec, # === 0. &], 0., MedianDeviation[Pick[vec, Unitize[vec], 1]]], RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"];


(* ::Subsection:: *)
(*Memory functions*)


(* ::Subsubsection::Closed:: *)
(*MemoryUsage*)


SyntaxInformation[MemoryUsage] = {"ArgumentsPattern" -> {_.}}

MemoryUsage[size_: 1] := Module[{},
  NotebookClose[memwindow];
  memwindow = 
   CreateWindow[DialogNotebook[{CancelButton["Close", DialogReturn[]],
      Manipulate[
       If[listing === {},
        "Noting found",
        TableForm[Join[#, {
             Row[Dimensions[ToExpression["Global`" <> #[[1]]]], "x"],
             Head[ToExpression["Global`" <> #[[1]]]],
             ClearButton["Global`" <> #[[1]]]
             }] & /@ listing, 
         TableHeadings -> {None, {"Name", "Size (MB)", "Dimensions", "Head"}}]
        ]
       ,
       {{msize, size, "minimum size [MB]"}, {1, 10, 100, 1000}},
       Button["Update", listing = MakeListing[msize]],
       {listing, ControlType -> None},
       ContentSize -> {500, 600},
       Paneled -> False,
       AppearanceElements -> None,
       Initialization :> {
         MakeListing[mb_] := Reverse@SortBy[Select[myByteCount[Names["Global`*"]], #[[2]] > mb &], Last],
         ClearButton[name_] := Button["Clear",       
           Replace[ToExpression[name, InputForm, Hold], Hold[x__] :> Clear[Unevaluated[x]]];
           listing = MakeListing[msize]
         ],
         listing = MakeListing[size];
         }
       ]}, WindowTitle -> "Plot data window", Background -> White]
    ];
  ]


SetAttributes[myByteCount, Listable ]

myByteCount[symbolName_String] := Replace[
	ToExpression[symbolName, InputForm, Hold], Hold[x__] :> If[MemberQ[Attributes[x], Protected | ReadProtected],
     Sequence @@ {},
     (*output size in MB and name*)
     {StringDelete[symbolName, "Global`"], 
      Round[ByteCount[Through[{OwnValues, DownValues, UpValues, SubValues, DefaultValues, FormatValues, NValues}[Unevaluated@x, Sort -> False]]]/1000000., .01]}
     ]
   ];


(* ::Subsubsection::Closed:: *)
(*ClearTemporaryVariables*)


SyntaxInformation[ClearTemporaryVariables] = {"ArgumentsPattern" -> {_.}}

ClearTemporaryVariables[] := Block[{names, attr},
  names = Names["QMRITools`*`Private`*"];
  attr = Attributes /@ names;
  MapThread[If[#1 === {Temporary}, ClearAll[#2]] &, {attr, names}];
  ]


(* ::Subsection::Closed:: *)
(*SumOfSquares*)


Options[SumOfSquares] = {OutputWeights -> True}

SyntaxInformation[SumOfSquares] = {"ArgumentsPattern" -> {_,OptionsPattern[]}};

SumOfSquares[data_, OptionsPattern[]] := Block[{sos, weights, dataf},
  dataf = TransData[data, "l"];
  sos = SumOfSquaresi[dataf];
  
  If[OptionValue[OutputWeights],
   weights = DevideNoZero[dataf, sos];
   {sos, TransData[weights,"r"]},
   sos
   ]
  ]

SumOfSquaresi = Compile[{{sig, _Real, 1}}, Sqrt[Total[sig^2]], RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed", Parallelization -> True];


(* ::Subsection::Closed:: *)
(*NNLeastSquares*)


SyntaxInformation[NNLeastSquares] = {"ArgumentsPattern" -> {_, _}};

(*Main function*)
NNLeastSquares[A_, f_] := With[{
    toIndicesZ = Compile[{{v, _Real, 1}}, Flatten[Position[v, 1.]]],
    toIndicesP = Compile[{{v, _Real, 1}}, Flatten[Position[1 - v, 1.]]],
    wCalc = Compile[{{AA, _Real, 2}, {ff, _Real, 1}, {x, _Real, 1}}, Transpose[AA].(ff - AA.x)],
    zCalc = Compile[{{R, _Real, 2}, {Q, _Real, 2}, {ff, _Real, 1}}, Inverse[R].Q.ff],
    xCalc = Compile[{{x, _Real, 1}, {z, _Real, 1}, {posSet, _Integer, 1}}, Block[{negz, alpha},
       negz = Select[posSet, z[[#]] < 0. &];
       alpha = Min[x[[negz]]/(x[[negz]] - z[[negz]])];
       N@Chop[x + alpha (z - x), 10.^-10]]]
    },
   Quiet[
    Block[{zerSet, posSet, maxPos, setz, z, x, zeroed, w, zeros, i, j,
       l},
     i = j = 1;
     zeros = 0 A[[1]];
     l = Length[zeros];
     (*fuctions to get posSet and zerSet and to calc z*)
     zerSet := toIndicesZ[zeroed];
     posSet := toIndicesP[zeroed];
     maxPos := Last[Ordering[zeroed w]];
     setz := Block[{Q, R},
       {Q, R} = QRDecomposition[A[[All, posSet]]];
       z = zeros; z[[posSet]] = zCalc[R, Q, f];
       ];
     (*initialize x, w, posSet and zerSet*)
     x = zeros;
     w = wCalc[A, f, x];
     zeroed = zeros + 1.;
     (*fist While loop*)
     While[j < l && zerSet != {} && Max[w[[zerSet]]] > 10.^-10,
      j++;
      (*index of max(w) and add j to posSet*)
      zeroed[[maxPos]] = 0.;
      (*calc z values for posSet*)
      setz;
      (*second While loop*)
      While[Min[z] < 0.,
       i++;
       (*calc alpha and recalculate x*)
       x = xCalc[x, z, posSet];
       (*move to zerSet all posSet vals were x=0*)
       zeroed[[Select[posSet, x[[#]] == 0. &]]] = 1.;
       (*calc z values for posSet*)
       setz;
       ];
      (*recalculate x and w*)
      w = wCalc[A, f, x = z];
      ];
     (*output solution*)
     Return[x];
     ]]];

(*support functions*)
toIndicesZ = Compile[{{v, _Real, 1}}, Flatten[Position[v, 1.]]];
toIndicesP = Compile[{{v, _Real, 1}}, Flatten[Position[1 - v, 1.]]];
wCalc = Compile[{{A, _Real, 2}, {f, _Real, 1}, {x, _Real, 1}}, 
   Transpose[A].(f - A.x)];
zCalc = Compile[{{R, _Real, 2}, {Q, _Real, 2}, {f, _Real, 1}}, 
   Inverse[R].Q.f];
xCalc = Compile[{{x, _Real, 1}, {z, _Real, 1}, {posSet, _Integer, 1}},
   Block[{negz, alpha},
    negz = Select[posSet, z[[#]] < 0 &];
    alpha = Min[x[[negz]]/(x[[negz]] - z[[negz]])];
    N@Chop[x + alpha (z - x), 10.^-10]]];


(* ::Subsection::Closed:: *)
(*Filters*)


(* ::Subsubsection::Closed:: *)
(*LapFilter*)


LapFilter[data_, fil_:0.8] := Clip[Chop[ImageData[TotalVariationFilter[Image3D[N@data, "Real"], fil, Method -> "Laplacian", MaxIterations -> 15]]], MinMax[data]]


(* ::Subsubsection::Closed:: *)
(*LapFilter*)


StdFilter[data_, ker_:2] := Abs[Sqrt[GaussianFilter[data^2, ker] - GaussianFilter[data, ker]^2]]


(* ::Section:: *)
(*End Package*)


End[]

EndPackage[]
