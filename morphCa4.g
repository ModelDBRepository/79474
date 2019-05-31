//CHEMESIS2.0
//morphCa4.g

echo {type} ": speed=" {na_speed} ", nastart=" {nastart}

/****** set clocks, units are milliseconds *********/
setclock 0 0.005	/* Used for Calcium cytosol */
setclock 1 0.01		/* iicr and CaER, Vm, gaba A, serca and leak */
setclock 2 0.02		/* cicr, biochem rxn, gaba B, cytleak and pump */
setclock 3 0.04		/* Used for ip3*/
setclock 4 0.2		/* Used for spike generator, inject current*/
setclock 5 0.4		/* for graphs and plot_out*/
setclock 6 5.0		/* used for spatial output */

create conservepool /extracell
setfield /extracell Cinit 10 Ctot 10 Conc 10 volume 2e-4
useclock /extracell 4

   /************ set up soma *************************/
/*** electrical compartment and voltage dependent channels ***/
create neutral /soma
Vcomp /soma/vm[1] {somalen} {somarad} {RM} {CM} {RI} {Er} {Vinit}

ih_comp /soma/vm 1 1 {g_ihsoma} {type} 
make_ka /soma/vm[1] {gkasoma} {ka_v0}
make_K {kinact} /soma/vm[1] {gKdrsoma} {type}

/* shunt due to electrode */ 
create leakage /soma/shunt
setfield /soma/shunt Ek 0 Gk {gshunt}
addmsg /soma/shunt /soma/vm[1] CHANNEL Gk Ek
addmsg /soma/vm[1] /soma/shunt VOLTAGE Vm

/*** calcium objects ***/
ca_buf_ip3_taper /soma {somacyls} {somashells} {somarad} {shellsize} {somalen} {ERfactor} {concen} {umole}
/*taper the soma, then make calcium release */
changeradius /soma 24 5.5e-4 2 {shellsize}	
changeradius /soma 23 8.0e-4 2 {shellsize}
changeradius /soma 1 4.5e-4 2 {shellsize}
changeradius /soma 2 7e-4 2 {shellsize}
makecyt2er /soma/Cacyt /soma/ip3 /soma/CaER {maxiicr} {iicrpower} {maxcicr} {cicrpower} {somashells} {somacyls} {serca} {pumppower} 1e-3
  useclock /soma/Cacyts#[]/x# 1
  useclock /soma/Cacyts#[]/iicrflux 1
  useclock /soma/Cacyts#[]/x00 2
  useclock /soma/Cacyts#[]/x01 2
  useclock /soma/Cacyts#[]/x10 2
  useclock /soma/Cacyts#[]/x11 2
  useclock /soma/Cacyts#[]/ryanflux 2
  useclock /soma/Cacyts#[]/serca 2
  useclock /soma/Cacyts#[]/leak 2
cytpumpcomp /soma/Cacyts1 /extracell pmca {somacyls} {Vpmca} {kpmca} {pmca_power} {mmole}
ncxcomp /soma/Cacyts1 /soma/vm[1] extracell 1 {somacyls} {Vncx} {kncx}
setsercaleak /soma/Cacyt /soma/CaER {somashells} {somacyls} {serca}

kleak_comp /soma/vm[1] /soma/Cacyts1 1 {somacyls} {gleak}
ica_ghk_comp /soma/vm[1] /soma/Cacyts1 1 {somacyls} {pca_p} {pca_t} /extracell
icak_comp /soma/vm[1] /soma/Cacyts1 {somacyls} {gkca}

useclock /soma/vm[1] 0
useclock /soma/Cacyts1[]/pmca 2
useclock /soma/Cacyts1[]/ncx 2
useclock /soma/Cacyts1[]/kleak 3
useclock /soma/Cacyts1[]/cytleak 2
useclock /soma/shunt 3
useclock /soma/vm[1]/ih 2
useclock /soma/Cacyt[]/#ica 1
useclock /soma/Cacyt[]/kca 2
useclock /soma/vm[1]/ka 1

  /************* set up rhabdomere **********************/
        /**voltage compartment **/

create neutral /rhab
Vcomp /rhab/vm {rhablen} {rhabrad} {RM} {CM} {RI} {Er} {Vinit}
setfield /rhab/vm Rm {RM/rhabSA} Cm {CM*rhabSA} Ra {Rcore}

    /*** calcium objects ***/
ca_ip3_rhab /rhab {rhabcyls} {rhabshells} {rhabrad} {rhabrad-rhabcorerad} {rhablen} {ERfactor} {quant} {concen} {umole}
cytpumpcomp /rhab/Cacyts1 /extracell pmca {rhabcyls} {Vpmca} {kpmca} {pmca_power} {mmole}
ncxcomp /rhab/Cacyts1 /rhab/vm extracell 1 {rhabcyls} {Vncx} {kncx}
setsercaleak /rhab/Cacyt /rhab/CaER {rhabshells} {rhabcyls} {serca}
kleak_comp /rhab/vm /rhab/Cacyts1 1 {rhabcyls} {gleak}

useclock /rhab/vm 0
useclock /rhab/Cacyts1[]/pmca 2
useclock /rhab/Cacyts1[]/ncx 2
useclock /rhab/Cacyts1[]/cytleak 2
useclock /rhab/Cacyts1[]/kleak 3

  /************* create neck *************/
	/***voltage compartment **/
create neutral /neck
Vcomp /neck/vm {necklen} {neckrad} {RM} {CM} {RI} {Er} {Vinit}
 
/*** calcium objects ***/
ca_buf_ip3_2D /neck 1 1 {neckrad} {shellsize} {necklen} {ERfactor} {concen} {umole}
cytpumpcomp /neck/Cacyts1 /extracell pmca 1 {Vpmca} {kpmca} {pmca_power} {mmole}
ncxcomp /neck/Cacyts1 /neck/vm extracell 1 1 {Vncx} {kncx}
setsercaleak /neck/Cacyt /neck/CaER 1 1 {serca}

useclock /neck/vm 0
useclock /neck/Cacyts1[]/pmca 2
useclock /neck/Cacyts1[]/ncx 2
useclock /neck/Cacyts1[]/cytleak 2

   /************ set up axon *************************/
        /**voltage compartment **/

create neutral /axon
ellipse_vcomp /axon/vm {axonlen} {axonslice} {axondiama} {axondiamb}  {RM} {CM} {RI} {Er} {Vinit}

    Na_comp B /axon/vm {gNaF} {nastart} {axonslice} {na_speed}
    ka_comp /axon/vm {gka} 1 {axonslice} {ka_v0}
    K_comp {kinact} /axon/vm {gKdr} 1 {axonslice} {type}
    ih_comp /axon/vm 1 {axonslice}  {g_ih} {type}

/*** calcium objects ***/
ca_buf_ip3_taper /axon {axoncyls} 1 {(axondiama+axondiamb)/4} {shellsize} {axonlen} {ERfactor} {concen} {umole}

/*taper the axon, then make calcium release */
changeradius /axon 100 4.0e-4 1 {shellsize}
changeradius /axon 99 2.5e-4 1 {shellsize}
makecyt2er /axon/Cacyt /axon/ip3 /axon/CaER {maxiicr} {iicrpower} {maxcicr} {cicrpower} 1 {axoncyls} {serca} {pumppower} 1e-3

  useclock /axon/Cacyts#[]/x# 1
  useclock /axon/Cacyts#[]/iicrflux 1
  useclock /axon/Cacyts#[]/x00 2
  useclock /axon/Cacyts#[]/x01 2
  useclock /axon/Cacyts#[]/x10 2
  useclock /axon/Cacyts#[]/x11 2
  useclock /axon/Cacyts#[]/ryanflux 2
  useclock /axon/Cacyts#[]/serca 2
  useclock /axon/Cacyts#[]/leak 2

cytpumpcomp /axon/Cacyts1 /extracell pmca {axoncyls} {Vpmca} {kpmca} {pmca_power} {mmole}
for (i=1; i<={axonslice}; i=i+1)
    axonval={axonslice}
    increment= {axoncyls}/{axonval}
    start=(i-1)*increment+1
    last=(i*increment)
    ncxcomp /axon/Cacyts1 /axon/vm[{i}] extracell {start} {last} {Vncx} {kncx}
    kleak_comp /axon/vm[{i}] /axon/Cacyts1 {start} {last} {gleak}
end
echo {increment}
setsercaleak /axon/Cacyt /axon/CaER 1 {axoncyls} {serca}

useclock /axon/vm[] 0
useclock /axon/Cacyts1[]/pmca 2
useclock /axon/Cacyts1[]/ncx 2
useclock /axon/Cacyts1[]/cytleak 2
useclock /axon/Cacyts1[]/kleak 3
useclock /axon/vm[]/ih 2
useclock /axon/vm[]/ka 1

   /************ set up terminal branches *************************/
	/* assume 1 of branches has gaba synapse, others don't */

        /**voltage compartment **/
create neutral /branch_syn
for (i=1; i<={branchcomps}; i=i+1)
  Vcomp /branch_syn/vm[{i}] {branchlen1} {syn_br_rad} {RM} {CM} {RI} {Er} {Vinit}
end
ih_comp /branch_syn/vm 1 {branchcomps}  {g_ih} {type}

	/**calcium **/
ca_buf_ip3_2D /branch_syn {branchcyls} 1 {syn_br_rad} {shellsize} {(branchcomps*branchlen1)} {ERfactor} {concen} {umole}
cytpumpcomp /branch_syn/Cacyts1 /extracell pmca {branchcyls} {Vpmca} {kpmca} {pmca_power} {mmole}
for (i=1; i<={branchcomps}; i=i+1)
  ncxcomp /branch_syn/Cacyts1 /branch_syn/vm[{i}] extracell {(i-1)*5+1} {i*5} {Vncx} {kncx}
end
setsercaleak /branch_syn/Cacyt /branch_syn/CaER 1 {branchcyls} {serca}

	/**calcium dependent channels**/
for (i=1; i<={branchcomps}; i=i+1)
  kleak_comp /branch_syn/vm[{i}] /branch_syn/Cacyts1 {(i-1)*5+1} {i*5} {gleak}
end

	/**clocks **/
useclock /branch_syn/vm[] 0
useclock /branch_syn/Cacyt[]/pmca 2
useclock /branch_syn/Cacyt[]/ncx 2
useclock /branch_syn/Cacyt[]/cytleak 2
useclock /branch_syn/vm[]/ih 2
useclock /branch_syn/Cacyts1[]/kleak 3

/***branch without GABA synapses ***/
        /**voltage compartment **/
create neutral /branch
for (i=1; i<={branchcomps}; i=i+1)
  Vcomp /branch/vm[{i}] {branchlen1} {syn_br_rad} {RM} {CM} {RI} {Er} {Vinit}
end
ih_comp /branch/vm 1 {branchcomps}  {g_ih} {type}

	/**calcium **/
ca_buf_ip3_2D /branch {branchcyls} 1 {syn_br_rad} {shellsize} {(branchlen1*branchcomps)} {ERfactor} {concen} {umole}
cytpumpcomp /branch/Cacyts1 /extracell pmca {branchcyls} {Vpmca} {kpmca} {pmca_power} {mmole}
for (i=1; i<={branchcomps}; i=i+1)
  ncxcomp /branch/Cacyts1 /branch/vm[{i}] extracell {(i-1)*5+1} {i*5} {Vncx} {kncx}
end
setsercaleak /branch/Cacyt /branch/CaER 1 {branchcyls} {serca}

	/**calcium dependent channels**/
for (i=1; i<={branchcomps}; i=i+1)
  kleak_comp /branch/vm[{i}] /branch/Cacyts1 {(i-1)*5+1} {i*5} {gleak}
end
	/**clocks **/
useclock /branch/vm[] 0
useclock /branch/Cacyt[]/pmca 2
useclock /branch/Cacyt[]/ncx 2
useclock /branch/Cacyt[]/cytleak 2
useclock /branch/vm[]/ih 2
useclock /branch/Cacyts1[]/kleak 3

/******************messages between compartments ***************/
/* messages between voltage compartments */
addmsg /rhab/vm /neck/vm RAXIAL Ra previous_state
addmsg /neck/vm /rhab/vm AXIAL previous_state
addmsg /neck/vm /soma/vm[1] RAXIAL Ra previous_state
addmsg /soma/vm[1] /neck/vm AXIAL  previous_state
addmsg /soma/vm[1] /axon/vm[1] RAXIAL Ra previous_state
addmsg /axon/vm[1] /soma/vm[1]  AXIAL  previous_state
addmsg /axon/vm[{axonslice}] /branch_syn/vm[1] RAXIAL Ra previous_state
addmsg /branch_syn/vm[1] /axon/vm[{axonslice}] AXIAL previous_state
addmsg /branch_syn/vm[1] /branch_syn/vm[2] RAXIAL Ra previous_state
addmsg /branch_syn/vm[2] /branch_syn/vm[1] AXIAL previous_state
addmsg /branch_syn/vm[2] /branch_syn/vm[3] RAXIAL Ra previous_state
addmsg /branch_syn/vm[3] /branch_syn/vm[2] AXIAL previous_state
addmsg /axon/vm[{axonslice}] /branch/vm[1] RAXIAL Ra previous_state
addmsg /branch/vm[1] /axon/vm[{axonslice}] AXIAL previous_state
addmsg /branch/vm[1] /branch/vm[2] RAXIAL Ra previous_state
addmsg /branch/vm[2] /branch/vm[1] AXIAL previous_state
addmsg /branch/vm[2] /branch/vm[3] RAXIAL Ra previous_state
addmsg /branch/vm[3] /branch/vm[2] AXIAL previous_state


/* messages between rxnpool compartments */
difcyl /rhab/ip3s2[{rhabcyls}] /neck/ip3s1[1] /rhab/neck_ip3dif {ip3dif} {umole}
difcyl /neck/ip3s1[1] /soma/ip3s2[1] /neck/soma_ip3dif {ip3dif} {umole}
difcyl /soma/ip3s2[{somacyls}] /axon/ip3s1[1] /soma/axon_ip3dif {ip3dif} {umole}
difcyl /axon/ip3s1[{axoncyls}] /branch_syn/ip3s1[1] /axon/brsyn_ip3dif {ip3dif} {umole}
difcyl /axon/ip3s1[{axoncyls}] /branch/ip3s1[1] /axon/branch_ip3dif {ip3dif} {umole}

useclock /neck/soma_ip3dif 3
useclock /rhab/neck_ip3dif 3
useclock /soma/axon_ip3dif 3
useclock /axon/brsyn_ip3dif 3
useclock /axon/branch_ip3dif 3

difcyl /rhab/Cacyts2[{rhabcyls}] /neck/Cacyts1[1] /rhab/neck_Cacytdif {Cadif} {mmole}
difcyl /neck/Cacyts1[1] /soma/Cacyts2[1] /neck/soma_Cacytdif {Cadif} {mmole}
difcyl /soma/Cacyts2[{somacyls}] /axon/Cacyts1[1] /soma/axon_Cacytdif {Cadif} {mmole}
difcyl /axon/Cacyts1[{axoncyls}] /branch_syn/Cacyts1[1] /axon/brsyn_Cacytdif {Cadif} {mmole}
difcyl /axon/Cacyts1[{axoncyls}] /branch/Cacyts1[1] /axon/branch_Cacytdif {Cadif} {mmole}




