//CHEMESIS2.0
//gabab-syn.g

function gabab_synapse(vpath, length, radius, ip3path, type)
str vpath, ip3path
float length, radius
str type

echo {type}
ce {vpath}

float initcon	=	0
/* volume of cylinder in Liters from cm units */
float vol=PI*radius*radius*length/1000

/* receptor + transmitter <-> bound_receptor */

   conservepool unbound_recept {recept_tot} {vol} 0 1e-6 
   poolcyl bound_recept {length} {radius} {initcon} 0 1e-6 
  create reaction gaba_recept_rxn
  setfield gaba_recept_rxn kf {gabab_kf} kb {gabab_kb}  
  addmsg unbound_recept gaba_recept_rxn SUBSTRATE Conc
  addmsg /stat/spike gaba_recept_rxn SUBSTRATE state
  addmsg bound_recept gaba_recept_rxn PRODUCT Conc 
  addmsg gaba_recept_rxn bound_recept RXN2 kfsubs kbprod 
  addmsg bound_recept unbound_recept CONC Conc 

/* bound_receptor + Gprot <-> recept-gaba-Gprot -> bound_receptor + Galfstar */

/**** Old formulation, using mmenz ****
 **** This has no unbinding of G from receptor after producing G alpha
poolcyl RgabaGprot {length} {radius} {initcon} 0 1e-6
conservepool Gprot {Gprot_syn} {vol} 0 1e-6 
create reaction RG_Gprot_rxn
setfield RG_Gprot_rxn kf {gabab_gf} kb {gabab_gb}
addmsg bound_recept RG_Gprot_rxn SUBSTRATE Conc
addmsg Gprot RG_Gprot_rxn SUBSTRATE Conc
addmsg RgabaGprot RG_Gprot_rxn PRODUCT Conc
addmsg RG_Gprot_rxn bound_recept RXN2 kbprod kfsubs
addmsg RG_Gprot_rxn RgabaGprot RXN2 kfsubs kbprod
addmsg RgabaGprot unbound_recept CONC Conc
addmsg RgabaGprot Gprot CONC Conc

poolcyl Galfstar {length} {radius} {initcon} 0 1e-6
create mmenz RGGprot_enz
setfield RGGprot_enz Vmax {gabab_gcat}
addmsg RgabaGprot RGGprot_enz ENZ Conc
addmsg RGGprot_enz Galfstar RXN0 product
addmsg Galfstar Gprot CONC Conc
*** end of old formulation ****/

   poolcyl Galfstar {length} {radius} {initcon} 0 1e-6 
   poolcyl Gbg {length} {radius} {initcon} 0 1e-6 
   conservepool Gprot {Gprot_syn} {vol} 0 1e-6 
   create enzyme RgabaGprot
   setfield RgabaGprot kf {gabab_gf} kb {gabab_gb} kcat {gabab_gcat} type 0 units 1e-6 vol {vol}
   addmsg bound_recept RgabaGprot ENZ Conc
   addmsg Gprot RgabaGprot SUBSTRATE Conc
   addmsg RgabaGprot bound_recept RXN2 kbprod kfsubs 
   addmsg RgabaGprot Galfstar RXN0MOLES deltacat
   addmsg RgabaGprot Gbg RXN0MOLES deltacat

   addmsg RgabaGprot unbound_recept CONC complex_conc
   addmsg RgabaGprot Gprot CONC complex_conc 

/* Galphastar -> Ginact */
   poolcyl Ginact {length} {radius} {initcon} 0 1e-6
   create reaction galfdeg
   setfield galfdeg kf {Khyd}
   addmsg Galfstar galfdeg SUBSTRATE Conc
   addmsg galfdeg Galfstar RXN1 kf
   addmsg galfdeg Ginact RXN0 kfsubs
   addmsg Ginact Gprot CONC Conc
   addmsg Galfstar Gprot CONC Conc

/* plc + galfstar <-> plc-galpha */
conservepool plctot {plc_syn} {vol} 0 1e-6
poolcyl plcGa {length} {radius} {initcon} 0 1e-6
create reaction plc_rxn
setfield plc_rxn kf {Kplcf} kb {Kplcb}
addmsg Galfstar plc_rxn SUBSTRATE Conc
addmsg plctot plc_rxn SUBSTRATE Conc
addmsg plcGa plc_rxn PRODUCT Conc
addmsg plc_rxn plcGa RXN2 kfsubs kbprod
addmsg plc_rxn Galfstar RXN2 kbprod kfsubs
addmsg plcGa plctot CONC Conc
addmsg plcGa Gprot CONC Conc

/***** GAP activity of PLC causes degradation of PLC-Ga ***/
   create reaction GAP
   setfield GAP kf {Kgap}
   addmsg plcGa GAP SUBSTRATE Conc
   addmsg GAP plcGa RXN1 kf
   addmsg GAP Ginact RXN0 kfsubs

if (type=="mm")
   /***** plc + pip2 <-> ip3 + plc using mm kinetics ****/

   conservepool pip2 {piptot} {vol} 0 1e-6
   create mmenz pip2ip3

   /* divide the total activity over compartments 5-10 
    * ideally, would want to set Kpicat1 to correct value, and 
    * send 1/5 of quantity to each compartment.*/

   setfield pip2ip3 Vmax {Kpicat1/5} Km {({Kpicat1}+{Kpib})/{Kpif}}
   addmsg plcGa pip2ip3 ENZ quantity
   addmsg pip2 pip2ip3 SUBSTRATE Conc 

   int i
   for (i=5; i<=10; i=i+1)
      addmsg pip2ip3 {ip3path}[{i}] RXN0MOLES product
      addmsg {ip3path}[{i}] pip2 CONC Conc
   end
   /***** end of plc + pip2 <-> ip3 + plc using mm kinetics ****/

else

   /***** plc + pip2 <-> plcPI -> ip3 + plc using enzyme formulation ***/

   poolcyl pip2 {length} {radius} {piptot} 0 1e-6
   poolcyl plcPI {length} {radius} {initcon} 0 1e-6
   create reaction plc_pip
   setfield plc_pip kf {Kpif} kb {Kpib}

	/*** messages to compute enzyme complex ***/
   addmsg pip2 plc_pip SUBSTRATE Conc
   addmsg plcGa plc_pip SUBSTRATE quantity
   addmsg plcPI plc_pip PRODUCT quantity

   addmsg plc_pip plcGa RXN2MOLES kbprod kfsubs
   addmsg plc_pip plcPI RXN2MOLES kfsubs kbprod
   addmsg plc_pip pip2 RXN2MOLES kbprod kfsubs

   /* conserve pool messages */
   addmsg plcPI Gprot MOLES quantity
   addmsg plcPI plctot MOLES quantity

	/*** reaction to create ip3 and produce plc and Ginact***/
   create reaction plcPIgap
   setfield plcPIgap kf {Kpicat2}

   addmsg plcPI plcPIgap SUBSTRATE quantity
   addmsg plcPIgap plcPI RXN1 kf
   addmsg plcPIgap Ginact RXN0MOLES kfsubs

   /* ideally, should distribute ip3 to several compartments, but
    * can't do that with the present code, so ip3 from GAP goes to 6 and 
    * ip3 with plcGa regenerated goes to 9  ***/

   addmsg plcPIgap {ip3path}[6] RXN0MOLES kfsubs

   /** reaction to create ip3 and regenerate plcGqa ***/
   create reaction plcPIenz
   setfield plcPIenz kf {Kpicat1} 

   addmsg plcPI plcPIenz SUBSTRATE quantity
   addmsg plcPIenz plcPI RXN1 kf
   addmsg plcPIenz plcGa RXN0MOLES kfsubs

   addmsg plcPIenz {ip3path}[9] RXN0MOLES kfsubs

   /*** end of reaction formulation of enzymes ***/
end

/*** inactivation of Gbg - assume that Gbg combines with inactive Galpha 
 *** thus it's inacivation rate should be similar to that of Galpha ***/

   addmsg GAP Gbg RXN1 kf

end
