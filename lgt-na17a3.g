//chemesis2.0
//lgt-na17a.g

function makelgtna(path, gbar)
str	path
float	gbar

float area

area = {getfield {path} SAout }


create ligand1_chan {path}/lgtna	/* units are msec, nA, uS, mV */
setfield  {path}/lgtna	\
		alpha.min 3.0e-3 \
		alpha.max 0.0 \
		alpha.slope -20 \
		alpha.v0 -20.0 \
		alpha.in_exp_power 1 \
		alpha.out_exp_power -1 \
		alpha.in_exp_offset 0 \
		alpha.out_exp_offset 1 \
		beta.min 15.0e-3 \	
        beta.max 0.0 \
		beta.slope 10.0 \
		beta.v0 -23.0 \
		beta.in_exp_power 1 \
		beta.out_exp_power -1 \
		beta.in_exp_offset 0 \
		beta.out_exp_offset 1 \
		act_power 1 \
		inact_power 1 \
		inact_type 1 \
		gamma.min 0.5e-3    \
		gamma.max 0.0e-3 \
		gamma.slope 0.03e-3 \
		gamma.v0 0.00 \
		gamma.in_exp_power 1 \
		gamma.out_exp_power -1 \
		gamma.in_exp_offset 0 \
		gamma.out_exp_offset 1 \
		delta.min 0.6e-3 \
		delta.max 0.0 \
		delta.slope 0.03e-3 \
		delta.v0 0.0 \
		delta.in_exp_power 1 \
		delta.out_exp_power -1 \
		delta.in_exp_offset 0 \
		delta.out_exp_offset 1 \
		Vr 30.0 \
		rxn_ord 2 \
		inact_rxn_ord 1 \
		Gbar {gbar*area}

end

/********************************************************************/
function lgtna_comp(vpath,ligpath,ncyls,gbar)

str vpath, ligpath
int ncyls
float gbar

int i

   for (i=1; i<= ncyls; i=i+1)
	makelgtna {ligpath}[{i}] {gbar}
	addmsg {ligpath}[{i}] {ligpath}[{i}]/lgtna LIGAND Conc
	addmsg {vpath} {ligpath}[{i}]/lgtna VOLTAGE Vm
	addmsg {ligpath}[{i}]/lgtna {vpath} CHANNEL G Vr
   end
end
