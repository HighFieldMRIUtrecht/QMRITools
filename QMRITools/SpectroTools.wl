(* ::Package:: *)

(* ::Title:: *)
(*QMRITools SpectroTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["QMRITools`SpectroTools`", Join[{"Developer`"}, Complement[QMRITools`$Contexts, {"QMRITools`SpectroTools`"}]]];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection:: *)
(*Functions*)


(* ::Subsection:: *)
(*Options*)


(* ::Subsection:: *)
(*Error Messages*)


(* ::Section:: *)
(*Functions*)


Begin["`Private`"] 


(* ::Subsection:: *)
(*CalculateWaveVector*)


(* ::Section:: *)
(*End Package*)


End[]

EndPackage[]


(* ::Subsection:: *)
(*Spectra Functions*)


(* ::Subsubsection:: *)
(*Spectra Fitting*)


(* ::Input:: *)
(*Clear[FitBasisSpectraI]*)
(*Options[FitBasisSpectraI]={Output->"Error",MaxIterations->3,SpectraMetaboliteBaseline->0};*)
(*FitBasisSpectraI[{ppmFull_,timeFull_,timeBasis_},{ppmY_,specY_},{indSt_,indEnd_},{cpn_,gyro_},*)
(*{gam_?NumericQ,eps_?NumericQ,phi0_?NumericQ,phi1_?NumericQ,gamm_?NumericQ},OptionsPattern[]]:=Block[{*)
(*ppm,specF,specBasisF,metBasis,basis,fit,specFit,spline,error*)
(*},*)
(**)
(*(*generate basis spectra from time domain*)*)
(*metBasis=OptionValue[SpectraMetaboliteBaseline];*)
(*specBasisF=If[metBasis===0,*)
(*(*no metabolite base line*)*)
(*Transpose[(ShiftedFourier[SpectraTimeShift[timeFull,#,gyro,{gam,eps}]]&/@timeBasis)[[All,indSt;;indEnd]]]*)
(*,*)
(*(*with metabolite base line, done perform line broadning metabolites.*)*)
(*Transpose[Join[*)
(*(ShiftedFourier[SpectraTimeShift[timeFull,#,gyro,{gam,eps}]]&/@timeBasis)[[All,indSt;;indEnd]],*)
(*{ShiftedFourier[SpectraTimeShift[timeFull,metBasis,gyro,{gamm,eps}]][[indSt;;indEnd]]}*)
(*]]*)
(*];*)
(**)
(*basis=Re[specBasisF];*)
(*spline=0.specF;*)
(**)
(*(*apply phase to target in stead of basis functions (faster)*)*)
(*specF=SpectraPhaseShift[ppmY,specY,{-phi0,-phi1}];*)
(**)
(*(*allow for itterative LLS fitting*)*)
(*Do[*)
(*(*perform Fit of basis spectra*)*)
(*fit=NNLeastSquares[basis,Re[specF-spline]];*)
(*specFit=specBasisF.fit;*)
(*(*perform the b-spline fit on the residuals*)*)
(*spline=BSplineCurveFit[specF-specFit,SplineKnotsNumber-> cpn,SplineDegree-> 2,SplineRegularization->0];*)
(*,{OptionValue[MaxIterations]}];*)
(**)
(*(*give ouput*)*)
(*Switch[OptionValue[Output],*)
(*(*output error of fit*)*)
(*"Error",*)
(*error=specF-specFit-spline;*)
(*Total[(Re[error])^2+(Im[error])^2],*)
(**)
(*(*ouput the fit results*)*)
(*"Fit",*)
(*(*apply phase to the basis spectra and spline*)*)
(*spline=SpectraPhaseShift[ppmY,spline,{phi0,phi1}];*)
(*specBasisF=Transpose[SpectraPhaseShift[ppmY,#,{phi0,phi1}]&/@Transpose[specBasisF]];*)
(*specFit=specBasisF.fit;*)
(*{specFit,spline,fit,specBasisF}*)
(*]*)
(*]*)
(**)
(*Clear[FitSpectra]*)
(*Options[FitSpectra]={*)
(*SpectraNucleus->"1H",SpectraPPMShift->4.65,SpectraFieldStrength->7,*)
(*SpectraPaddingFactor->1,SpectraSplineSpacingFactor->.75,MaxIterations->3,*)
(*SpectraMetaboliteBaseline->0*)
(*};*)
(*FitSpectra[specBasisIn_,specIn_,{st_,end_},dtime_,{lwvals_,lwamsp_},OptionsPattern[]]:=Block[{*)
(*t1,pad,spfac, specYFull,field,nuc,shift,*)
(*timeBasis,metBasis,timeFull,ppmFull,nsamp,ppmFr,*)
(*indSt,indEnd,specY,times,ppms,*)
(*specYP,phi0i,phi1i,gamf,epsf,phi0f,phi1f,*)
(*lw,epsi,splineSpace,gami,cpn,gamm,gammf,*)
(*gam,eps,gam1,eps1,phi0,phi1,full,tar,par,ran,err,sol,*)
(*specFit,spline,specBasisF,fit,output,log*)
(*},*)
(**)
(*(*logging*)*)
(*log={};*)
(*PrintTemporary[Dynamic[Column[log]]];*)
(**)
(*pad=OptionValue[SpectraPaddingFactor]+1;*)
(*metBasis=OptionValue[SpectraMetaboliteBaseline];*)
(*spfac=OptionValue[SpectraSplineSpacingFactor];*)
(*field= OptionValue[SpectraFieldStrength];*)
(*nuc =OptionValue[SpectraNucleus] ;*)
(*shift = OptionValue[SpectraPPMShift];*)
(**)
(*(*time the fitting*)*)
(*t1=AbsoluteTiming[*)
(**)
(*(*-------------------------------------------------------------------*)*)
(*(*pad the spectra and get the time and ppm axes*)*)
(*specYFull=ShiftedFourier[PadRight[ShiftedInverseFourier[specIn],pad Length[specIn]]];*)
(*{timeFull,ppmFull,{nsamp,ppmFr}}=GetTimePPMRange[specYFull,dtime,field,nuc,shift];*)
(*(*get the basis spectra*)*)
(*timeBasis=PadRight[ShiftedInverseFourier[#],pad Length[#]]&/@specBasisIn;*)
(*(*check if a metabolite baseline is used and pad*)*)
(*If[metBasis=!=0,metBasis=PadRight[ShiftedInverseFourier[metBasis],pad Length[metBasis]]];*)
(**)
(*(*-------------------------------------------------------------------*)*)
(*(*find the positions of the fit range*)*)
(*{indSt,indEnd}=Flatten[Position[ppmFull,Nearest[ppmFull,#][[1]]]&/@{st,end}];*)
(*(*get the fit rance data*)*)
(*specY=specYFull[[indSt;;indEnd]];*)
(*times=timeFull[[indSt;;indEnd]];*)
(*ppms=ppmFull[[indSt;;indEnd]];*)
(*(*logging of input parameters*)*)
(*AppendTo[log,Style["Spectral Properties",Bold]];*)
(**)
(*AppendTo[log,"    - Number of samples:          "<>ToString[nsamp]];*)
(*AppendTo[log,"    - Gyro magnetic ratio:        "<>ToString[ppmFr]<>" Hz"];*)
(*AppendTo[log,"    - Number of fit samples:      "<>ToString[indEnd-indSt+1]];*)
(*AppendTo[log,""];*)
(**)
(*(*-------------------------------------------------------------------*)*)
(*(*find initial linewidth and spec shift*)*)
(*AppendTo[log,Style["Estimating linewidth",Bold]];*)
(*{lw,epsi}=EstimateLineWidth[ppmFull,specYFull,{lwvals,lwamsp}];*)
(*gami=ppmFr lw;*)
(*(*logging of parameters*)*)
(*AppendTo[log,"    - spectral linewidth intit:   "<>ToString[gami /ppmFr]<>" ppm"];*)
(*AppendTo[log,"                                  "<>ToString[gami]<>" Hz"];*)
(*AppendTo[log,"    - base spectra shift:         "<>ToString[epsi]<>" ppm"];*)
(*AppendTo[log,"                                  "<>ToString[epsi ppmFr]<>" Hz"];*)
(*AppendTo[log,""];*)
(**)
(*(*-------------------------------------------------------------------*)*)
(*(*find initial phase estimate*)*)
(*AppendTo[log,Style["Estimating phase correction",Bold]];*)
(*{phi0i,phi1i}=EstimatePhaseShift[{ppmFull,specYFull},{timeFull,timeBasis},{gami,epsi},ppmFr];*)
(*(*logging of parameters*)*)
(*AppendTo[log,"    - zeroth order phase:         "<>ToString[phi0i]<>" rad"];*)
(*AppendTo[log,"                                  "<>ToString[phi0i/Degree]<>" deg"];*)
(*AppendTo[log,"    - first order phase:          "<>ToString[phi1i]<>" rad/ppm"];*)
(*AppendTo[log,"                                  "<>ToString[phi1i/Degree]<>" deg/ppm"];*)
(*AppendTo[log,""];*)
(**)
(*(*-------------------------------------------------------------------*)*)
(*(*get the spline basis fucntion paramters*)*)
(*AppendTo[log,Style["Estimating spline smoothness",Bold]];*)
(*splineSpace=spfac lw;*)
(*cpn = Round[Subtract@@Reverse[MinMax[ppms]]/splineSpace];*)
(*AppendTo[log,"    - spline spacing:             "<>ToString[splineSpace]<>" ppm"];*)
(*AppendTo[log,"    - spline control points:      "<>ToString[cpn]];*)
(*AppendTo[log,""];*)
(**)
(*(*-------------------------------------------------------------------*)*)
(*(*perform the fitting*)*)
(*AppendTo[log,Style["Performing spectra fitting",Bold]];*)
(*(*get the input for the fit*)*)
(*full={ppmFull,timeFull,timeBasis};*)
(*tar={ppms,specY};*)
(*ran={indSt,indEnd};*)
(*par={cpn,ppmFr};*)
(**)
(*(*perform the minimization*)*)
(*If[metBasis===0,*)
(*fit=FindMinimum[{*)
(*FitBasisSpectraI[full,tar,ran,par,{gamf,epsf,phi0f,phi1f,0},Output->"Error",MaxIterations->OptionValue[MaxIterations]]*)
(*,0.5gami<gamf<2gami,epsi-.5<epsf<epsi+.5,-2Pi<phi0f<2Pi,-2Pi<phi1f<2Pi}*)
(*,{gamf,gami},{epsf,epsi},{phi0f,phi0i},{phi1f,phi1i},*)
(*MaxIterations->25][[2]];*)
(*(*get the solution and output*)*)
(*sol={gam,eps,phi0,phi1,gamm}={gamf,epsf,2ArcTan[Tan[0.5phi0f]],2ArcTan[Tan[0.5phi1f]],0}/.fit;*)
(*output=FitBasisSpectraI[full,tar,ran,par,sol,Output->"Fit",MaxIterations->OptionValue[MaxIterations]];*)
(*,*)
(*fit=FindMinimum[{*)
(*FitBasisSpectraI[full,tar,ran,par,{gamf,epsf,phi0f,phi1f,gammf},Output->"Error",MaxIterations->OptionValue[MaxIterations],SpectraMetaboliteBaseline->metBasis]*)
(*,0.5gami<gamf<2gami,epsi-.5<epsf<epsi+.5,-2Pi<phi0f<2Pi,-2Pi<phi1f<2Pi,0<gammf<.5gami}*)
(*,{gamf,gami},{epsf,epsi},{phi0f,0},{phi0f,phi0i},{phi1f,phi1i},*)
(*MaxIterations->25][[2]];*)
(*(*get the solution and output*)*)
(*sol={gam,eps,phi0,phi1,gamm}={gamf,epsf,2ArcTan[Tan[0.5phi0f]],2ArcTan[Tan[0.5phi1f]],gammf}/.fit;*)
(*output=FitBasisSpectraI[full,tar,ran,par,sol,Output->"Fit",MaxIterations->OptionValue[MaxIterations],SpectraMetaboliteBaseline->metBasis];*)
(*];*)
(**)
(*(*logging*)*)
(*AppendTo[log,"    - spectral linewidth:         "<>ToString[gam/ppmFr]<>" ppm"];*)
(*AppendTo[log,"                                  "<>ToString[gam]<>" Hz"];*)
(*AppendTo[log,"    - base spectra shift:         "<>ToString[eps]<>" ppm"];*)
(*AppendTo[log,"                                  "<>ToString[eps ppmFr]<>" Hz"];*)
(*AppendTo[log,"    - zeroth order phase:         "<>ToString[phi0]<>" rad"];*)
(*AppendTo[log,"                                  "<>ToString[phi0/Degree]<>" deg"];*)
(*AppendTo[log,"    - first order phase:          "<>ToString[phi1]<>" rad/s"];*)
(*AppendTo[log,"                                  "<>ToString[phi1/Degree]<>" deg/s"];*)
(*][[1]];*)
(**)
(*(*log the computation time*)*)
(*AppendTo[log,""];*)
(*AppendTo[log,"Total computation time: "<>ToString[t1]<>" s"];*)
(**)
(*(*Print[Column[log]];*)*)
(**)
(*(*give the output*)*)
(*{output,{ppms,specY},sol,log}*)
(*]*)


(* ::Subsubsection::Closed:: *)
(*Ordering raw data*)


(* ::Input:: *)
(*(*Mean over list of values*)*)
(*MeanType[list_,type_,posS_List]:=Fold[MeanType,{list,type},posS]*)
(*(*Mean such that output and input match*)*)
(*MeanType[{list_,type_},posS_String]:=MeanType[list,type,posS]*)
(*(*single evaluation of mean*)*)
(*MeanType[list_,type_,posS_String]:=Block[{pos},*)
(*(*Print[type];*)*)
(*pos=posS/.Thread[type->Range[Length[type]]];*)
(*(*Print["mean over: ",posS," (",pos")"];*)*)
(*If[IntegerQ[pos],{MeanAt[list,pos],Drop[type,{pos}]},$Failed]*)
(*]*)
(**)
(*(*calculate mean at specific level*)*)
(*MeanAt[list_,level_]:=Total[list,{level}]/Dimensions[list][[level]]/;1<=Abs[level]<=ArrayDepth@list*)
(**)
(*(*put kspace in requested order*)*)
(*OrderKspace[kspace_,type_,order_]:=OrderKspace[{kspace,type},order]*)
(*OrderKspace[{kspace_,type_},order_]:=Block[{mis},*)
(*mis=If[!MemberQ[type,#],#,Nothing]&/@order;*)
(*If[mis==={},*)
(*{Transpose[kspace,Flatten[(Position[order,#1]&)/@type]],order},*)
(*Print["the types ",mis," are missing"]*)
(*]]*)
(**)
(*SagitalTranspose[data_]:=(Reverse[Transpose[#1],2]&)/@data;*)


(* ::Subsubsection::Closed:: *)
(*Fourier Functions*)


(* ::Input:: *)
(*(*shift a dataset with specific shifts*)*)
(*ShiftData[data_,shift_]:=RotateRight[data,Reverse[shift]];*)
(*(*shift data*)*)
(*FourierShift[data_]:=RotateRight[data,Floor[Dimensions[data]/2]];*)
(*InverseFourierShift[data_]:=RotateLeft[data,Floor[Dimensions[data]/2]];*)
(*(*perform shifted fourier*)*)
(*ShiftedFourier[time_]:=FourierShift[Fourier[time,FourierParameters->{-1, 1}]];*)
(*FourierShifted[time_]:=Fourier[FourierShift[time],FourierParameters->{-1, 1}];*)
(*ShiftedInverseFourier[spec_]:=InverseFourier[InverseFourierShift[spec],FourierParameters->{-1, 1}];*)


(* ::Subsubsection::Closed:: *)
(*Spectra fourier recon*)


(* ::Input:: *)
(*FourierKspace2D[kspace_,head_]:=Block[{ksPad,dim,imPad,shift,kspaceP,imData},*)
(*(*get the oversampling padding*)*)
(*ksPad=Round[({"Y-resolution","X-resolution"}{"ky_oversample_factor","kx_oversample_factor"}-{"N_ky","N_samp"})/2/.head];*)
(*(*get the final data dimentions*)*)
(*dim={"number_of_locations","Y-resolution","X-resolution"}/.head;*)
(*(*pad the kaspaces with zeros*)*)
(*kspaceP=ArrayPad[#,Transpose@{ksPad,ksPad},0.+0.I]&/@kspace;*)
(*(*get the image padding and image shift*)*)
(*imPad=-(Dimensions[kspaceP]-dim)/2;*)
(*shift=Total[#]&/@({"Y_range","X_range"}/.head);*)
(*(*perform the fourie transform*)*)
(*imData=ArrayPad[ShiftData[FourierShifted[#],shift]&/@kspaceP,Transpose[{imPad,imPad}]]*)
(*]*)
(**)
(**)
(*FourierKspaceCSI[kspace_,head_]:=Block[{ksPad,dim,imPad,shift,kspaceP,imData},*)
(*(*get the oversampling padding*)*)
(*ksPad=Round[({"Z-resolution","Y-resolution","X-resolution"}{"kz_oversample_factor","ky_oversample_factor","kx_oversample_factor"}-{"N_kz","N_ky","N_kx"})/2/.head];*)
(*(*get the final data dimentions*)*)
(*dim={"Z-resolution","Y-resolution","X-resolution"}/.head;*)
(*(*pad the kaspaces with zeros*)*)
(*kspaceP=ArrayPad[#,Transpose@{ksPad,ksPad},0.+0.I]&/@kspace;*)
(*(*get the image padding and image shift*)*)
(*shift=Total[#]&/@({"Z_range","Y_range","X_range"}/.head);*)
(*(*perform the fourie transform*)*)
(*imData=ShiftData[FourierShift[FourierShifted[#]],shift]&/@kspaceP*)
(*]*)


(* ::Subsubsection::Closed:: *)
(*Spectra data Reconstruction*)


(* ::Input:: *)
(*CoilWeightedReconCSI[kspace_,noisei_,head_]:=Block[{CSI,noise,CSIsos,weightsCSI,sMatC,nMatC,csiMat,dMat,CSIcc,spectra},*)
(**)
(*Switch[ArrayDepth[kspace],*)
(*4,*)
(*CSIcc=TransData[FourierKspaceCSI[kspace,head],"l"];*)
(*,5,*)
(*(*perform spatial fourier for CSI*)*)
(*CSI=FourierKspaceCSI[#,head]&/@kspace;*)
(**)
(*(*perfrom normalization*)*)
(*CSI=Transpose[CSI];*)
(*noise=noisei;*)
(**)
(*(*get weights*)*)
(*CSIsos=SumOfSquares[Total@Abs@CSI,OutputWeights->False];*)
(*weightsCSI=#/CSIsos&/@CSI[[1]];*)
(**)
(*(*perform weightd reconstruction*)*)
(*sMatC=TransData[weightsCSI,"l"];*)
(*nMatC=Inverse[NoiseCovariance[noise]];*)
(*csiMat=TransData[CSI,"l"];*)
(**)
(*dMat=TransData[TransData[Transpose[CSI],"l"],"l"];*)
(*CSIcc=MapThread[Conjugate[#1].nMatC.#2&,{sMatC,dMat},3];*)
(*];*)
(*(*Perform spectral Fourier*)*)
(*spectra=Map[FourierShift[Fourier[#,FourierParameters->{-1, 1}]]&,CSIcc,{-2}];*)
(*(*Normalize spectra*)*)
(*spectra=1000.spectra/Max[Abs[spectra]];*)
(*(*phase align spectra*)*)
(*(*spectra=ParallelMap[PhaseAlign[#]&,spectra,{3}];*)*)
(**)
(*{spectra,TransData[CSIcc,"r"]}*)
(*]*)
(**)
(*CoilWeightedRecon[kspace_,noise_,head_,shift_:0]:=Block[{compData,meanData,weights,weightsF,sMat,nMat,dMat,recon},*)
(*(*make Image Data*)*)
(*compData=Map[FourierKspace2D[#,head]&,kspace,{-4}];*)
(*(*shift the echos to center if needed*)*)
(*If[shift=!=0,*)
(*compData=Table[If[EvenQ[i],*)
(*RotateRight[compData[[i]],{0,0,0,shift[[1]]}],*)
(*RotateLeft[compData[[i]],{0,0,0,shift[[2]]}]*)
(*],{i,1,Length[compData]}];*)
(*];*)
(**)
(*(*calculate mean signal and complex coil weights*)*)
(*Switch[ArrayDepth[compData],*)
(*4,*)
(*(*Calculate the mean abs signal and determine the weights*)*)
(*meanData=SumOfSquares[Abs@compData,OutputWeights->False];*)
(*weights=Map[#/meanData&,compData];*)
(*,5,*)
(*(*Calculate the mean abs signal of the first echo and determine the weights*)*)
(*meanData=SumOfSquares[Abs@compData[[1]],OutputWeights->False];*)
(*weights=Map[#/meanData&,compData[[1]]];*)
(*];*)
(**)
(*(*filter weights*)*)
(*weightsF=Map[MedianFilter[Re[#],1]+I MedianFilter[Im[#],1]&,weights,{2}];*)
(**)
(*(*perform reconstruction*)*)
(*sMat=TransData[weightsF,"l"];*)
(*nMat=Inverse[NoiseCovariance[noise]];*)
(*recon=Switch[ArrayDepth[compData],*)
(*4,*)
(*dMat=TransData[compData,"l"];*)
(*MapThread[Conjugate[#1].nMat.#2&,{sMat,dMat},3]*)
(*,5,*)
(*Transpose[( *)
(*dMat=TransData[#,"l"];*)
(*MapThread[Conjugate[#1].nMat.#2&,{sMat,dMat},3]*)
(*)&/@compData]*)
(*];*)
(**)
(*(*scale to proper values*)*)
(*recon=1000.recon/Max[Abs[recon]];*)
(**)
(*#[recon]&/@{Abs,Arg,Re,Im}*)
(*]*)


(* ::Input:: *)
(*MakeSpectraGrid[spectra_,sc_:0.025]:=Block[{spectraF,max,plots,speci},*)
(*spectraF=ParallelMap[GaussianFilter[Abs[#],2]&,spectra,{-2}];*)
(*max=Max[spectraF];*)
(**)
(*plots=ParallelMap[*)
(*( *)
(*speci=#-Min[#];*)
(*If[Max[#]>sc max,*)
(*ListLinePlot[speci,PlotRange->{0,0.5max},Axes->False,ImageSize->50,AspectRatio->1,PlotStyle->Directive[{Thick,Darker@Green}],PerformanceGoal->"Quality"]*)
(*,*)
(*ListLinePlot[speci,PlotRange->{0,0.5max},Axes->False,ImageSize->50,AspectRatio->1,PlotStyle->Directive[{Thick,Darker@Red}],PerformanceGoal->"Speed"]*)
(*]*)
(*)&,spectraF,{-2}];*)
(*Grid[#,Spacings->0]&/@plots*)
(*]*)


(* ::Subsubsection::Closed:: *)
(*Read List Data*)


(* ::Input:: *)
(*ReadListData[file_]:=Block[{*)
(*fl,head,list,data,lab,dataIndex,dataVals,dataValsN,ruleKx,ruleKy,ruleKz,ruleCoil,*)
(*typ,pos,dataSplit,indexSplit, echo,*)
(*sizeInd,size,ind,off,noise,indData,nSamp,kspace,line,types,outData,outHead},*)
(**)
(*fl=StringReplace[file,{".list"->"",".data"->""}];*)
(*If[!FileExistsQ[fl<>".list"]||!FileExistsQ[fl<>".data"],Print["files not found"]];*)
(**)
(*(*read the data - longest part*)*)
(*list=ReadList[fl<>".list",String];*)
(*data=BinaryReadList[fl<>".data","Complex64"];*)
(**)
(*(*Get the header*)*)
(*head=StringSplit/@Select[list,StringTake[#,1]==="."&];*)
(*head=Thread[head[[All,5]]->ToExpression[head[[All,7;;]]]];*)
(*head[[All,2]]=If[Length[#]==1,#[[1]],#]&/@head[[All,2]];*)
(*(*get the labels*)*)
(*lab=StringSplit[list[[StringPosition[StringJoin[StringTake[#,1]&/@list],"# "][[1,1]]-2]]][[2;;-2]];*)
(**)
(*(*parse text table*)*)
(*dataIndex=Transpose[StringSplitExp[Select[list,StringTake[#,1]===" "&]]];(*longest part*)*)
(**)
(*(*create header values*)*)
(*dataVals=Thread[lab->(Sort[DeleteDuplicates[#]]&/@dataIndex)];*)
(*dataValsN=Thread["N_"<>#&/@dataVals[[All,1]]->Length/@dataVals[[All,2]] ];*)
(*dataVals[[All,2]]=If[Length[#]==1,#[[1]],#]&/@dataVals[[All,2]];*)
(**)
(*(*Create rules for values that are not a normal range. eg kspace index or coil numbers*)*)
(*If[MemberQ[lab,"kx"],ruleKx=Thread[("kx"/.dataVals)->(Range["N_kx"/.dataValsN]-1)]];*)
(*ruleKy=Thread[("ky"/.dataVals)->(Range["N_ky"/.dataValsN]-1)];*)
(*ruleKz=Thread[("kz"/.dataVals)->(Range["N_kz"/.dataValsN]-1)];*)
(*ruleCoil=Thread[("chan"/.dataVals)->(Range["N_chan"/.dataValsN]-1)];*)
(**)
(*(*partition raw data per k-line*)*)
(*data=DynamicPartition[data,dataIndex[[-1]]/8];(*longest part*)*)
(**)
(*(*split the data and index for data type*)*)
(*typ=("typ"/.dataVals[[1]]);*)
(*pos=Flatten@Position[dataIndex[[1]],#]&/@typ;*)
(*dataSplit=Thread[typ->(data[[#]]&/@pos)];*)
(*indexSplit=Thread[typ->(dataIndex[[All,#]]&/@pos)];*)
(**)
(*(*get the number of sample in the data data*)*)
(*nSamp=("STD"/.indexSplit)[[-1,1]]/8;*)
(*AppendTo[dataValsN,"N_samp"->nSamp];*)
(**)
(*(*get the data size*)*)
(*sizeInd={"N_kx","N_ky","N_kz","N_chan","N_dyn","N_card","N_echo","N_loca","N_mix","N_extr1","N_extr2","N_aver","N_samp"};*)
(*sizeInd=Select[sizeInd,MemberQ[dataValsN[[All,1]],#]&];*)
(*size=sizeInd/.dataValsN;*)
(*(*get the types with dimensions > 1*)*)
(*types=Pick[sizeInd,Unitize[size-1],1];*)
(**)
(*(*process noise data *)*)
(*noise="NOI"/.dataSplit;*)
(**)
(*(*get acepterd sample data and index*)*)
(*data=("STD"/.dataSplit);*)
(*ind=sizeInd[[;;-2]]/.Thread["N_"<>#&/@lab->Range[Length[lab]]];*)
(*indData=("STD"/.indexSplit)[[ind]];*)
(**)
(*(*reverse even echo*)*)
(*echo=1-Mod[indData[[Position[sizeInd,"N_echo"][[1,1]]]],2];*)
(*data=MapThread[If[#2==0,Reverse@#,#]&,{data,echo}];*)
(**)
(*(*convert the index values to array values*)*)
(*off=If[MemberQ[lab,"kx"],1,0];*)
(*If[MemberQ[lab,"kx"],indData[[1]]=indData[[1]]/.ruleKx;];*)
(*indData[[1+off]]=indData[[1+off]]/.ruleKy;*)
(*indData[[2+off]]=indData[[2+off]]/.ruleKz;*)
(*indData[[3+off]]=indData[[3+off]]/.ruleCoil;*)
(*indData=Transpose[indData+1];*)
(**)
(*(*create squeezed k-space*)*)
(*Clear[line];*)
(*kspace=ReplacePart[ConstantArray[line,size[[;;-2]]],Thread[indData->data]];(*longest part*)*)
(*line=ConstantArray[0.+0.I,nSamp];*)
(*kspace=Squeeze[kspace];*)
(*size=Dimensions[kspace];*)
(*Clear[line];*)
(**)
(*(*print output*)*)
(*Print["Datatypes in data: ",("typ"/.dataVals[[1]])];*)
(*Print[Column[Prepend[StringJoin/@Thread[{"  - ",types,": ",ToString/@size}],"The data contains: "]]];*)
(**)
(*(*define output*)*)
(*outHead={Join[dataVals,dataValsN,head],types};(*General*)*)
(*outData={kspace,noise};*)
(**)
(*(*output*)*)
(*{outData,outHead}*)
(*]*)


(* ::Input:: *)
(*(*split string en convert to expression*)*)
(*StringSplitExp[strings_]:=System`Convert`TableDump`ParseTable[StringCases[strings,Except[WhitespaceCharacter]..][[All,;;-2]],{{"",""},{"-","+"},"."},False]*)
(**)
(*(*removes singleton dimensions*)*)
(*Squeeze[data_]:=Block[{single},*)
(*single=((1-Unitize[Dimensions[data]-1])/. 0->All);*)
(*While[single[[-1]]===All&&Length[single]>1,single=Drop[single,-1]];*)
(*ToPackedArray[data[[##]]&@@single]*)
(*]*)
(**)
(*(*partition data in lists of arbitrary length*)*)
(*DynamicPartition[L_,p:{__Integer},x___]:=dPcore[L,Accumulate@p,x]/;!Negative@Min@p&&Length@L>=Tr@p*)
(*(*Partition function*)*)
(*dPcore[L_,p:{q___,_}]:=Inner[L[[#;;#2]]&,{0,q}+1,p,Head@L]*)
(*dPcore[L_,p_,All]:=Append[dPcore[L,p],Drop[L,Last@p]]*)
(*dPcore[L_,p_,n__]:=Join[dPcore[L,p],Partition[Drop[L,Last@p],n]]*)


(* ::Subsubsection::Closed:: *)
(*Export PDF report*)


(* ::Input:: *)
(*Clear[ExportPDFReport]*)
(*ExportPDFReport[myList_,fileName_:"",orient_:"Portrait"]:=Block[{report},*)
(*report=CreateDocument[Null,PageHeaders->{{None,None,None},{None,None,None}},PrintingOptions->{"PrintingMargins"->{{20,20},{20,20}},"PaperOrientation"->orient}];*)
(*Do[Paste[report,i];*)
(*NotebookWrite[report,Cell["","PageBreak",PageBreakBelow->True,CellMargins->0,PageWidth->PaperWidth]];*)
(*,{i,myList}];*)
(*Export[fileName,report];*)
(*NotebookClose[report];*)
(*Clear[report];*)
(*]*)


(* ::Subsubsection:: *)
(*B-spline Fitting*)


(* ::Input:: *)
(*(*0th order b-spline basis function*)*)
(*UnitComp=Compile[{{min,_Real,0},{max,_Real,0},{x,_Real,0}},*)
(*If[min<=x<max,1,0],*)
(*RuntimeAttributes->{Listable},RuntimeOptions->"Speed"];*)
(**)
(*(*b-spline division i*)*)
(*DivComp1=Compile[{{d,_Real,0},{u,_Real,0},{x,_Real,1}},*)
(*If[d==0.,x,(x-u)/d],*)
(*RuntimeAttributes->{Listable},RuntimeOptions->"Speed"];*)
(*(*b-spline division i+1*)*)
(*DivComp2=Compile[{{d,_Real,0},{u,_Real,0},{x,_Real,1}},*)
(*If[d==0.,x,(u-x)/d],*)
(*RuntimeAttributes->{Listable},RuntimeOptions->"Speed"];*)
(**)
(*(*generate b-spline basis functions with order p and knots, for x points*)*)
(*Basis[p_,knots_,x_]:=Basis[p,knots,x]=Block[{kn,ui,ui1,uip,uip1,bi,bi1,d1,d2},*)
(*(*function cashes the basis function already calculated*)*)
(*If[p==0,*)
(*(*first order splines*)*)
(*kn=knots;*)
(*kn[[-1]]=kn[[-1]]+1;*)
(*(*get the 0th order basis function*)*)
(*UnitComp[#[[1]],#[[2]],x]&/@Partition[kn,2,1]*)
(*,*)
(*(*higher order splines, first partition the knots*)*)
(*{ui,ui1,uip,uip1}=Transpose[Partition[knots,2+p,1][[All,{1,2,-2,-1}]]];*)
(*(*get the basis functions of order p-1 and partition*)*)
(*{bi,bi1}=Transpose[Partition[Basis[p-1,knots,x],2,1]];*)
(*(*get the basis functions of order p*)*)
(*DivComp1[uip-ui,ui,x]bi+DivComp2[uip1-ui1,uip1,x]bi1*)
(*]*)
(*]*)
(**)
(*Options[BSplineBasisFunctions]={SplineDegree->2,SplineKnotsNumber->50,SplineRegularization->0};*)
(**)
(*BSplineBasisFunctions[Npts_,opts:OptionsPattern[]]:=BSplineBasisFunctions[Npts,opts]=Block[{*)
(*cpn,sd,reg,len,paras,knots,coeffMat,coeffMatR,coeffMatDD,smooth*)
(*},*)
(*cpn=OptionValue[SplineKnotsNumber];*)
(*sd=OptionValue[SplineDegree];*)
(*reg=OptionValue[SplineRegularization];*)
(*len=Length[pts];*)
(**)
(*(*define the bpline points x = [0,1]*)*)
(*paras=Range[0,1,1/(Npts-1+2)]//N;*)
(*(*define the knots for order sd and cpn degrees of freedome*)*)
(*knots=Join[ConstantArray[0.,sd],N@Range[0,1,1/(cpn-sd)],ConstantArray[1.,sd]];*)
(*(*generate the coefficient matrix*)*)
(*coeffMat=Basis[sd,knots,paras];*)
(*(*maker reg coefficient matirx*)*)
(*coeffMatDD=ListConvolve[{1,-2,1},#]&/@coeffMat;*)
(*coeffMat=Transpose[coeffMat[[All,2;;-2]]];*)
(*smooth=reg (coeffMatDD.Transpose[coeffMatDD]);*)
(*coeffMatR=Join[coeffMat,smooth];*)
(*(*output*)*)
(*{coeffMat,coeffMatR}*)
(*]*)
(**)
(*Options[BSplineCurveFit]={SplineDegree->2,SplineKnotsNumber->50,SplineRegularization->0};*)
(**)
(*BSplineCurveFit[pts_,opts:OptionsPattern[]]:=Block[{*)
(*paras,knots,coeffMat,ctrlpts,cpn,sd,reg, len, Amat,ptsP*)
(*},*)
(*cpn=OptionValue[SplineKnotsNumber];*)
(**)
(*{coeffMat,Amat}=BSplineBasisFunctions[Length[pts],opts];*)
(**)
(*ptsP=PadRight[pts,Length[Amat]];*)
(*ctrlpts=LLeastSquares[Amat,ptsP];*)
(**)
(*(Amat.ctrlpts)[[;;(-cpn-1)]]*)
(*]*)


(* ::Subsubsection:: *)
(*Spectra Functions*)


(* ::Input:: *)
(*GetTimePPMRange[spec_,dt_,field_,nuc_,shift_]:=Block[{Nsamp,ppmFreq,time,bw,ppmBW,ppm},*)
(*Nsamp=Length[spec];*)
(*time=Range[dt,Nsamp dt,dt ];*)
(**)
(*ppmFreq=GyromagneticRatio[nuc]field;(*frequency per ppm*)*)
(*bw=1/dt;(*acquisition band with*)*)
(*ppmBW=bw/ppmFreq;(*ppm range*)*)
(*ppm=Range[-ppmBW/2+shift,ppmBW/2+shift,ppmBW/(Nsamp-1)];*)
(*{time,Reverse@ppm,{Nsamp,ppmFreq}}*)
(*]*)


(* ::Input:: *)
(*(*interpolate the time domain. *)*)
(*ChangeDwellTime[time_,dwOrig_,dwTar_]:=Block[{NsampOrig,timeOrig,NsampTar,timeTar},*)
(*(*get time of original signal*)*)
(*NsampOrig=Length@time;*)
(*timeOrig=dwOrig (Range[NsampOrig]-1);*)
(*(*define time of new signal*)*)
(*NsampTar=Round[Max[timeOrig]/dwTar];*)
(*timeTar=dwTar (Range[NsampTar]-1);*)
(*(*Interpolate the time to the new timescale*)*)
(*Interpolation[Transpose[{timeOrig,time}],InterpolationOrder->1][timeTar]*)
(*]*)
(**)
(*(*find the first and second order phase correction of spectra*)*)
(*PhaseCorrect[ppm_,speci_,phi0_?NumericQ,phi1_?NumericQ]:=PhaseCorrectC[ppm,speci,phi0,phi1]*)
(**)
(*PhaseCorrectC=Compile[{{ppm,_Real,1},{speci,_Complex,1},{phi0,_Real,0},{phi1,_Real,0}},Block[{spec},*)
(*spec=Exp[-I(phi0+phi1 ppm)]speci;*)
(*Total[(Arg[spec])^2]+Total[(Abs[spec]-Re[spec])^2]*)
(*],RuntimeOptions->"Speed"];*)
(**)
(*PhaseCorrectSpectra[ppm_,spect_]:=Block[{phi0,phi1},*)
(*{Exp[-I(phi0+phi1 ppm)]spect,{phi0,phi1}}/.FindMinimum[{PhaseCorrect[ppm,spect,phi0,phi1],-Pi<phi0<Pi,-Pi<phi1<Pi},{{phi0,0},{phi1,0}}][[2]]*)
(*]*)
(**)
(*Clear[EstimateLineWidth]*)
(*(*Function to estimate linewidth*)*)
(*EstimateLineWidth[ppm_,spec_,{peaks_,amps_}]:=Block[{dppm,deltaf,corrf,max,corrf2,pts,pos,ppmC},*)
(*(*define delta ppm and the delta function for correlation*)*)
(*dppm=(ppm[[1]]-ppm[[2]]);*)
(*deltaf=0 ppm;*)
(*deltaf[[Flatten[Position[ppm,First@Nearest[ppm,#]]&/@peaks]]]=amps;*)
(*(*perfomr correlation of spectra with delta function*)*)
(*corrf=Abs@ListCorrelate[deltaf,spec,Round[Length[deltaf]/2],0];*)
(*corrf=Length[corrf]corrf/Max[corrf];*)
(*(*Find max correlation and position*)*)
(*max=Max[corrf];*)
(*pos=Position[corrf,max][[1,1]];*)
(*(*{pos,max}=Transpose[FindPeaks[corrf]];*)
(*pos=Position[pos,First@Nearest[pos,Length[ppm]/2]][[1,1]];*)
(*max=max[[pos]];*)
(*pos=Position[corrf,max][[1,1]];*)*)
(*(*find two points closest to FWHM*)*)
(*corrf2=Transpose[{Range[Length[corrf]],-Abs[corrf-max/2]+max/2}];*)
(*pts=Nearest[corrf2,{pos,max/2},2];*)
(**)
(*(*debugging plots*)*)
(*(*ppmC=dppm(Range[Length[corrf]]-Length[corrf]/2);*)
(*Print[Show[PlotSpectra[ppm,deltaf,GridLineSpacing\[Rule]10],ImageSize\[Rule]300]];*)
(*Print[Show[PlotSpectra[ppm,spec,GridLineSpacing\[Rule]10],ImageSize\[Rule]300]];*)
(*Print[Show[*)
(*PlotSpectra[ppmC,corrf,GridLineSpacing\[Rule]10],*)
(*ListLinePlot[{Transpose[{ppmC[[pts[[All,1]]]],pts[[All,2]]}],{{ppmC[[pos]],0},{ppmC[[pos]],max}}},PlotStyle\[Rule]Directive[{Thick,Red}]*)
(*,ScalingFunctions\[Rule]{"Reverse",Automatic}]*)
(*,ImageSize\[Rule]300]];*)*)
(**)
(*(*calculate the estimated lw and shift*)*)
(*{dppm(Subtract@@(Reverse@Sort@pts[[All,1]])),-dppm(pos-(Length[ppm]/2.))}*)
(*]*)
(**)
(**)
(*(*function to estimate phase form abs fitting of baiss spectra*)*)
(*EstimatePhaseShift[{ppm_,spec_},{time_,fids_},{gam_,eps_},gyro_]:=Block[{specsC,fit,phi0f,phi1f,phi},*)
(*specsC=Transpose[ShiftedFourier[SpectraTimeShift[time,#,gyro,{gam,eps}]]&/@fids];*)
(*fit=specsC.NNLeastSquares[Abs[specsC],Abs[spec]];*)
(*phi={phi0f,phi1f}/.FindMinimum[*)
(*{PhaseError[ppm,fit,spec,{phi0f,phi1f}],-Pi<phi0f<Pi,-Pi<phi1f<Pi},*)
(*{phi0f,0},{phi1f,0}*)
(*][[2]];*)
(**)
(*(*debugging plots*)*)
(*(**)
(*Print[FlipView[{*)
(*Show[PlotSpectra[ppm,SpectraPhaseShift[ppm,fit,phi],GridLineSpacing\[Rule]10],ImageSize\[Rule]300],*)
(*Show[PlotSpectra[ppm,spec,GridLineSpacing\[Rule]10],ImageSize\[Rule]300]*)
(*}]];*)
(**)*)
(*phi*)
(*];*)
(**)
(*(*find the first and second order phase correction of spectra*)*)
(*PhaseError[ppm_,speci_,spect_,{phi0_?NumericQ,phi1_?NumericQ}]:=PhaseErrorC[ppm,speci,spect,phi0,phi1]*)
(**)
(*PhaseErrorC=Compile[{{ppm,_Real,1},{speci,_Complex,1},{spect,_Complex,1},{phi0,_Real,0},{phi1,_Real,0}},Block[{spec},*)
(*spec=Exp[-I(phi0+phi1 ppm)]speci;*)
(*Total[(Re[spect]-Re[spec])^2]+Total[(Im[spect]-Im[spec])^2]*)
(*],RuntimeOptions->"Speed"];*)
(**)
(**)
(**)
(*(*shift first and second order phase of spectra*)*)
(*SpectraPhaseShift[ppm_,spec_,phi0_]:=SpectraPhaseShiftC[ppm,spec,phi0,0.];*)
(*SpectraPhaseShift[ppm_,spec_,{phi0_,phi1_}]:=SpectraPhaseShiftC[ppm,spec,phi0,phi1];*)
(**)
(*SpectraPhaseShiftC=Compile[{{ppm,_Real,1},{spec,_Complex,1},{phi0,_Real,0},{phi1,_Real,0}},*)
(*Exp[-I(phi0+phi1 ppm)]spec,*)
(*RuntimeAttributes->{Listable},RuntimeOptions->"Speed"];*)
(**)
(*(*shift frequency and linewidth of FID*)*)
(*SpectraTimeShift[time_,times_,gyro_,gam_]:=SpectraTimeShiftC[time,times,gyro,gam,0.];*)
(*SpectraTimeShift[time_,times_,gyro_,{gam_,eps_}]:=SpectraTimeShiftC[time,times,gyro,gam,eps];*)
(**)
(*SpectraTimeShiftC=Compile[{{time,_Real,1},{times,_Complex,1},{gyro,_Real,0},{gam,_Real,0},{eps,_Real,0}},*)
(*Exp[-(gam-eps gyro 2 Pi I)time]times,*)
(*RuntimeAttributes->{Listable},RuntimeOptions->"Speed"];*)


(* ::Subsubsection:: *)
(*Plot Spectra*)


(* ::Input:: *)
(*Options[PlotSpectra]={PlotRange->Full,Method->"All",GridLines->{},PlotColor->Automatic,GridLineSpacing->.1};*)
(**)
(*PlotSpectra[ppm_,spec_,OptionsPattern[]]:=Block[{fun,plot,grid,or,rr,col},*)
(**)
(*fun=Switch[OptionValue[Method],"Abs",{Abs},"Re",{Re},"Im",{Im},"ReIm",{Im,Re},"All",{Im,Re,Abs}];*)
(**)
(*plot=Transpose[{ppm,#}]&/@(#@spec&/@fun);*)
(*grid=Join[Range[Round[Min[ppm]],Round[Max[ppm]],OptionValue[GridLineSpacing]],OptionValue[GridLines]];*)
(**)
(*rr=OptionValue[PlotRange];*)
(*Switch[rr,*)
(*{_,Full},rr[[2]]={-Max[Abs[spec]],Max[Abs[spec]]},*)
(*Full,rr={Full,{-Max[Abs[spec]],Max[Abs[spec]]}}*)
(*];*)
(**)
(*col=If[OptionValue[PlotColor]===Automatic,({Gray,{Red,Thin},{Thick,Black}}[[-Length[fun];;]]),OptionValue[PlotColor]];*)
(**)
(*ListLinePlot[plot,PlotStyle->col,PlotRange->rr,GridLines->{grid,None},*)
(**)
(*AspectRatio->.2,ImageSize->1000,ScalingFunctions->{"Reverse",Automatic},*)
(*Frame->{{False,False},{True,False}},FrameStyle->Directive[{Thick,Black}],FrameLabel->{"PPM",None},*)
(*LabelStyle->{Bold,14,Black}]*)
(*]*)
(**)
(*Options[PlotFid]={PlotRange->Full,Method->"All",GridLines->{},PlotColor->Automatic};*)
(**)
(*PlotFid[time_,fid_,OptionsPattern[]]:=Block[{fun,plot,grid,rr,col},*)
(**)
(*fun=Switch[OptionValue[Method],"Abs",{Abs},"ReIm",{Im,Re},"All",{Im,Re,Abs}];*)
(**)
(*plot=Transpose[{time,#}]&/@(#@fid&/@fun);*)
(*grid=Join[Range[Round[Min[time]],Round[Max[time]],.05],OptionValue[GridLines]];*)
(**)
(*rr=OptionValue[PlotRange];*)
(*Switch[rr,*)
(*{_,Full},rr[[2]]={-Max[Abs[fid]],Max[Abs[fid]]},*)
(*Full,rr={Full,{-Max[Abs[fid]],Max[Abs[fid]]}}*)
(*];*)
(**)
(*col=If[OptionValue[PlotColor]===Automatic,({Gray,{Red,Thin},{Thick,Black}}[[-Length[fun];;]]),OptionValue[PlotColor]];*)
(**)
(*ListLinePlot[plot,PlotStyle->col,PlotRange->rr,GridLines->{grid,{0}},*)
(*AspectRatio->.2,ImageSize->1000,*)
(*Frame->{{False,False},{True,False}},FrameStyle->Directive[{Thick,Black}],FrameLabel->{"time [s]",None},*)
(*LabelStyle->{Bold,14,Black}*)
(*]*)
(*]*)