//genesis
//kleak-newlig4.g

function make_kleak(path, gbar, vpath)
str	path
float	gbar

float area

if ({vpath} == "/rhab/vm")
    area={rhabSA}/{rhabcyls}
else
    area = {getfield {path} SAout }
end

//echo {vpath} {area}

create ligand2_chan {path}/kleak	/* units are msec, nA, uS, mV */
setfield  {path}/kleak	\
		k1f.min 2000 \	
		k1f.max 0.0 \
		k1f.slope -20 \
		k1f.v0 -20.0 \
		k1f.in_exp_power 1 \
		k1f.out_exp_power -1 \
		k1f.in_exp_offset 0 \
		k1f.out_exp_offset 1 \
		k1b.min 1.2e-3 \	
		k1b.max 0.0 \
		k1b.slope 10.0 \
		k1b.v0 -23.0 \
		k1b.in_exp_power 1 \
		k1b.out_exp_power -1 \
		k1b.in_exp_offset 0 \
		k1b.out_exp_offset 1 \
		k2f.min 20e3 \	
		k2f.max 0.0 \
		k2f.slope -20 \
		k2f.v0 -20.0 \
		k2f.in_exp_power 1 \
		k2f.out_exp_power -1 \
		k2f.in_exp_offset 0 \
		k2f.out_exp_offset 1 \
		k2b.min 0.1e-3 \	
		k2b.max 0.0 \
		k2b.slope 10.0 \
		k2b.v0 -23.0 \
		k2b.in_exp_power 1 \
		k2b.out_exp_power -1 \
		k2b.in_exp_offset 0 \
		k2b.out_exp_offset 1 \
        	gamma.slope -20 \
        	gamma.min 0 \
        	gamma.max 0 \
		gamma.in_exp_power 1 \
		gamma.out_exp_power -1 \
		gamma.in_exp_offset 0 \
		gamma.out_exp_offset 1 \
        	delta.slope -20 \
        	delta.min 0 \
        	delta.max 0 \
		delta.in_exp_power 1 \
		delta.out_exp_power -1 \
		delta.in_exp_offset 0 \
		delta.out_exp_offset 1 \
		Vr -85.0 \
		rxn_ord1 2 \
		rxn_ord2 2 \
        	cond_state 0 \
		Gbar {gbar*area}

end

/********************************************************************/

function kleak_comp (vpath, capath, startcyl, endcyl, gbar)
str vpath, capath
int startcyl, endcyl
float gbar

int i

  for (i=startcyl; i<=endcyl; i=i+1)
    make_kleak {capath}[{i}] {gbar} {vpath}
    addmsg {capath}[{i}] {capath}[{i}]/kleak LIGAND Conc
    addmsg {vpath} {capath}[{i}]/kleak VOLTAGE Vm
    addmsg {capath}[{i}]/kleak {vpath} CHANNEL G Vr
  end
end
