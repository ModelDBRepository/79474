//genesis
//gabaa-chan.g

function makegabaa(vpath,spikepath, gbar)
str vpath, spikepath
float gbar

float area

area = {getfield {vpath} dia } * {getfield {vpath} len} * PI

create ligand2_chan {vpath}/gabaa	/* units are msec, nA, uS, mV */
setfield  {vpath}/gabaa	\
		k2f.min 0.018 \	/* 0.022 from Destexhe * 0.8 */
		k2f.max 0.0 \
		k2f.slope -20 \
		k2f.v0 -20.0 \
		k2f.in_exp_power 1 \
		k2f.out_exp_power -1 \
		k2f.in_exp_offset 0 \
		k2f.out_exp_offset 1 \
		k2b.min 0.009 \	/* 0.011 from Destexhe * 0.8 */
		k2b.max 0.0 \
		k2b.slope 10.0 \
		k2b.v0 -23.0 \
		k2b.in_exp_power 1 \
		k2b.out_exp_power -1 \
		k2b.in_exp_offset 0 \
		k2b.out_exp_offset 1 \
		gamma.min 0.031    \	/* 0.034 from Destexhe * 0.87 from ffrench-Mullen*/
		gamma.max 0.0 \
		gamma.slope -20 \
		gamma.v0 -20.0 \
		gamma.in_exp_power 1 \
		gamma.out_exp_power -1 \
		gamma.in_exp_offset 0 \
		gamma.out_exp_offset 1 \
		delta.min 0.165 \	/* 0.19 from Destexhe *0.87 from ffrench-Mullen*/
		delta.max 0.0 \
		delta.slope 10.0 \
		delta.v0 -23.0 \
		delta.in_exp_power 1 \
		delta.out_exp_power -1 \
		delta.in_exp_offset 0 \
		delta.out_exp_offset 1 \
		k1f.min 0.130    \	/* 0.15 from Destexhe * 0.87 from ffrench-Mullen */
		k1f.max 0.0 \
		k1f.slope -20 \
		k1f.v0 -20.0 \
		k1f.in_exp_power 1 \
		k1f.out_exp_power -1 \
		k1f.in_exp_offset 0 \
		k1f.out_exp_offset 1 \
		k1b.min 0.160 \		/* 0.2 from Destexhe * 0.8 from ffrench-Mullen*/
		k1b.max 0.0 \
		k1b.slope 10.0 \
		k1b.v0 -23.0 \
		k1b.in_exp_power 1 \
		k1b.out_exp_power -1 \
		k1b.in_exp_offset 0 \
		k1b.out_exp_offset 1 \
		Vr -70.0 \
		rxn_ord1 1 \
rxn_ord2 0 \
		cond_state 1 \
		Gbar {gbar*area}

	addmsg {spikepath} {vpath}/gabaa LIGAND state
	addmsg {vpath} {vpath}/gabaa VOLTAGE Vm
	addmsg {vpath}/gabaa {vpath} CHANNEL G Vr

end


