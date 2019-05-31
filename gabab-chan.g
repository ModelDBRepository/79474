//genesis
//gabab-chan.g

function makegabab(vpath, galpha, gbar)
str vpath, galpha
float gbar

float area

area = {getfield {vpath} dia } * {getfield {vpath} len} * PI

create ligand2_chan {vpath}/gabab	/* units are msec, nA, uS, mV */
setfield  {vpath}/gabab	\
		k2f.min 0.005 \	/* 0.010 from Destexhe / 2 */
		k2f.max 0.0 \
		k2f.slope -20 \
		k2f.v0 -20.0 \
		k2f.in_exp_power 1 \
		k2f.out_exp_power -1 \
		k2f.in_exp_offset 0 \
		k2f.out_exp_offset 1 \
		k2b.min 0.001 \	/* 0.002 from Destexhe / 2 */
		k2b.max 0.0 \
		k2b.slope 10.0 \
		k2b.v0 -23.0 \
		k2b.in_exp_power 1 \
		k2b.out_exp_power -1 \
		k2b.in_exp_offset 0 \
		k2b.out_exp_offset 1 \
		gamma.min 0.00    \
		gamma.max 0.0 \
		gamma.slope -20 \
		gamma.v0 -20.0 \
		gamma.in_exp_power 1 \
		gamma.out_exp_power -1 \
		gamma.in_exp_offset 0 \
		gamma.out_exp_offset 1 \
		delta.min 0.00 \
		delta.max 0.0 \
		delta.slope 10.0 \
		delta.v0 -23.0 \
		delta.in_exp_power 1 \
		delta.out_exp_power -1 \
		delta.in_exp_offset 0 \
		delta.out_exp_offset 1 \
		k1f.min 0.009   \	/* 0.018 from Destexhe / 2 */
		k1f.max 0.0 \
		k1f.slope -20 \
		k1f.v0 -20.0 \
		k1f.in_exp_power 1 \
		k1f.out_exp_power -1 \
		k1f.in_exp_offset 0 \
		k1f.out_exp_offset 1 \
		k1b.min 0.025 \		/* 0.025 from Destexhe / 2 */
		k1b.max 0.0 \
		k1b.slope 10.0 \
		k1b.v0 -23.0 \
		k1b.in_exp_power 1 \
		k1b.out_exp_power -1 \
		k1b.in_exp_offset 0 \
		k1b.out_exp_offset 1 \
		Vr -85.0 \
		rxn_ord1 1 \
                rxn_ord2 0 \
		cond_state 1	\
		Gbar {gbar*area}

	addmsg {galpha} {vpath}/gabab LIGAND Conc
	addmsg {vpath} {vpath}/gabab VOLTAGE Vm
	addmsg {vpath}/gabab {vpath} CHANNEL G Vr

end

