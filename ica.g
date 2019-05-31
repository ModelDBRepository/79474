//genesis
//ica.g

function make_ica(path, type, actv0, actslope, acttau, inactv0, inactslope, inacttau, inactpow, actpow)
str path, type
float actv0, actslope, acttau
float inactv0, inactslope, inacttau
int inactpow, actexp

create inf_tau_chan {path}/{type}_ica	/* units are msec, nA, uS, mV */
setfield ^ 	act_ss.min 0 \
		act_ss.max 1.0 \
		act_ss.slope {actslope} \
		act_ss.v0 {actv0} \
		act_ss.in_exp_power 1 \
		act_ss.out_exp_power -1 \
		act_ss.in_exp_offset 0 \
		act_ss.out_exp_offset 1 \
		act_tau.min {acttau} \
		act_tau.max 0.0 \
		act_tau.slope 10.0 \
		act_tau.v0 0.0 \
		act_tau.in_exp_power 1 \
		act_tau.out_exp_power -1 \
		act_tau.in_exp_offset 0 \
		act_tau.out_exp_offset 1 \
	 	inact_ss.min 0 \
		inact_ss.max 1.0 \
		inact_ss.slope {inactslope} \
		inact_ss.v0 {inactv0} \
		inact_ss.in_exp_power 1 \
		inact_ss.out_exp_power -1 \
		inact_ss.in_exp_offset 0 \
		inact_ss.out_exp_offset 1 \
		inact_tau.min {inacttau} \
		inact_tau.max 0.0 \
		inact_tau.slope 10.0 \
		inact_tau.v0 0.0 \
		inact_tau.in_exp_power 1 \
		inact_tau.out_exp_power -1 \
		inact_tau.in_exp_power 1 \
		inact_tau.in_exp_offset 0 \
		inact_tau.out_exp_offset 1 \
		act_power {actpow} \
		inact_power {inactpow} \
		Vr 50.0 \
		Gbar   1
end

/******************************************************************/

function make_ghk(path,pca,type)
str path,type
float pca

float area

area = {getfield {path} SAout}

create electrodif {path}/{type}_ghk_ica

setfield ^ Pca {pca*area} \
	   charge 2 \
	   T 293 \
	   Vunits 0.001
end

/*******************************************************************/
function ica_axon (vpath, capath, startcyl, endcyl, pca_axon, caextpath)
str vpath, capath, caextpath
int startcyl, endcyl
float pca_axon, Cext

int i

  for (i=startcyl; i<=endcyl; i=i+1)
   make_ica {capath}[{i}] persist 13.2 -8 150 0 10 0 0	1 /* make traditional ica, persistant */
   make_ghk {capath}[{i}] {pca_axon} persist	/* make GHK Ica */

/* voltage messages to Ica and GHK-Ica */
   addmsg {vpath} {capath}[{i}]/persist_ica VOLTAGE Vm
   addmsg {vpath} {capath}[{i}]/persist_ghk_ica VOLTAGE Vm

/* ext & int calcium concentration to GHK */
   addmsg {caextpath} {capath}[{i}]/persist_ghk_ica CONC_EXT Conc
   addmsg {capath}[{i}] {capath}[{i}]/persist_ghk_ica CONC_INT Conc

/* open fraction from ica to GHK ica = G / Gbar */
   addmsg {capath}[{i}]/persist_ica {capath}[{i}]/persist_ghk_ica OPEN_FRACTION G Gbar

/* send psuedoG and Vr to voltage compartment */
   addmsg {capath}[{i}]/persist_ghk_ica {vpath} CHANNEL pseudoG Vr

/* send current and charge to concentration pool */
   addmsg {capath}[{i}]/persist_ghk_ica {capath}[{i}] CURRENT charge I
end
end

/*******************************************************************/

function ica_ghk_comp (vpath, capath, startcyl, endcyl, pca_persist, pca_trans, caextpath)
str vpath, capath, caextpath
int startcyl, endcyl
float pca_persist, pca_trans, Cext

int i

  for (i=startcyl; i<=endcyl; i=i+1)
   make_ica {capath}[{i}] persist 3.2 -8 150 0 10 0 0	1 /* make traditional ica, persistant */
   make_ghk {capath}[{i}] {pca_persist}	persist	/* make GHK Ica */

/* voltage messages to Ica and GHK-Ica */
   addmsg {vpath} {capath}[{i}]/persist_ica VOLTAGE Vm
   addmsg {vpath} {capath}[{i}]/persist_ghk_ica VOLTAGE Vm

/* ext & int calcium concentration to GHK */
   addmsg {caextpath} {capath}[{i}]/persist_ghk_ica CONC_EXT Conc
   addmsg {capath}[{i}] {capath}[{i}]/persist_ghk_ica CONC_INT Conc

/* open fraction from ica to GHK ica = G / Gbar */
   addmsg {capath}[{i}]/persist_ica {capath}[{i}]/persist_ghk_ica OPEN_FRACTION G Gbar

/* send psuedoG and Vr to voltage compartment */
   addmsg {capath}[{i}]/persist_ghk_ica {vpath} CHANNEL pseudoG Vr

/* send current and charge to concentration pool */
   addmsg {capath}[{i}]/persist_ghk_ica {capath}[{i}] CURRENT charge I

/* repeat for transient current */
//   make_ica {capath}[{i}] trans -40.0 -10 10 -48 11 130 1 1	/* make traditional ica, transient */
   make_ica {capath}[{i}] trans -30.0 -10 5 -49 6 75 1 2	/* make traditional ica, transient */
   make_ghk {capath}[{i}] {pca_trans}	trans	/* make GHK Ica */

/* voltage messages to Ica and GHK-Ica */
   addmsg {vpath} {capath}[{i}]/trans_ica VOLTAGE Vm
   addmsg {vpath} {capath}[{i}]/trans_ghk_ica VOLTAGE Vm

/* ext & int calcium concentration to CHK */
   addmsg {caextpath} {capath}[{i}]/trans_ghk_ica CONC_EXT Conc
   addmsg {capath}[{i}] {capath}[{i}]/trans_ghk_ica CONC_INT Conc

/* open fraction from ica to GHK ica = G / Gbar */
   addmsg {capath}[{i}]/trans_ica {capath}[{i}]/trans_ghk_ica OPEN_FRACTION G Gbar

/* send psuedoG and Vr to voltage compartment */
   addmsg {capath}[{i}]/trans_ghk_ica {vpath} CHANNEL pseudoG Vr

/* send current and charge to concentration pool */
   addmsg {capath}[{i}]/trans_ghk_ica {capath}[{i}] CURRENT charge I
 end
end


