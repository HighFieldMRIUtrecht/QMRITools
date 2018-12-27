(* ::Package:: *)

(* ::Title:: *)
(*QMRITools JcouplingTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*start Package*)


BeginPackage["QMRITools`JcouplingTools`"]

$ContextPath =  Union[$ContextPath, System`$QMRIToolsContextPaths];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection::Closed:: *)
(*Functions*)


SimHamiltonian::usage = 
"SimHamiltonian[sysi] simulates the hamiltionan for a given spin system. The spinsystem is generated by GetSpinSystem.
The output is the spin system and hamiltonian structure."

SimEvolve::usage =
"SimEvolve[din,H,t] evolves the spin system din given the hamiltonian H over a time t. din and H are generated by SimHamiltonian. 
The output is a new spinsystem dout."

SimRotate::usage = 
"SimRotate[din, H ,angle] rotates the spin system din given the hamiltonian H over angele with phase 90 degrees.
SimRotate[din, H ,angle, phase] rotates the spin system din given the hamiltonian H over angele with phase.
din and H are generated by SimHamiltonian. 
The output is a new spinsystem dout."

SimAddPhase::usage = 
"SimAddPhase[din ,H ,phase] adds phase to the spin system din given the hamiltonian H.
din and H are generated by SimHamiltonian. 
The output is a new spinsystem dout."

SimSpoil::usage = 
"SimSpoil[din] spoils all the non zeroth order states of a spin system.
The output is a new spinsystem dout."

SequencePulseAcquire::usage = 
"SequencePulseAcquire[din, H] performs a pulsaquire experiment of the spin system din given the hamiltonian H with a 90 Degree pulse.
SequencePulseAcquire[din, H, b1] performs a pulsaquire experiment of the spin system din given the hamiltonian H with a 90 Degree pulse and b1.
The output is a new spinsystem dout."

SequenceSpinEcho::usage =
"SequenceSpinEcho[din, H, te] performs a spin echo experiment with echo time te of the spin system din given the hamiltonian H with a 90 and 180 Degree pulse.
SequenceSpinEcho[din, H, te, b1] performs a spin echo experiment with echo time te of the spin system din given the hamiltonian H with a 90 and 180 Degree pulse and b1.
The output is a new spinsystem dout."

SequenceSteam::usage =
"SequenceSteam[din, H, {te, tm}] performs a stimulated echo experiment with echo time te and mixing time tm of the spin system din given the hamiltonian H with 3 90 Degree pulses.
The output is a new spinsystem dout."

SequenceTSE::usage =
"SequenceTSE[din ,H, {te, necho}, {ex, ref}] performs a multi echo spin echo experiment with echo time te with necho echos of the spin system din given the hamiltonian H using ex Degree exitation and ref Degree refocus pulses.
SequenceTSE[din ,H, {te, necho}, {ex, ref}, b1_:1] performs a multi echo spin echo experiment with echo time te with necho echos of the spin system din given the hamiltonian H using ex Degree exitation and ref Degree refocus pulses and b1.
The output is a new spinsystem dout."

SimReadout::usage = 
"SimReadout[din, H] performs a readout of a spinsystem din with hamiltonian H.
Output is {time,fids,ppm,spec,dout}, which are the free induction decay fids with its time, the spectrum spec with its ppm and the evolved spin system dout."

SimSignal::usage = 
"SimSignal[din, H] performs a readout of a spinsystem din with hamiltonian H.
Output is the complex signal."

PlotSpectrum::usage = 
"PlotSpectrum[ppm, spec] plots the spectrum, ppm and spec can be generated using SimReadout."

GetSpinSystem::usage = 
"GetSpinSystem[name] get a spinsystem that can be used in SimHamiltonian. Current implementes systems are \"glu\", \"lac\", \"gaba\", \"fatGly\", \"fatAll\", \"fatEnd\", \"fatDouble\", \"fatStart\", and \"fatMet\"."

SysTable::usage = 
"SysTable[sys] shows the spinsystem as a table. The spinsytem is obtained form GetSpinSystem."

PhaseAlign::usage = 
"PhaseAlign[spec] automatically phase aligns the spectrum by maximizing the Real part of the spectrum."


(* ::Subsection::Closed:: *)
(*Options*)


FieldStrength::usage = 
"FieldStrength is an option for SimHamiltonian. It defines the field strength for which the hamiltonian is calculated."

ReadoutOutput::usage = 
"ReadoutOutput is an option for SimReadout and SimSignal and values can be \"all\" and \"each\". When set to \"all\" the total signal and signal is given, when set to \"each\" the signal or spectrum for each peak is given seperately."

ReadoutPhase::usage = 
"ReadoutPhase is an option for SimReadout and defines the readout phase."

Linewidth::usage = 
"Linewidth is an option for SimReadout and defines the spectral linewidth."

LinewidthShape::usage = 
"LinewidthShape is an option for SimReadout and defines the linewidth shape, values can be \"L\", \"G\" or \"L\", which are Laplacian, Gaussion or a combination, respectively."

ReadoutSamples::usage = 
"ReadoutSamples is an option for SimReadout and defines the number of readout samples for the spectrum."

ReadoutBandwith::usage = 
"ReadoutBandwith is an option for SimReadout defines the spectral bandwith."

SpectrumColor::usage = 
"SpectrumColor is an option for PlotSpectrum and defines the spectrum color."

CenterFrequency::usage = 
"CenterFrequency is an option for GetSpinSystem and defines the center frequency."


(* ::Subsection:: *)
(*Error messages*)


(* ::Section:: *)
(*Jcoupling Core Functionality*)


Begin["`Private`"]


verb = False;


(* ::Subsection::Closed:: *)
(*SimHamiltonian*)


Options[SimHamiltonian]={FieldStrength->3}

SyntaxInformation[SimHamiltonian]={"ArgumentsPattern" -> {_, OptionsPattern[]}};

SimHamiltonian[sysi_,OptionsPattern[]]:=Block[{
sys,sysJ,sysS,scale,sysSi,names,it,name,Hj,Hres,nSpins,nSpins2,iden,zero,set,HbasisA,HbasisB,
states,statesi,st,bas,Hix,Hiy,Hiz,di,Hfx,Hfy,Hfz,wIxy,Ixy,Fxy,wFxy,
dn,weight,weighti,Hcs,Hjs,Hjw,ham,hamJ,valD,matU,valDJ,matUJ,hstruc, bField},

bField=OptionValue[FieldStrength];

sys=If[StringQ[sysi],GetSpinSystem[sysi],sysi];

(*define frequencys*)
{sysJ,sysS,scale,sysSi,names,it,name}=sys;
Hj=2Pi sysJ ;
Hres=sysS (-2.*Pi*bField*42.576 )(*omega at ppm*);

(*standard matrixes and sizes*)
nSpins=Length[sysS];nSpins2=2^nSpins;
iden=SparseArray[IdentityMatrix[nSpins2]];
zero=SparseArray[ConstantArray[0,{nSpins2,nSpins2}]];
(*make spin basis set*)
set=Permutations[-Sort@Flatten[ConstantArray[{1,-1},nSpins]],{nSpins}];
HbasisA=Transpose[.5ConstantArray[set,nSpins2],{2,3,1}];
HbasisB=Transpose/@HbasisA;
(*make states*)
statesi=Round@Abs[HbasisB-HbasisA];(*see where both are equal \[Rule] 0 equal, 1 different*)
states=SparseArray[1-Unitize[Total[statesi]-1]];(*find where only one is different, thus sum of states = 1*)
statesi=states #&/@statesi; (*get the individual spin states, thus find *)

(*Create All the angular momentum opperators Iix, Iiy and Iiz*)
{Hix,Hiy,Hiz,di}=Transpose[Table[
st=statesi[[i]];
bas=HbasisA[[i]];
{st Abs[bas],st bas I,iden bas,iden bas}
,{i,1,nSpins}]];
{Hfx,Hfy,Hfz,dn}=Total/@{Hix,Hiy,Hiz,di};
(*create the readout angular momentum opperators*)
Ixy=(Hix-Hiy I);Fxy=(Hfx-Hfy I);(*unweighted versions*)
wIxy=scale Ixy;wFxy=Total[wIxy];(*weighted for spin occurence*)

(*construct the hamiltonian Sum of Ii.Ij for j>i*)
Hcs=Hjs=Hjw=zero;
MatrixForm@Table[
Hcs-=Hres[[j]]Hiz[[j]] ;(* izj *)
Table[
Hjs-=Hj[[j,k]](Hiz[[j]].Hiz[[k]]);(* izj, izk*)
Hjw-=Hj[[j,k]](Hix[[j]].Hix[[k]]);(* ixj, ixk*)
Hjw-=Hj[[j,k]](Hiy[[j]].Hiy[[k]]);(* ixj, ixk*)
,{k,j+1,nSpins}]
,{j,nSpins}];
(*make the hamilonian with and without chemical shift*)
ham=Hcs+Hjs+Hjw;hamJ=Hjs+Hjw;
(*get eigensystem of the hamiltonian*)
{valD,matU}=Eigensystem[Normal[ham]];
matU=SparseArray[Chop[matU]];
{valDJ,matUJ}=Eigensystem[Normal[hamJ]];
matUJ=SparseArray[Chop[matUJ]];

(*make hstructure and output*)
hstruc={"J"->Hj,"shifts"->sysS,"shifts_rad"->Hj,"Bfield"->bField,"scale"->scale,
"nSpins"->nSpins,"nSpins2"->nSpins2,"basisA"->HbasisA,"basisB"->HbasisB,"sates"->states,"statesi"->statesi,
"Fx"->Hfx,"Fy"->Hfy,"Fz"->Hfz,"Fxy"->Fxy,"wFxy"->wFxy,"Ix"->Hix,"Iy"->Hiy,"Iz"->Hiz,"Ixy"->Ixy,"wIxy"->wIxy,
"weight"->weight,"weighti"->weighti,"Hab"->ham,"HabJ"->hamJ,"Hval"->valD,"Hvec"->matU,"HvalJ"->valDJ,"HvecJ"->matUJ};
(*output*)
{dn,hstruc}
]


(* ::Subsection:: *)
(*Excite and evolve*)


(* ::Subsubsection::Closed:: *)
(*SimEvolve*)


SyntaxInformation[SimEvolve]={"ArgumentsPattern" -> {_, _, _}};

SimEvolve[din_,H_,t_]:=Block[{d, matU,valD},
{valD,matU}={"Hval","Hvec"}/.H;(*use eigen basis for fast computation*)
d =SimEvolveM[matU,valD,t](*= Exp[-I ham t]*);
Chop[d.din.ConjugateTranspose[d]]
]

SimEvolveM[matU_,valD_,t_]:=Chop[Transpose[matU].SparseArray[DiagonalMatrix[Exp[I valD t]]].matU]


(* ::Subsubsection::Closed:: *)
(*SimRotate*)


SyntaxInformation[SimRotate]={"ArgumentsPattern" -> {_, _, _, _.}};

SimRotate[din_,H_,angle_,phase_:90]:=Block[{alpha,ph,dinS,Fx,Fy,Fz,Rz,rotate, pMat,rMat, tMat},
{alpha,ph}={angle, phase}Degree;(*to rad*)
rMat=MatrixExp[I alpha ("Fx"/.H)];(*rotation around x*)
pMat=MatrixExp[-I ph ("Fz"/.H)];(*phase - rotation around z*)
tMat=pMat.rMat.ConjugateTranspose[pMat];(*define rot matirx*)
Chop[tMat.din.ConjugateTranspose[tMat]](*predef matrix preven extra comp*)
];


(* ::Subsubsection::Closed:: *)
(*SimAddPhase*)


SyntaxInformation[SimAddPhase]={"ArgumentsPattern" -> {_, _, _}};

SimAddPhase[din_,H_,phase_]:=Block[{pMat},
pMat=MatrixExp[-I ("Fz"/.H) phase Degree];(*phase - rotation around z*)
Chop[pMat.din.ConjugateTranspose[pMat]](*add phase due to gradients, rotation around z*)
]


(* ::Subsubsection::Closed:: *)
(*SimSpoil*)


SyntaxInformation[SimSpoil]={"ArgumentsPattern" -> {_}};

SimSpoil[din_]:=Chop[IdentityMatrix[Length[din]]din](*spoil all non zeroth order states*)


(* ::Subsection:: *)
(*Sequences*)


(* ::Subsubsection::Closed:: *)
(*SequencePulseAcquire*)


SyntaxInformation[SequencePulseAcquire]={"ArgumentsPattern" -> {_, _, _.}};

SequencePulseAcquire[din_,H_,b1_:1]:=SimRotate[din,H,b1 90,0](*excite*)


(* ::Subsubsection::Closed:: *)
(*SequenceSpinEcho*)


SyntaxInformation[SequenceSpinEcho]={"ArgumentsPattern" -> {_, _, _, _.}};

SequenceSpinEcho[din_,H_,te_,b1_:1]:=Block[{d,tau},
tau=te/2;
d=SimRotate[din,H,b1 90,0];(*excite*)
d=SimEvolve[d,H,tau];(*evolve by tau, no crush*)
d=SimRotate[d,H,b1 180,90];(* refocus*)
SimEvolve[d,H,tau](*evolve by tau, no crush*)
]


(* ::Subsubsection::Closed:: *)
(*SequenceSteam*)


SyntaxInformation[SequenceSteam]={"ArgumentsPattern" -> {_, _, {_, _}}};

SequenceSteam[din_,H_,{te_,tm_}]:=Block[{d,tau},
tau=te/2;
Total@Table[
d=SimRotate[din,H,-90,0];(*excite*)
d=(2/Pi)SimAddPhase[d,H,j];(*dephase the transverse signal*)
d=SimEvolve[d,H,tau]; (*evolve by tau*)
d=SimRotate[d,H,-90,0]; (*tip up*)
d=SimSpoil[d];(*destroy all non zero order states*)
d=SimEvolve[d,H,tm];(*evolve by tm*)
d=SimRotate[d,H,-90,0];(*tip down*)
d=(Pi/4)SimAddPhase[d,H,j];(*dephase the transverse signal*)
d=SimEvolve[d,H,tau];(*evolve by tau*)
d
,{j,0,270,90}]
]


(* ::Subsubsection::Closed:: *)
(*SequenceTSE*)


SyntaxInformation[SequenceTSE]={"ArgumentsPattern" -> {_, _, {_, _}, {_,_}, _.}};

SequenceTSE[din_,H_,{te_,necho_},{ex_,ref_}, b1_:1]:=Block[{d,tau},
tau=te/2;
d=SimRotate[din,H,b1 ex,0];
(*loop over reg pulses*)
Table[
d=SimEvolve[d,H,tau];
d=SimRotate[d,H,b1 ref,90];
d=SimEvolve[d,H,tau]
,{i,0,necho}]
]


(* ::Subsection:: *)
(*ReadOut*)


(* ::Subsubsection::Closed:: *)
(*SimReadout*)


Options[SimReadout] = {ReadoutOutput->"all", ReadoutPhase->90, Linewidth->5, LinewidthShape->"L", ReadoutSamples -> 2046, ReadoutBandwith->2000}

SyntaxInformation[SimReadout]={"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

SimReadout[din_,H_,OptionsPattern[]]:=Block[{
dt,hab,field,nSpins2,Fx,Fy,time,fid,t2,sigma,decay,valD,matU,ord,sig,Ixy,
Fxy,corr,fids,d1,d,dout,ppm,spec,di,si,fun,wSpins,ran,phaseComp,val,
n,swidth,linewidth,sel,phase,shape},

n = OptionValue[ReadoutSamples];
swidth = OptionValue[ReadoutBandwith];
linewidth = OptionValue[Linewidth];
sel = OptionValue[ReadoutOutput];
phase = OptionValue[ReadoutPhase];
shape = OptionValue[LinewidthShape];

(*Get hamiltonian info*)
{valD,matU,field,nSpins2,Fxy,Ixy,wSpins}={"Hval","Hvec","Bfield","nSpins2","wFxy","wIxy","weight"}/.H;
(*get the time and ppms*)
dt=1./swidth;
time=dt(Range[0,n-1]);
ran=swidth/2-swidth/(2 n);
ppm=Range[-ran,ran,swidth/n]/(field 42.577 )+4.65;
(*shape definition*)
t2=1/(linewidth Pi);
sigma=Sqrt[( 2 t2 Log[0.5])^2/(-2*Log[0.5])];
decay=Switch[shape,
"L",Exp[-time/t2],
"G",Exp[-time/(2 sigma^2)],
"LG",0.5 Exp[-time/t2]+0.5Exp[-time/(2 sigma^2)]];
(*create the fids by incrementing the spinsystem by dt*)
d=SimEvolveM[matU,valD,dt];(*spin evolve over dt*)
di=din;(*initial signal and spin state*)
val=(1/nSpins2)decay Exp[-I  phase Degree];
(*evolve spin states with dt, but not for first*)
Switch[sel,
"all",
fids=val Table[If[i!=1,di=Chop[d.di.ConjugateTranspose[d]]];
 Tr[(di.Fxy)],{i,1,n}];
spec=InverseFourier[((-1)^Range[n])fids];
,
"each",
fids=Transpose[val Table[If[i!=1,Chop[di=d.di.ConjugateTranspose[d]]];
( Tr[di.#])&/@Ixy,{i,1,n}]];
spec=InverseFourier[((-1)^Range[n])#]&/@fids;
];
(*create spectra*)

{time,fids,ppm,spec,dout}
]


(* ::Subsubsection::Closed:: *)
(*SimSignal*)


Options[SimSignal] = {ReadoutOutput->"all"}

SyntaxInformation[SimSignal] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

SimSignal[din_,H_,OptionsPattern[]]:=Block[{Ixy,w,sel},
w=(1/"nSpins2")/.H;
sel=OptionValue[ReadoutOutput];
Switch[sel,
(*total signal*)
"all",w Tr[din.("wFxy"/.H)],
(*seperate signal for each peak*)
"each",Ixy=("wIxy"/.H);w Tr[din.#]&/@Ixy,
(*signal for peak selection either one or list*)
_,Ixy=("wIxy"/.H);If[ListQ[sel],w Tr[din.Ixy[[#]]]&/@sel,w Tr[din.Ixy[[sel]]]]
]
]


(* ::Subsection:: *)
(*PlotSpectrum*)


(* ::Subsubsection::Closed:: *)
(*PlotSpectrum*)


Options[PlotSpectrum] = {PlotRange->{{0,6}, Full}, SpectrumColor->Black}

SyntaxInformation[PlotSpectrum] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

PlotSpectrum[ppm_,spec_,OptionsPattern[]]:=Block[{pdat,style,ran, sc, col},

{ran, sc}=OptionValue[PlotRange];
col=OptionValue[SpectrumColor];

{pdat,style}=If[Head[spec[[1]]]===Complex,
{{Transpose@{ppm,Im@spec},Transpose@{ppm,Re@spec}},(Directive[#]&/@{{Thin,Lighter[col]},{Thick,col}})},
{Transpose@{ppm,spec},Directive[Thick,col]}];
ListLinePlot[pdat,
PlotRange->{ran,sc},ScalingFunctions->{"Reverse",Identity},
AxesStyle->Directive[{Thick,Black}],LabelStyle->Directive[{Bold,Black,12}],
PlotStyle->style,ImageSize->600,Axes->{True,False}]
]


(* ::Subsubsection::Closed:: *)
(*PhaseAlign*)


SyntaxInformation[PhaseAlign]={"ArgumentsPattern" -> {_}};

PhaseAlign[spec_]:=Block[{phi},
phi=Sort[Table[{Total[Re[Flatten[spec] Exp[I x Degree]]],x},{x,-180,180,.5}]][[-1,2]];
spec Exp[I phi Degree]
]


(* ::Subsection:: *)
(*Spin Systems*)


(* ::Subsubsection::Closed:: *)
(*GetSpinSystem*)


Options[GetSpinSystem] = {CenterFrequency->4.65};

SyntaxInformation[GetSpinSystem]={"ArgumentsPattern" -> {_, OptionsPattern[]}};

GetSpinSystem[name_, OptionsPattern[]]:=Block[{names, n, it, sysS, sysSi, sysJ, scale, j, j1, j2, cf},

cf=OptionValue[CenterFrequency];

Switch[name,
"glu",
(*single spin system*)
names={"A","B","C","D","E"};
n=Length[names];
it=Range[n];
sysSi={3.7433,2.0375,2.1200,2.3378,2.3520};
sysS=sysSi-cf;
sysJ={
{{1,2},7.3310},{{1,3},5.84},
{{2,3},-14.8490},{{2,4},6.4130},{{2,5},8.406},
{{3,4},8.4780},{{3,5},6.875},
{{4,5},-15.915}
};
sysJ=SysToMat[sysJ,n];
scale={1,1,1,1,1};
{sysJ,sysS,scale,sysSi,names,it,name}
,
"lac",
(*single spin system*)
names={"A","B","C","D"};
n=Length[names];
it=Range[n];
sysSi={4.0974,1.3142,1.3142,1.3142};
sysS=sysSi-cf;
sysJ={
{{1,2},6.933},{{1,3},6.933},{{1,4},6.933}
};
sysJ=SysToMat[sysJ,n];
scale={1,1,1,1};
{sysJ,sysS,scale,sysSi,names,it,name}
,
"gaba",
(*single spin system*)
names={"A","B","C","D","E","F"};
n=Length[names];
it=Range[n];
sysSi={2.2840, 2.2840, 1.8880, 1.8880, 3.0130, 3.0130};
sysS=sysSi-cf;
sysJ={
{{1,2},-15.938},{{1,3},7.678},{{1,4},6.98},
{{2,3},6.9800},{{2,4},7.678},
{{3,4},-15},{{3,5},8.5100},{{3,6},6.503},
{{4,5},6.503},{{4,6},8.51},
{{5,6},-14.062}
};
sysJ=SysToMat[sysJ,n];
scale={1,1,1,1,1,1};
{sysJ,sysS,scale,sysSi,names,it,name}
,
"fatGly",
(*single spin system*)
names={"G","H","I"};
n=Length[names];
it=Range[n];
sysSi={4.2,4.45,5.15};
sysS=sysSi-cf;
sysJ={
{{1,2},-12.4},{{1,3},7.0},
{{2,3},7.0}
};
sysJ=SysToMat[sysJ,n];
scale={2,2,1};
{sysJ,sysS,scale,sysSi,names,it,name}
,
"fatAll",
(*single spin system*)
names={"A","B","C","D","E","J"};
n=Length[names];
it=Range[n];
sysSi={0.9,1.3,1.6,2.0,2.3,5.3};
sysS=sysSi-cf;
sysJ={
{{1,2},5.0},
{{2,3},6},{{2,4},6},
{{3,5},6},
{{4,6},6.2}
};
sysJ=SysToMat[sysJ,n];
scale={9,66,6,12,6,6};
{sysJ,sysS,scale,sysSi,names,it,name}
,
"fatEnd",
(*single spin system*)
names={"B","A","A"(*,"A","B"*)};
n=Length[names];
it=Range[n];
sysSi={1.3,0.9,0.9(*,0.9,1.3*)};
sysS=sysSi-cf;
j=8;(*8.0*)
sysJ={
{{1,2},j}(*{{1,3},j},{{1,4},j},*)
(*{{2,5},j},
{{3,5},j},*)
(*{{4,5},j}*)
};
sysJ=SysToMat[sysJ,n];
scale=3{2,2,1(*,1,1*)}(*3 chains with head*);
{sysJ,sysS,scale,sysSi,names,it,name}
,
"fatDouble",
(*single spin system*)
names={"B","D","J"(*,"B","D"*)};
n=Length[names];
it=Range[n];
sysSi={1.3,2.03,5.3(*,1.3,2.03*)};
sysS=sysSi-cf;
j1=7.1;j2=6.2;
sysJ={
{{1,2},j1},(*{{1,5},j1},*)
{{2,3},j2}(*{{2,4},j1},*)
(*{{3,4},j2},*)
(*{{4,5},j1}*)
};
sysJ=SysToMat[sysJ,n];
scale=3 2{2,2,1(*,1,1*)}(*2x to complete, 3 chains with double*);
{sysJ,sysS,scale,sysSi,names,it,name}
,
"fatStart",
(*single spin system*)
names={"B","C","E"(*,"B","C","E"*)};
n=Length[names];
it=Range[n];
sysSi={1.3,1.6,2.27(*,1.3,1.6,2.27*)};
sysS=sysSi-cf;
j1=7.1(*CE*);j2=7.1(*BC*);
sysJ={(*7.1*)
{{1,2},j2},(*{{1,5},j2},*)
{{2,3},j1}(*,{{2,4},j2},{{2,6},j1},
{{3,5},j1},
{{4,5},j2},
{{5,6},j1}*)
};
sysJ=SysToMat[sysJ,n];
scale=3 {2,2,2(*,1,1,1*)}(*3 chains with start*);
{sysJ,sysS,scale,sysSi,names,it,name}
,
"fatMet",
names={"B"};
n=Length[names];
it=Range[n];
sysSi={1.3};
sysS=sysSi-cf;
sysJ={};
sysJ=SysToMat[sysJ,n];
scale=3 2 10{1}(*3 chains with 6 normal met with 2 H*);
{sysJ,sysS,scale,sysSi,names,it,name}
]
]

SysToMat[sysJ_,n_]:=Block[{out},
out=N@ConstantArray[0,{n,n}];
(out[[#[[1,1]],#[[1,2]]]]=#[[2]])&/@sysJ;
out
]


(* ::Subsubsection::Closed:: *)
(*SysTable*)


SyntaxInformation[SysTable]={"ArgumentsPattern" -> {_}};

SysTable[sys_]:=Module[{sysJ,sysS,sysSi,scale,names,it,
head,lab,tables,name},
tables=(
{sysJ,sysS,scale,sysSi,names,it,name}=#;
head=Thread[{(*it,*)names,sysSi,scale}];
lab={Row[#[[{1}]],"  "]&/@head,Column/@head};
Column[{Style[name,Bold,Large],TableForm[sysJ/. (0.->"-"),TableHeadings->lab]},Alignment->Center]
)&/@sys;
(*Column[tables,Alignment\[Rule]Center,Spacings\[Rule]2]*)
tables
]


(* ::Section:: *)
(*End Package*)


End[]

EndPackage[]

