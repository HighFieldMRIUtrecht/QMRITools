(* ::Package:: *)

(* ::Title:: *)
(*QMRITools MuscleBidsTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["QMRITools`MuscleBidsTools`", Join[{"Developer`"}, Complement[QMRITools`$Contexts, {"QMRITools`MuscleBidsTools`"}]]];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection:: *)
(*Functions*)


ImportJSON::usage = 
"ImportJSON[file] impors a json file as rawJSON."

GetJSONPosition::usage = 
"GetJSONPosition[{json..}, {{key, value}..}] gets the position from a list of JSON association lists where keys have the given value.
GetJSONPosition[{json..}, {{key, value}..}, sortkey] same but finaly sorts the positions for the value of the sortkey."

MergeJSON::usage = 
"MergeJSON[{json..}] merges a list of JSON association lists where duplicate keys with same values are removed and duplicate keys with different values are merges."

AddToJson::usage = 
"AddToJson[json, <|key->value..|>] adds new keys and values to the JSON list where duplicte keys are eitehr removed or joined.
AddToJson[json, \"QMRITools\"] adds the QMRITools software version to the json."


PartitionBidsName::usage = 
"PartitionBidsName[name] converts a Bids name to the a Bids labels as an association, i.e. {\"sub\",\"ses\",\"stk\",\"rep\",\"type\",\"suf\"}."

PartitionBidsFolderName::usage = 
"PartitionBidsFolderName[fol] partitions the Bids folder and file name. it retruns the bids root folder and the label parts using PartitionBidsName."

GenerateBidsName::usage = 
"GenerateBidsName[parts] generates a Bids file name from the Bids labels association which can be generated by PartitionBidsName."

GenerateBidsFileName::usage = 
"GenerateBidsFileName[parts] generates a Bids file name from the Bids labels association which can be generated by PartitionBidsName.
GenerateBidsFileName[fol, parts] the same but with a custom root folder."

SelectBidsFolders::usage =
"SelectBidsFolders[fol, tag] Selects all folders in the fol with the name tag."

SelectBidsSubjects::usage =
"SelectBidsSubjects[fol] selects all subjects in the bids folder"

SelectBidsSessions::usage =
"SelectBidsSessions[fol] selects all sessions in the bids subject folder"


BidsDcmToNii::usage =
"BidsDcmToNii[sourceFolder, rawFolder] converts the bids sourceFolder with dicom files to raw nii files save in the rawFolder. The conversion directory is the current working Directory.
BidsDcmToNii[fol, sourceFolder, rawFolder] the same but the conversion directory is fol."


MuscleBidsConvert::usage =
"MuscleBidsConvert[niiFol, discription] converts all nii data in the niiFol subfolder \"raw\" to Muscle-Bids based on the data discription.

Example discription:
{\"Label\" -> \"DIXON\", \"Type\" -> \"megre\", \"Class\" -> \"Stacks\", \"Overlap\" -> 5}
{\"Label\" -> \"DIXON\", \"Type\" -> \"megre\", \"Class\" -> \"Stacks\"}
{\"Label\" -> \"DTI\", \"Type\" -> \"dwi\", \"Class\" -> \"Stacks\", \"Overlap\" -> 5, \"Suffix\" -> \"dti\"}
{\"Label\" -> \"DIXON\", \"Type\" -> \"megre\"}."


CheckDataDiscription::usage =
"CheckDataDiscription[discription] checks the data discription used in MuscleBidsConvert. For example {\"Label\"->\"DTI\",\"Type\"->\"dwi\",\"Class\"->\"Stacks\",\"Overlap\"->5,\"Suffix\"->\"dti\"},"


(* ::Subsection:: *)
(*Options*)


BidsIncludeSession::usage = 
"BidsIncludeSession is an option for BidsDcmToNii. If True session folders will be used in output even if they are not specified."


DeleteAfterConversion::usage = 
"DeleteAfterConversion is an options for MuscleBidsConvert. If set True all files that have been converted will be deleted."

SelectSubjects::usage = 
"SelectSubjects is an options for MuscleBidsConvert. Can be a list of bids subject names else it is All"


(* ::Subsection:: *)
(*Error Messages*)


Bids::type = "Unknown Muscle-BIDS type: `1`, using folder \"miss\".";

Bids::class = "Unknown Muscle-BIDS Class: `1`. Must be \"Volume\", \"Stacks\", \"Repetitions\"";

Bids::man = "Manditory values \"Lable\" and \"Type\" are not in the data discription.";

Bids::stk = "Class \"stacks\" is used but overlap is not defined, assuming overlap 0.";


(* ::Section:: *)
(*Functions*)


Begin["`Private`"] 


(* ::Subsection:: *)
(*BIDS*)


(* ::Subsubsection::Closed:: *)
(*General Definitions*)


bidsTypes = <|
	(*anata types*)
	"T1w"->"anat","T1w-FS"->"anat","T2w"->"anat","T2w-FS"->"anat",
	(*dixon*)
	"megre"->"dix","mese"->"dix",
	(*quant types*)
	"T1"->"quant","T2"->"quant","wT2"->"quant",
	(*diff types*)
	"dwi"->"dwi"
|>;


bidsName = {"sub","ses","stk","rep","type","suf"};


bidsClass = {"Volume", "Stacks", "Repetitions"};


dataToLog =If[KeyExistsQ[#, $Failed], 
	"Wrong data dicription: " <> #[$Failed], 
	StringJoin[ToString[#[[1]]] <> ": " <> ToString[#[[2]]] <> "; " & /@ Normal[#]]
]&;


(* ::Subsubsection::Closed:: *)
(*PartitionBidsName*)


SyntaxInformation[PartitionBidsName] = {"ArgumentsPattern" -> {_}};

PartitionBidsName[list_?ListQ]:=PartitionBidsName/@list

PartitionBidsName[string_?StringQ]:=Block[{parts,labs,suf},
	parts=StringSplit[#,"-"]&/@StringSplit[string,"_"];
	labs=Rule@@#&/@Select[parts,Length[#]===2&];
	suf=Flatten[Select[parts,Length[#]=!=2&]];
	suf=If[suf=!={},If[MemberQ[Keys[bidsTypes],First@suf],{"type"->First@suf,"suf"->Rest@suf},{"suf"->suf}],{"suf"->{}}];
	Association[Join[labs,suf]]
] 


(* ::Subsubsection::Closed:: *)
(*PartitionBidsFolderName*)


SyntaxInformation[PartitionBidsFolderName] = {"ArgumentsPattern" -> {_}};

PartitionBidsFolderName[fol_?ListQ]:=PartitionBidsFolderName/@fol

PartitionBidsFolderName[fol_?StringQ]:={
	First@StringSplit[fol,"sub-"],PartitionBidsName@StringJoin@Riffle[Select[FileNameSplit[fol],StringContainsQ[#,"-"]&],"_"]
} 


(* ::Subsubsection::Closed:: *)
(*GenerateBidsName*)


SyntaxInformation[GenerateBidsName] = {"ArgumentsPattern" -> {_}};

GenerateBidsName[list_?ListQ]:=GenerateBidsName/@list

GenerateBidsName[parts_?AssociationQ]:=StringJoin[Riffle[Select[Join[
	BidsString[parts,{"sub","ses","stk","rep"}],BidsValue[parts,{"type","suf"}
]],#=!=""&],"_"]]


(* ::Subsubsection::Closed:: *)
(*GenerateBidsFileName*)


SyntaxInformation[GenerateBidsFileName] = {"ArgumentsPattern" -> {_, _.}};

GenerateBidsFileName[list_?ListQ]:=GenerateBidsFileName["",#]&/@list

GenerateBidsFileName[fol_?StringQ, list_?ListQ]:=GenerateBidsFileName[fol,#]&/@list

GenerateBidsFileName[parts_?AssociationQ]:=GenerateBidsFileName["",parts]

GenerateBidsFileName[fol_?StringQ, parts_?AssociationQ]:=FileNameJoin[Select[{
	fol, BidsString[parts,"sub"], BidsString[parts,"ses"], BidsType[parts], GenerateBidsName[parts]
},#1=!=""&]]


(* ::Subsubsection::Closed:: *)
(*GenerateBidsFileName*)


SyntaxInformation[SelectBidsFolders] = {"ArgumentsPattern" -> {_, _}};

SelectBidsFolders[fol_?ListQ, tag_] := Flatten[SelectBidsFolders[#, tag] & /@ fol]
SelectBidsFolders[fol_?StringQ, tag_] := Block[{folSel, done, cont},
	folSel = Select[FileNames[All, fol], (DirectoryQ[#] && (FileBaseName[#] === tag || StringTake[FileBaseName[#], 3] === "sub" || StringTake[FileBaseName[#], 3] === "ses")) &];
	done = Select[folSel, FileBaseName[#] === tag &];
	cont = Complement[folSel, done];
	Flatten[{done, If[cont =!= {}, SelectBidsFolders[cont, tag], Nothing]}]
]


(* ::Subsubsection:: *)
(*SelectBidsSubjects*)


SyntaxInformation[SelectBidsSubjects] = {"ArgumentsPattern" -> {_}};

SelectBidsSubjects[fol_] := Select[FileNames[All, fol], (DirectoryQ[#] && StringTake[FileNameTake[#], 3] === "sub") &]


(* ::Subsubsection:: *)
(*SelectBidsSessions*)


SyntaxInformation[SelectBidsSessions] = {"ArgumentsPattern" -> {_}};

SelectBidsSessions[fol_?ListQ]:=Flatten[SelectBidsSessions/@fol]

SelectBidsSessions[fol_?StringQ] := Select[FileNames[All, fol], (DirectoryQ[#] && StringTake[FileNameTake[#], 3] === "ses") &]


(* ::Subsubsection::Closed:: *)
(*BidsType*)


BidsType[parts_]:=bidsTypes[parts["type"]]/.{Missing[___]->"miss"} 


(* ::Subsubsection::Closed:: *)
(*BidsString*)


BidsString[parts_,val_?ListQ]:=BidsString[parts,#]&/@val

BidsString[parts_,val_?StringQ]:=Block[{str},
	str=parts[val]/.Missing[___]->"";
	If[str==="","",val<>"-"<>str]
]


(* ::Subsubsection::Closed:: *)
(*BidsValue*)


BidsValue[parts_,val_?ListQ]:=Flatten[BidsValue[parts,#]&/@val]

BidsValue[parts_,val_?StringQ]:=parts[val]/.Missing[___]->"" 


(* ::Subsubsection::Closed:: *)
(*CheckBidsTypes*)


CheckBidsTypes[type_]:=If[!MemberQ[Drop[Keys[bidsTypes],-1],type],Message[Bids::type,type]]


(* ::Subsection::Closed:: *)
(*BidsDcmToNii*)


Options[BidsDcmToNii]={BidsIncludeSession->True}

SyntaxInformation[BidsDcmToNii] = {"ArgumentsPattern" -> {_, _, _., OptionsPattern[]}};

BidsDcmToNii[dcmFol_,niiFol_,opts:OptionsPattern[]]:=BidsDcmToNii[Directory[],dcmFol,niiFol,opts]
 
BidsDcmToNii[loc_,dcmFol_,niiFol_,OptionsPattern[]]:=Block[{logFile,fols,folsi,foli,keys,name,ses,bidsname,out},
	(*start logging*)
	ResetLog[];
	ShowLog[];
	logFile=FileNameJoin[{niiFol,"DcmToNii_"<>StringReplace[DateString[{"Day","Month","YearShort","-","Time"}],":"->""]<>".log"}];
	
	(*find all foders that need to be converted*)
	fols=FileNameJoin[{loc, #}]&/@Select[FileNames[All,dcmFol],DirectoryQ];
	
	(*loop over all dcm folders*)
	Table[
		(*----*)AddToLog[{"Converting: ",folsi},True,0];
		(*----*)AddToLog["Using Chris Rorden's dcm2niix.exe (https://github.com/rordenlab/dcm2niix)",0];
		
		(*get the names*)
		foli=PartitionBidsName[FileBaseName[folsi]];
		keys=Keys[foli];
		
		(*if bids take sub key else assume first suf is name*)
		name="sub"->If[MemberQ[keys,"sub"],foli["sub"],First[foli["suf"]]];
		
		(*if bids take ses key else assume last suf is session*)
		ses="ses"->If[MemberQ[keys,"ses"],
			(*session is present take session*)
			First[foli["ses"]],
			(*more than one suf last is session*)
			If[Length[foli["suf"]]>1,Last[foli["suf"]],
				(*no session, see if need to be forced*)
				If[OptionValue[BidsIncludeSession],"001",""]
			]
		];
		(*create the output with the bidsname to which all is exported*)
		bidsname=GenerateBidsFileName[Association[{name,ses}]];
		out=FileNameJoin[{StringReplace[DirectoryName[folsi],{dcmFol->niiFol}],DirectoryName[DirectoryName[bidsname]],"raw"}];
		(*----*)AddToLog[{"Output folder: ",out},1];
		Quiet[CreateDirectory[out]];
		
		(*perform the conversions only when output folder is empty*)
		If[EmptyDirectoryQ[out],
			DcmToNii[{folsi,out}];
			(*----*)AddToLog["Folder was converted",1],
			(*----*)AddToLog["Folder was skipped since output folder already exists",1];
		];
		
	(*Close loop over folders*)	
	,{folsi,fols}];
	
	(*export the log file*)
	ExportLog[logFile,True];
]


(* ::Subsection:: *)
(*MuscleBidsConvert*)


(* ::Subsubsection:: *)
(*MuscleBidsConvert*)


Options[MuscleBidsConvert] = {DeleteAfterConversion->False, SelectSubjects->All};

SyntaxInformation[MuscleBidsConvert] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

MuscleBidsConvert[niiFol_?StringQ, datDis_,ops:OptionsPattern[]]:=Block[{datType,fols,subs,logFile,fol,nam,filesSl,jsons,files,nTyp,pat,ass,rfol},
	(*convert the nameType to valid input*)
	datType=CheckDataDiscription[datDis];
	datType=If[AssociationQ[datType],{datType},datType];
	
	(*slect the subjects to be processed*)
	fols = SelectBidsSubjects[niiFol];
	subs = OptionValue[SelectSubjects];
	subs = If[subs===All,
		fols,
		Select[fols,MemberQ[subs,PartitionBidsFolderName[#][[-1]]["sub"]]&]
	];
	
	(*open log*)
	ShowLog[];
	
	(*loop over the subjects*)
	Table[
		(*start logging*)
		logFile = FileNameJoin[{fol,"BIDSConvert.log"}];
		Print[logFile];
		ImportLog[logFile];
		(*----*)AddToLog[{"Starting bids conversion for directory: ", fol},True,0];
		(*----*)AddToLog["Perform conversion for: ",1];
		
		(*loop over the datType*)
		Table[
			(*check if datType is valid*)
			If[KeyExistsQ[ass,$Failed],
			(*----*)AddToLog[dataToLog@ass,2,True];
			(*----*)AddToLog["Skipping",3],
			(*if valid perform conversion*)
			(*----*)AddToLog[dataToLog@ass,2,True];
			rfol=SelectBidsFolders[fol,ass["InFolder"]];
			
			(*loop over all inFolders in subject folder*)
			Table[
				(*----*)AddToLog[{"Finding all JSON files in the directory",foli},2];
				files=FileNames["*.json",foli];
				(*----*)AddToLog[{"There were",Length[files]," JSON files found"},3];
				
				(*select the files to process*)
				nam=ass["Label"];
				pat=Switch[ass["Class"],
				"Volume",__~~nam~~__,
				"Stacks"|"Repetitions",__~~nam~~DigitCharacter..~~__
				];
				filesSl=Select[files,StringContainsQ[#,pat]&];
				(*----*)AddToLog[{"Importing",Length[filesSl],"JSON files containing",nam, "that are part of class",ass["Class"]},4];
				jsons=ImportJSON/@filesSl;
				
				(*perform the conversions*)
				MuscleBidsConvertI[foli, filesSl, jsons, ass, OptionValue[DeleteAfterConversion]]
			
			(*Close sub folders loop*)
			,{foli,rfol}]
	
		(*close datatype loop*)
		],{ass,datType}];
		
		(*export the log files*)
		ExportLog[logFile,True];
	
	(*close subject loop*)
	,{fol,subs}];
] 


(* ::Subsubsection:: *)
(*CheckDataDiscription*)


SyntaxInformation[CheckDataDiscription] = {"ArgumentsPattern" -> {_}};

CheckDataDiscription[dis:{_List..}]:=CheckDataDiscription/@dis

CheckDataDiscription[dis:{_Rule..}]:=Block[{ass,key,man,typ, fail},
	(*Get the data discription keys*)
	ass=Association[dis];
	key=Keys[ass];
	
	(*fail output*)
	fail = Association[$Failed->ToString[Normal[ass]]];
	
	(*Check if manditory keys are present*)
	man=ContainsAll[key,{"Label","Type"}];
	If[!man,
		Return[Message[Bids::man];fail],
		
		(*Check if type is valid*)
		If[!MemberQ[Keys[bidsTypes],ass["Type"]], Message[Bids::type,ass["Type"]]];
		(*Check if class is present*)
		If[KeyExistsQ[ass,"Class"],
			(*if present add check class is vlid*)
			If[!MemberQ[bidsClass,ass["Class"]],Return[Message[Bids::class,ass["Class"]];fail]],
			(*add class if not present*)
			ass=Association[ass,"Class"->"Volume"]
		];
		
		(*check suffic, in and out folder*)
		If[!KeyExistsQ[ass,"Suffix"],ass=Association[ass,"Suffix"->""]];
		If[!KeyExistsQ[ass,"InFolder"],ass=Association[ass,"InFolder"->"raw"]];
		ass=Association[ass,"OutFolder"->(bidsTypes[ass["Type"]]/. {Missing[___]->"miss"})];
		
		(*add overlap if class is stacks*)
		If[ass["Class"]==="Stacks"&&!KeyExistsQ[ass,"Overlap"],Message[Bids::stk];ass=Association[ass,"Overlap"->0]];
		
		ass
	]
]


(* ::Subsubsection:: *)
(*MuscleBidsConvertI*)


MuscleBidsConvertI[foli_,files_,json_,datType_,del_]:=Block[{
		name,nType,type,suf,fol,parts,names,nr, infoExtra,
		namei,dixType,pos,info,data,vox,grad,val,sufd,outFile
	},
	
	(*see if one label or session|repetion*)
	{name,nType,type,suf}=datType/@{"Label","Class","Type","Suffix"};
	{fol,parts}=PartitionBidsFolderName[foli];
	
	names=If[nType==="Volume",{name},GetStackLabels[json,name]];
	(*-----*)AddToLog[{"Found",ToString[Length[names]],nType,"with the label","\""<>name<>"\""},3];
	
	(*skip if nothing found*)
	If[names==={},
		(*-----*)AddToLog["No data found skipping processing",3],
		(*-----*)AddToLog[StringJoin@@Riffle[names,", "],4];
		
		(*switch to bids data type*)
		(*loop over stac names*)
		Table[
			(*-----*)AddToLog[{"Processing:",namei},True,4];
			nr=GetStackNr[nType,namei];
			
			(*see which data type is expected*)
			Switch[type,
				(*---------- DIXON -----------*)
				"megre",
				
				(*loop over dixon data types*)
				Table[
					(*get the posisiton of the files needed*)
					pos=GetJSONPosition[json,{{"SeriesDescription",namei},{"ImageType",dixType}},"EchoNumber"];
					(*-----*)AddToLog[{"Importing",Length[pos],type,"datasets with properties: ",{namei, dixType}},5];
					
					(*get the json and data*)
					info=ii=MergeJSON[json[[pos]]];
					{data,vox}=Transpose[ImportNii[#]&/@ConvertExtension[files[[pos]],".nii"]];
					data=Transpose[data];
					vox=First@vox;
					(*-----*)AddToLog[{"Dimensions:",Dimensions@data,"; Voxel size:",vox},5];
					
					(*correct data for different types*)
					{data,sufd}=Switch[dixType,
						"Mixed",{1000.data/2047.,""},
						"Phase",{Pi (data-2047.)/2047,"ph"},
						"Real",{1000.(data-2047.)/2047.,"real"},
						"Imaginary",{1000.(data-2047.)/2047.,"imag"}
					];
					
					(*make the additional manditory bids json values*)
					infoExtra=<|
						"ForthDimension"->"EchoTime",
						"DataClass"->datType["Class"],
						If[datType["Class"]==="Repetitions","RepetitionNummer"->ToExpression[Last@nr],Nothing],
						If[datType["Class"]==="Stacks","StackNummer"->ToExpression[Last@nr],Nothing],
						If[datType["Class"]==="Stacks","OverLap"->datType["Overlap"],Nothing]
					|>;
					
					(*export to the correct folder*)
					outFile=GenerateBidsFileName[fol,<|parts,"type"->type,GetStackNr[nType,namei],"suf"->Flatten@{suf,sufd}|>];
					(*-----*)AddToLog[{"Exporting to file:",outFile},5];
					ExportNii[data,vox,ConvertExtension[outFile,".nii"]];
					Export[ConvertExtension[outFile,".json"],AddToJson[AddToJson[info,"QMRITools"],infoExtra]];
					
					(*Delete used files*)
					If[del,
						(*-----*)AddToLog[{"Deleting",Length[pos],type,"datasets with properties: ",{namei, dixType}},5];
						Quiet@DeleteFile[ConvertExtension[files[[pos]],".nii"]];
						Quiet@DeleteFile[ConvertExtension[files[[pos]],".nii.gz"]];
						DeleteFile[ConvertExtension[files[[pos]],".json"]]
					];
				
				(*Closeloop over dixon data types*)
				,{dixType,{"Mixed","Phase","Real","Imaginary"}}],
				
				(*---------- DWI -----------*)
				"dwi",
				
				(*get the posisiton of the files needed*)
				pos=GetJSONPosition[json,{{"SeriesDescription",namei}}];
				(*-----*)AddToLog[{"Importing ",Length[pos],type,"dataset with properties: ",namei},5];
				
				(*get the json and data*)
				info = json[[First@pos]];
				{data,grad,val,vox}=ImportNiiDiff[ConvertExtension[files[[First@pos]],".nii"],FlipBvec->False];
				(*-----*)AddToLog[{"Dimensions:",Dimensions@data,"; Voxel size:",vox},5];
				
				(*export to the correct folder*)
				outFile=GenerateBidsFileName[fol,<|parts,"type"->type,GetStackNr[nType,namei],"suf"->{suf}|>];
				(*-----*)AddToLog[{"Exporting to file:",outFile},5];
				ExportBval[val,ConvertExtension[outFile,".bval"]];
				ExportBvec[grad,ConvertExtension[outFile,".bvec"]];
				ExportNii[data,vox,ConvertExtension[outFile,".nii"]];
				Export[ConvertExtension[outFile,".json"],AddToJson[info,"QMRITools"]];
				
				If[del,
					(*-----*)AddToLog[{"Deleting",Length[pos],type,"dataset with properties: ",namei},5];
					Quiet@DeleteFile[ConvertExtension[files[[pos]],".nii"]];
					Quiet@DeleteFile[ConvertExtension[files[[pos]],".nii.gz"]];
					DeleteFile[ConvertExtension[files[[pos]],".json"]];
					DeleteFile[ConvertExtension[files[[pos]],".bval"]];
					DeleteFile[ConvertExtension[files[[pos]],".bvec"]];
				],
				(*---------- T2 -----------*)
				"T2",
				Print["Not done yet"],
				
				(*---------- Other -----------*)
				_,Print["Unknow type for conversion"];
			
			(*Close Type switch*)
			];
		(*close loop over stac names*)
		,{namei,names}];
	]
] 


(* ::Subsubsection:: *)
(*GetStackLabels*)


GetStackLabels[{},name_]:={};
GetStackLabels[jsons:{_?AssociationQ..},name_]:=Sort@DeleteDuplicates@Flatten@StringCases[
	#["SeriesDescription"]&/@jsons,name~~num:DigitCharacter..:>name<>num]


(* ::Subsubsection:: *)
(*GetStackNr*)


GetStackNr[nType_,namei_]:=Switch[nType,
	"Volume","",
	"Stacks"|"Repetition",
	Switch[nType,"Stacks","stk","Repetition","rep"]->StringPadInteger[ToExpression@First@StringCases[namei,__~~num:DigitCharacter..:>num]]
]


(* ::Subsection:: *)
(*JSON*)


(* ::Subsubsection:: *)
(*ImportJSON*)


ImportJSON[file_]:=Import[file,"RawJSON"]


(* ::Subsubsection:: *)
(*GetJSONPosition*)


GetJSONPosition[json_,selection_]:=GetJSONPosition[json,selection,""]

GetJSONPosition[json_,selection_,sort_]:=Block[{seli,self,list,key,val,inds,pos},
	seli = ToLowerCase[Last[Flatten[{#1/.#3}]]]===ToLowerCase[#2]&;
	self = (list=#1;key=#2[[1]];val=#2[[2]];Select[list,seli[key,val,json[[#]]]&])&;
	inds = Range[Length[json]];
	pos = Fold[self,inds,selection];
	If[sort==="", pos, pos[[Ordering[sort/.json[[pos]]]]]]
]


(* ::Subsubsection:: *)
(*MergeJSON*)


MergeJSON[json:{_?AssociationQ..}]:=Block[{keys},
	keys=DeleteDuplicates[Flatten[Keys/@json]];
	Association[If[#[[2]]==={},Nothing,#]&/@Thread[
		keys->(If[Length[#]===1,First@#,#]&/@(
		(DeleteDuplicates/@Transpose[(#/@keys)&/@json])/.Missing[___]->Nothing))]
	]
]



(* ::Subsubsection:: *)
(*AddToJson*)


AddToJson[json_, add_]:=MergeJSON[{json,
	Switch[add,
		"QMRITools",<|"ConversionSoftware"->"QMRITools.com","ConversionSoftwareVersion"->QMRITools`$InstalledVersion|>,
		_,add]}
]


(* ::Section:: *)
(*End Package*)


End[]

EndPackage[]