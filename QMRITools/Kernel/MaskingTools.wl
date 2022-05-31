(* ::Package:: *)

(* ::Title:: *)
(*QMRITools MaskingTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["QMRITools`MaskingTools`", Join[{"Developer`"}, Complement[QMRITools`$Contexts, {"QMRITools`MaskingTools`"}]]];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection::Closed:: *)
(*Functions*)


NormalizeData::usage = 
"NormalizeData[data] normalizes the data to the mean signal of the data. For 4D data it normalizes to the first volume of the 4th dimension.
NormalizeData[data,{min,max}] normalizes the data between min and max."

NormalizeMeanData::usage = 
"NormalizeMeanData[data] calculates the mean normalized data from a 4D dataset."

HomoginizeData::usage = 
"HomoginizeData[data, mask] tries to homoginize the data within the mask by removing intensity gradients."


Mask::usage =
"Mask[data] creates a mask by automatically finding a threshold.
Mask[data, min]creates a mask which selects only data above the min value.
Mask[data,{min,max}] creates a mask which selects data between the min and max value."

SmoothMask::usage = 
"SmoothMask[mask] generates one clean masked volume form a noisy mask."

MaskData::usage = 
"MaskData[data, mask] applies a mask to data. mask can be 2D or 3D, data can be 2D, 3D or 4D."

GetMaskData::usage =
"GetMaskData[data, mask] retruns the data selected by the mask."

MeanSignal::usage = 
"MeanSignal[data] calculates the mean signal per volume of 4D data.
MeanSignal[data, pos] calculates the mean signal per volume of 4D data for the given list of positions."


SplitSegmentations::usage = 
"SplitSegmentations[segmentation] splits a lable mask from ITKsnap or slicer3D in seperate masks and label numbers.
Output is masks and label numbers, {mask, labs}."

RescaleSegmentation::usage = 
"RescaleSegmentation[data, dim] rescales segmentations to given dimensions.
RescaleSegmentation[data, {vox1, vox2}] rescales segmentations from voxelsize vox1 to voxelsize vox2."

MergeSegmentations::usage = 
"MergeSegmentations[masks, labels] generates an ITKsnap or slices3D compatible segmentation from individual masks and label numbers.
Output is a labled segmentation."

SmoothSegmentation::usage =
"SmoothSegmentation[masks] smooths segmentations and removes the overlaps between multiple segmentations." 

RemoveMaskOverlaps::usage = 
"RemoveMaskOverlaps[mask] removes the overlaps between multiple masks. Mask is a 4D dataset with {z, masks, x, y}."

GrowMask::usage=
"GrowMask[mask,size] if size > 0 the mask is dilated and if size < 0 the mask is eroded."

SegmentMask::usage = 
"SegmentMask[mask, n] divides a mask in n segments along the slice direction, n must be an integer. The mask is divided in n equal parts where each parts has the same number of slices."


ROIMask::usage = 
"ROIMask[maskdim, {name->{{{x,y},slice}..}..}] crates mask from coordinates x and y at slice. 
maskdim is the dimensions of the output {zout,xout,yout}."


(* ::Subsection::Closed:: *)
(*Options*)


MaskSmoothing::usage = 
"MaskSmoothing is an options for Mask, if set to True it smooths the mask, by closing holse and smoothing the contours."

MaskComponents::usage =
"MaskComponents is an option for Mask and SmoothMask. Determinse the amount of largest clusters used as mask." 

MaskClosing::usage =
"MaskClosing  is an option for Mask and SmoothMask. The size of the holes in the mask that will be closed." 

MaskDilation::usage = 
"MaskDilation is an option for Mask. If the value is greater than 0 it will dilate the mask, if the value is smaller than 0 it will erode the mask."

MaskFiltKernel::usage =
"MaskFiltKernel is an option for Mask, SmoothMask and SmoothSegmentation. How mucht the contours are smoothed." 

GetMaskOutput::usage = 
"GetMaskOutput is an option for GetMaskData. Defaul is \"Slices\" which gives the mask data per slices. Else the entire mask data is given as output."

GetMaskOnly::usage = 
"GetMaskOnly is an option for GetMaskData. If set True all values in the mask are given, if set False only non zero values in the mask are give."

UseMask::usage = 
"UseMask is a function for MeanSignal and DriftCorrect."


(* ::Subsection::Closed:: *)
(*Error Messages*)


Mask::tresh = "Given treshhold `1` value is not a vallid input, must be a number for min treshhold only or a vector {min tresh, max tresh}."

GetMaskData::tresh = "The dimensions of the data and the mask must be the same, dataset: `1`, mask: `2`."

MaskData::dim = "Dimensions are not equal, data: `1`, mask `2`." 

MaskData::dep = "Data dimensions should be 2D, 3D or 4D. Mask dimensions should be 2D or 3D. Data is `1`D and Mask is `2`D."

ROIMask::war = "there are more slices in the roi set than in the given dimensions."


(* ::Section:: *)
(*Functions*)


Begin["`Private`"]


(* ::Subsection:: *)
(*Normalize Functions*)


(* ::Subsubsection::Closed:: *)
(*NormalizeData*)


SyntaxInformation[NormalizeData] = {"ArgumentsPattern" -> {_,_., OptionsPattern[]}};

NormalizeData[data_] := Block[{mdat},
	Switch[ArrayDepth[data],
		3, NormalizeData[data, Mask[data - Min[data]]],
		4, NormalizeData[data, mdat = Mean[Transpose[data]]; Mask[mdat - Min[mdat]]]
	]
]

NormalizeData[data_, mask_] := Block[{dat,mn,min,dato},
	min=Min[data];
	dat = GetMaskData[Switch[ArrayDepth[data],3, data, 4, data[[All,1]]], mask];
	If[min < 0, dat = dat - min; dato=data-min,dato=data];
	mn = MeanNoZero[dat]/100.;
	ToPackedArray[dato/mn]
]

(* ::Subsubsection::Closed:: *)
(*NormalizeMeanData*)


NormalizeMeanData[data_] := NormalizeData@Mean@Transpose@data

NormalizeMeanData[data_, mask_] := NormalizeData[Mean@Transpose@data,mask]


(* ::Subsubsection::Closed:: *)
(*HomoginizeData*)


SyntaxInformation[HomoginizeData] = {"ArgumentsPattern" -> {_, _}};

HomoginizeData[datai_, mask_] := 
 Module[{data, mn, fit, datac, maskout},
  data = mask GaussianFilter[datai, 5];
  mn = Mean[Cases[Flatten[N[data]],Except[0.]]];
  fit = FitGradientMap[Erosion[mask, 3] data];
  
  datac = (datai/(fit + 0.001));
  maskout = Mask[datac, 0.1];
  maskout = Dilation[SmoothMask[maskout], 5];
  maskout Clip[mn datac, {0.8, 1.5} MinMax[data], {0, 0}]
  ]


FitGradientMap[data_] := Module[{func, x, y, z, coor},
  Clear[x, y, z];
  coor = Flatten[
    MapIndexed[
     ReleaseHold@If[#1 == 0, Hold[Sequence[]], Join[#2, {#1}]] &, 
     data, {3}], 2];
  func = Fit[coor, {1, x, y, z, x y, x z, y z, z^2, x^2, y^2(*, z^3, x^3, y^3, z x x, y x x, z y y , x y y , y z z, x z z*)}, {x, y, z}];
  {x, y, z} = TransData[Array[{#1, #2, #3} &, Dimensions[data]], "r"];
  func
  ]


(* ::Subsection:: *)
(*Masking*)


(* ::Subsubsection::Closed:: *)
(*Mask*)


Options[Mask]={MaskSmoothing -> False, MaskComponents -> 2, MaskClosing -> 5, MaskFiltKernel -> 2, MaskDilation -> 0};

SyntaxInformation[Mask] = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

Mask[data_,opts:OptionsPattern[]]:=Mask[data, 0, opts]

Mask[dat_?ArrayQ, tr_,opts:OptionsPattern[]]:= Block[{mask,tresh, dataD, datN, data, dil},
	
	data = ToPackedArray@N@dat;
	dataD = ArrayDepth[data];
	
	If[Length[tresh]>2, Message[Mask::tresh, tresh],
		
		If[ArrayDepth[data]>3, Message[Mask::dep, dataD],
			
			mask = If[tr===0,
				datN = data/(0.95 MeanNoZero[Flatten[data]]);
				(*no threshhold*)
				datN = If[dataD==2,Image[datN],Image3D[datN]];
				ImageData[Binarize[datN]]
				,
				(*threshhold*)
				tresh=If[NumberQ[tr],{tr},tr];		
				If[Length[tresh]==1,
					UnitStep[data-tresh[[1]]],
					UnitStep[data-tresh[[1]]]-UnitStep[data-tresh[[2]]]
				]
			];
			
			(*smooth the mask if needed*)		
			mask = ToPackedArray@If[OptionValue[MaskSmoothing], 
				SmoothMask[mask, MaskComponents -> OptionValue[MaskComponents], 
					MaskClosing -> OptionValue[MaskClosing], MaskFiltKernel -> OptionValue[MaskFiltKernel]]
				, 
				mask
			];
			
			dil = OptionValue[MaskDilation];
			If[dil>0,
				Dilation[mask,Round[OptionValue[MaskDilation]]], 
				If[dil<0,
					Erosion[mask,Round[OptionValue[MaskDilation]]],
					mask	
				]
			]
		]
	]
]


(* ::Subsubsection::Closed:: *)
(*SmoothMask*)


Options[SmoothMask]={MaskComponents->1, MaskClosing->5, MaskFiltKernel->2}

SyntaxInformation[SmoothMask] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

SmoothMask[mask_,OptionsPattern[]] := Block[{pad, close, obj, filt},
  close = OptionValue[MaskClosing];(*close holes in mask*)
  pad = 3 close;
  obj = OptionValue[MaskComponents];(*number of objects that are maintained*)
  filt = OptionValue[MaskFiltKernel];(*how much smooting*)

  If[ArrayDepth[mask]==2,
  	Round[GaussianFilter[ArrayPad[Closing[ImageData[SelectComponents[Image[ArrayPad[mask, pad]],"Count", -obj]], close],-pad], filt]],
  	Round[GaussianFilter[ArrayPad[Closing[ImageData[SelectComponents[Image3D[ArrayPad[mask, pad]],"Count", -obj]], close],-pad], filt]]
  ]
]


(* ::Subsubsection::Closed:: *)
(*MaskData*)


SyntaxInformation[MaskData] = {"ArgumentsPattern" -> {_, _}};

MaskData[data_, mask_]:=Block[{dataD, maskD,dimD,dimM,out},
	dataD = ArrayDepth[data];
	maskD = ArrayDepth[mask];
	dimD = Dimensions[data];
	dimM = Dimensions[mask];
	
	out = Switch[{dataD,maskD},
		{2,2}, If[dimD == dimM, mask data, 1],
		{3,3}, If[dimD == dimM, mask data, 1],
		{3,2}, If[dimD[[2;;]] == dimM, mask # &/@ data, 1],
		{4,3}, 
		Which[
			dimD[[2;;]] == dimM, mask # & /@ data,
			dimD[[{1,3,4}]] == dimM, Transpose[mask # & /@ Transpose[data]],
			True, 1
			],
		_, 2;
	];
	
	If[out === 1, Message[MaskData::dim, dimD, dimM]];
	If[out === 2, Message[MaskData::dep, dataD, maskD]];
	
	ToPackedArray@N@out
]


(* ::Subsubsection::Closed:: *)
(*GetMaskData*)


Options[GetMaskData] = {GetMaskOutput -> "All",GetMaskOnly->False}

SyntaxInformation[GetMaskData] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

GetMaskData[data_?ArrayQ, mask_?ArrayQ, OptionsPattern[]] := Block[{fdat},
	If[!(Dimensions[data]=!=Dimensions[mask]||Drop[Dimensions[data], {2}]=!=Dimensions[mask]),
		Message[GetMaskData::dim,Dimensions[data],Dimensions[mask]]
		,
		If[OptionValue[GetMaskOnly],
			(*get true mask values*)
			Switch[OptionValue[GetMaskOutput],
				"Slices", MapThread[Pick[Chop[Flatten[N[#1]]], Unitize[Flatten[#2]], 1]&, {data,mask}, ArrayDepth[data]-2],
				_, Pick[Chop[Flatten[N[data]]], Unitize[Flatten[mask]], 1]
			]
			,			
			(*get all non zero values in mask*)
			Switch[OptionValue[GetMaskOutput],
				"Slices", Map[(fdat=Chop[Flatten[N@#]];Pick[fdat, Unitize[fdat], 1])&, data*mask, {ArrayDepth[data]-2}],
				_ , fdat=N@Chop[Flatten[N[data mask]]];	Pick[fdat, Unitize[fdat], 1]
			]
		]
	]
]


(* ::Subsection::Closed:: *)
(*MeanSignal*)


Options[MeanSignal] = { UseMask->True }

SyntaxInformation[MeanSignal] = {"ArgumentsPattern" -> {_, _.,OptionsPattern[]}};

MeanSignal[data_, opts:OptionsPattern[]] := MeanSignal[data, "", opts];

MeanSignal[data_, posi_ ,OptionsPattern[]] := Block[{mean, mask, pos, dat,mdat},
  
  Which[
  	ListQ[posi],
  	pos=posi; dat=data[[All,pos]];
  	,
  	IntegerQ[posi],
  	pos={posi}; dat=data[[All,pos]];
  	,
  	True,
  	pos=All; dat=data;
  ];
  
  mask = If[OptionValue[UseMask],
  	mdat = NormalizeData[Mean@Transpose@dat];
   	Round@GaussianFilter[Mask[mdat], 5]
   	,
   	ConstantArray[1,Dimensions[dat[[All,1]]]]
  ];   
  
  mean = MeanNoZero[Flatten[#]] & /@ Transpose[MaskData[dat, mask]];
   
  N@mean
]


(* ::Subsection:: *)
(*Segmentation functions*)


(* ::Subsubsection::Closed:: *)
(*SplitSegmentations*)


SyntaxInformation[SplitSegmentations] = {"ArgumentsPattern" -> {_}};

SplitSegmentations[masksI_]:=SplitSegmentations[masksI, True]

SplitSegmentations[masksI_,sparse_] := Block[{vals, masks},
	masks=SparseArray[masksI];
	vals = DeleteCases[Sort@Round[DeleteDuplicates[Flatten[masksI]]],0];
	masks =(1 - Unitize[masks - #]) & /@ vals;
	masks = Transpose[masks];
	{If[sparse,masks,Normal@masks], vals}
  ]


(* ::Subsubsection::Closed:: *)
(*MergeSegmentations*)


SyntaxInformation[MergeSegmentations] = {"ArgumentsPattern" -> {_,_}};

MergeSegmentations[masks_, vals_] := Normal@Total[vals Transpose@SparseArray[masks]];


(* ::Subsubsection::Closed:: *)
(*SmoothSegmentation*)


Options[SmoothSegmentation] = {MaskFiltKernel -> 2, MaskComponents->1}

SyntaxInformation[SmoothSegmentation] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

SmoothSegmentation[masks_, OptionsPattern[]] := 
 Block[{obj, maskInp, maskOver, maskOut, smooth, posOver, x, y, z, p, tmp},
 	smooth = OptionValue[MaskFiltKernel];
	obj = OptionValue[MaskComponents];
	
	(*convert data to sparse Array and transpose*)
	maskInp = Transpose[SparseArray[Round@masks]];
	
	(*Get smoothed or non smoothed masks*)
	maskInp = SparseArray@Round[ImageData[SelectComponents[Image3D[Round[GaussianFilter[Normal[#], smooth] + 0.15], "Bit"], "Count", -If[obj<1, 1, obj], CornerNeighbors -> False]]]& /@ maskInp;
	
	(*remove the overlaps*)
	Transpose@RemoveMaskOverlapsI[SparseArray[maskInp]]
  ]


(* ::Subsubsection::Closed:: *)
(*RemoveMaskOverlaps*)


SyntaxInformation[RemoveMaskOverlaps] = {"ArgumentsPattern" -> {_}};
	
RemoveMaskOverlaps[masks_] := Transpose@RemoveMaskOverlapsI[Transpose[SparseArray[Round@masks]]];

RemoveMaskOverlapsI[masks_] := Block[{maskOver, posOver, maskInp, maskOut, z, x, y, p},
	maskOver = SparseArray[Mask[Total[masks], 1.5]];
	posOver = maskOver["ExplicitPositions"];
	maskOut = SparseArray[SparseArray[(1 - maskOver) #] & /@ masks];
	
	maskInp = maskOver Transpose[masks, {4, 1, 2, 3}];
	p = ({z, x, y} = #; {First@First[maskInp[[z, x, y]]["ExplicitPositions"]], z, x, y}) & /@posOver;
	maskOut + SparseArray[p -> 1, Dimensions[maskOut]]
]


(* ::Subsubsection::Closed:: *)
(*RescaleSegmentation*)


GrowMask[seg_, size_] := Which[size === 0,
	SparseArray[seg],
	size > 0,
	If[ArrayDepth[seg]>3,
		Transpose[SparseArray[SparseArray[ImageData@Dilation[Image3D[#], Round[size]]] & /@ Transpose[seg]]],
		SparseArray[Dilation[Normal[seg], Round[size]]]
	],
	size< 0,
	If[ArrayDepth[seg]>3,
		Transpose[SparseArray[SparseArray[ImageData@Erosion[Image3D[#], Round[Abs[size]]]] & /@ Transpose[seg]]],
		SparseArray[Dilation[Normal[seg], Round[size]]]
	]
]


(* ::Subsubsection::Closed:: *)
(*RescaleSegmentation*)


SyntaxInformation[RescaleSegmentation] = {"ArgumentsPattern" -> {_, _}};

RescaleSegmentation[seg_, vox_] := Block[{segs, val},
	If[ArrayDepth[seg] == 3,
		{segs, val} = SplitSegmentations[seg],
		segs = seg
	];
	segs = Transpose@RemoveMaskOverlapsI[SparseArray[SparseArray[Round[RescaleData[Normal[#], vox, InterpolationOrder -> 1]]] & /@Transpose[segs]]];
	If[ArrayDepth[seg] == 3, MergeSegmentations[segs, val], segs]
]



(* ::Subsubsection::Closed:: *)
(*SegmentMask*)


SyntaxInformation[SegmentMask] = {"ArgumentsPattern" -> {_, _, _.}};

SegmentMask[mask_, seg_?IntegerQ] := Block[{pos, f, l, sel, out},
  pos = Flatten@Position[Unitize[Total[Flatten[#]]] & /@ mask, 1];
  {f, l} = {First[pos], Last[pos]};
  sel = Partition[Round[Range[f, l, ((l - f)/seg)]], 2, 1] + Append[ConstantArray[{0, -1}, seg - 1], {0, 0}];
  out = ConstantArray[0*mask, seg];
  Table[out[[i, sel[[i, 1]] ;; sel[[i, 2]]]] = mask[[sel[[i, 1]] ;; sel[[i, 2]]]], {i, 1, seg}];
  out
  ]


(* ::Subsection::Closed:: *)
(*ROIMask*)


SyntaxInformation[ROIMask] = {"ArgumentsPattern" -> {_, _, _.}};

ROIMask[ROIdim_,maskdim_,ROI:{(_?StringQ->{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..})..}]:=
Module[{output},
	output=Map[#[[1]]->ROIMask[ROIdim,maskdim,#[[2]]]&,ROI];
	Print["The Folowing masks were Created: ",output[[All,1]]];
	Return[output]
	]

ROIMask[ROIdim_,maskdim_,ROI:{{_?StringQ->{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..}}..}]:=
Module[{output},
	output=Map[#[[1,1]]->ROIMask[ROIdim,maskdim,#[[1,2]]]&,ROI];
	Print["The Folowing masks were Created: ",output[[All,1]]];
	Return[output]
	]

ROIMask[ROIdim_,maskdim_,ROI:{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..}]:=
Module[{output,ROIcor,ROIslice,msk},
	output=ConstantArray[0,Join[{ROIdim[[1]]},maskdim]];
	If[ROI[[All,1]]!={{{0,0}}},
		ROIcor=Round[ROI[[All,1]]];
		ROIslice=Clip[ROI[[All,2]],{1,ROIdim[[1]]}];
		msk=1-ImageData[Image[Graphics[Polygon[#],PlotRange->{{0,ROIdim[[3]]},{0,ROIdim[[2]]}}],"Bit",ColorSpace->"Grayscale",ImageSize->maskdim]]&/@ROIcor;
		MapIndexed[output[[#1]]=msk[[First[#2]]];&,ROIslice];
		];
	Return[output];
	]

ROIMask[maskdim_,ROI:{(_?StringQ->{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..})..}]:=
Module[{output},
	output=Map[#[[1]]->ROIMask[maskdim,#[[2]]]&,ROI];
	Print["The Folowing masks were Created: ",output[[All,1]]];
	Return[output]
	]

ROIMask[maskdim_,ROI:{{_?StringQ->{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..}}..}]:=
Module[{output},
	output=Map[#[[1,1]]->ROIMask[maskdim,#[[1,2]]]&,ROI];
	Print["The Folowing masks were Created: ",output[[All,1]]];
	Return[output]
	]

ROIMask[maskdim_,ROI:{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..}]:=
Module[{output, ROIcor, ROIslice, msk},
 output = ConstantArray[0, maskdim];
 If[ROI[[All, 1]] != {{{0, 0}}},
  ROIcor = Round[Map[Reverse[maskdim[[2 ;; 3]]]*# &, ROI[[All, 1]], {2}]];
  If[Max[ROI[[All, 2]]] > maskdim[[1]], Message[ROIMask::war]];
  ROIslice = Clip[ROI[[All, 2]], {1, maskdim[[1]]}];
  msk = 1 - 
      ImageData[
       Image[Graphics[Polygon[#], 
         PlotRange -> {{0, maskdim[[3]]}, {0, maskdim[[2]]}}], "Bit", 
        ColorSpace -> "Grayscale", 
        ImageSize -> maskdim[[2 ;; 3]]]] & /@ ROIcor;
  MapIndexed[output[[#1]] = msk[[First[#2]]]; &, ROIslice];
  ];
 Return[output];]


(* ::Section:: *)
(*End Package*)


End[]

EndPackage[]
