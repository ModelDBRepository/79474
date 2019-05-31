//genesis
//kc4act3AtypeAslowinact.g
// Kca current, modified from Sakakibara et al. 1993 by Avrama, Nov, 1997
//kca current params modified for dependence on internal calcium concentration

function make_kctypeA(path, gbar)
str	path
float gbar

float area

area = {getfield {path} SAout }

create vdep_ligdep_chan {path}/kctypeA	/* units are msec, nA, uS, mV */
setfield ^ 	act_ssv.min 0.0 \
		act_ssv.max 1.0 \
		act_ssv.slope -17.0 \
		act_ssv.v0 -34.0 \
		act_ssv.power -1 \
		act_ssv.offset 1 \
 		act_ssca.min 0.0 \
		act_ssca.max 1.0 \
		act_ssca.slope -0.6 \
		act_ssca.v0 -4.15 \
		act_ssca.out_exp_power -1 \
		act_ssca.in_exp_power 1 \
		act_ssca.out_exp_offset 1 \
		act_ssca.in_exp_offset 0 \
		act_tauv.min 200 \
		act_tauv.max 50 \
		act_tauv.slope 4.0 \
		act_tauv.v0 -33.0 \
		act_tauv.power -1 \
		act_tauv.offset 1 \
		act_tauca.min 0.7 \
		act_tauca.max 0.3 \
		act_tauca.slope 0.4 \
		act_tauca.v0 -3.69 \
		act_tauca.in_exp_power 1 \
		act_tauca.out_exp_power -1 \
		act_tauca.in_exp_offset 0 \
		act_tauca.out_exp_offset 1 \
		inact_ssca.min 1.0 \
		inact_ssca.max 0.0 \
		inact_ssca.slope 0.11 \
		inact_ssca.v0 -3.6 \
		inact_ssca.in_exp_power 1 \
		inact_ssca.out_exp_power -1 \
		inact_ssca.in_exp_offset 0 \
		inact_ssca.out_exp_offset 1\
		inact_ssv.min 0.3 \
		inact_ssv.max 0.7 \
		inact_ssv.v0 -36.0 \
		inact_ssv.slope 8.0 \
		inact_ssv.power -1 \
		inact_ssv.offset 1 \
		inact_tauv.min 1000.0 \
		inact_tauv.max 1200.0 \
		inact_tauv.slope -5.0 \
		inact_tauv.v0 -10.0 \
		inact_tauv.power -1 \
		inact_tauv.offset 1 \
		inact_tauca.min 1.0 \
		inact_tauca.max 0.0 \
		inact_tauca.slope -0.7 \
		inact_tauca.v0 -3.5 \
		inact_tauca.in_exp_power 1 \
		inact_tauca.out_exp_power -1 \
		inact_tauca.in_exp_offset 0 \
		inact_tauca.out_exp_offset 1 \
		act_power 3 \
		inact_power 1 \
		Vr -85.0 \
		Gbar   {gbar*area} \
		act_ss_type 0 \
		act_tau_type 0 \
		inact_ss_type 0 \
		inact_tau_type 0

end

/********************************************************************/

function icak_typeA (vpath, capath, cyl1, ncyls, gbar)
str vpath, capath
int ncyls, cyl1
float gbar

int i

  for (i=cyl1; i<=ncyls; i=i+1)
	make_kctypeA {capath}[{i}] {gbar}
	addmsg {vpath} {capath}[{i}]/kctypeA VOLTAGE Vm
	addmsg {capath}[{i}] {capath}[{i}]/kctypeA LIGAND Conc
	addmsg {capath}[{i}]/kctypeA {vpath} CHANNEL G Vr
  end
end
