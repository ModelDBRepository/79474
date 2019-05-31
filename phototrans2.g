//CHEMESIS2.0
//phototrans.g
//stochastic activation of rhodopsin in individual microvilli

function phototrans (ip3path)
 
create neutral /rhabmemb
ce /rhabmemb

int cyl, i
float value, cumvalue
float slice_volume, vil_volume, vil_xarea, vil_sa

/******* light stimulus **********/
create pulsegen shutter
setfield shutter      \
  baselevel 0  \ 
  level1 {intensity} \ /* photon rate (msec-1) during light on */
  width1 {duration} \ /* specify in units of time, not steps */
  delay1 {lightdelay} \ /* specify in units of time, not steps */
  delay2 99999  \
  trig_mode 0 \
  trig_time 0

create randomspike light
setfield light min_amp 0 max_amp 1.0 rate 0
addmsg shutter light RATE output

/****setup phototransduction in ncyls membrane compartments of rhabdomere **/ 
            /* outerrad*outerrad - innerrad*innerrad */
slice_volume=PI*(rhabrad*rhabrad-(rhabcorerad*rhabcorerad))*(rhablen/rhabcyls)/1000
vil_xarea=PI*rhabvilrad*rhabvilrad
vil_volume=vil_xarea*rhabvillen/1000
vil_sa=PI*rhabvilrad*2*rhabvillen
int slice_vil = numvilli/rhabcyls
echo {slice_vil}

for (cyl = 1; cyl <= rhabcyls; cyl=cyl+1)

/*******rhodopsin activation and inactivation***********/

	create rhodopsin mrhod[{cyl}]
	setfield mrhod[{cyl}] \
		slice {cyl} \
		total_villi {numvilli} \
		slice_villi {slice_vil} \
		villus_vol {vil_volume} \
		villus_xarea {vil_xarea} \
		villus_sa {vil_sa} \
		inact_const {Krkcat*Krkf*RKArrtot/(Krkcat+Krkb)} \
		len {rhabvillen} \
		radius {rhabvilrad} \
		depletion {deplete_power} \
		factor[1] 1 factor[2] 1.9 factor[3] 2.7 factor[4] 3.4 factor[5] 4.02 \
		factor[6] 4.56 factor[7] 5.0 factor[8] 5.4 factor[9] 5.74 factor[0] 0 \
		units {umole}
	cumvalue=0
	for (i=1; i<10; i=i+1)
		value=1/{sqrt {i}}
		cumvalue=cumvalue+value
		setfield mrhod[{cyl}] factor[{i}] {cumvalue}
	end
	addmsg light mrhod[{cyl}] ISOM state

	create randomspike inact[{cyl}]
	setfield inact[{cyl}]  min_amp 0 max_amp 1.0 rate 0
	addmsg mrhod[{cyl}] inact[{cyl}] RATE inact_rate
	addmsg inact[{cyl}] mrhod[{cyl}] INACT state

        /*** calcium feedback to arrestin activity ***/
/*   setfield RKcomplex[{cyl}] form {RKform} pow 1 thresh {RKthresh} halfmax {RKhalf} sign 1
   addmsg {capath}[{cyl}] RKcomplex[{cyl}] FEEDBACK Conc {RKwhich}
*/
 
/********* G protein *******************************/
        /*** Gprotein pools ***/
   create enzyme mrhoGprot[{cyl}]
   setfield mrhoGprot[{cyl}] kf {Kgf} kb {Kgb} kcat {Kgcat} type {quant} units {umole}
   pool2D Ga[{cyl}] {rhabrad} {rhabrad-rhabvillen} {rhablen/rhabcyls} 0 {quant} {umole}
   conservepool Gprot[{cyl}] {Gtot} {slice_volume} {quant} {umole}
   pool2D Ginact[{cyl}] {rhabrad} {rhabrad-rhabvillen} {rhablen/rhabcyls} 0 {quant} {umole}

        /*** messages to set up reaction ***/
   addmsg mrhod[{cyl}] mrhoGprot[{cyl}] RHODOPSIN effective slice_vol slice_xarea slice_sa
   addmsg mrhod[{cyl}] Gprot[{cyl}] VOLUME slice_vol
   addmsg Gprot[{cyl}] mrhoGprot[{cyl}] SUBSTRATE Conc

   addmsg mrhoGprot[{cyl}] Ga[{cyl}] RXN0MOLES deltacat
   addmsg mrhoGprot[{cyl}] Ga[{cyl}] VOLUME vol SAin SAout

	/*** decrement Gprot conservepool by Ga and mrhoGprot amount ***/
   addmsg mrhoGprot[{cyl}] Gprot[{cyl}] MOLES complex_quant
   addmsg Ga[{cyl}] Gprot[{cyl}] MOLES quantity

        /*** degradation of active Ga & production of Ginact ***/
   create reaction gadeg[{cyl}]
   setfield gadeg[{cyl}] kf {Khyd}
   addmsg Ga[{cyl}] gadeg[{cyl}] SUBSTRATE quantity
   addmsg gadeg[{cyl}] Ga[{cyl}] RXN1 kf
   addmsg gadeg[{cyl}] Ginact[{cyl}] RXN0MOLES kfsubs
   addmsg Ga[{cyl}] Ginact[{cyl}] VOLUME vol SAin SAout
   addmsg Ginact[{cyl}] Gprot[{cyl}] MOLES quantity
  
/******** plc reaction and GAP activity ***************/
	/*** pool of PLCtot and plcGa ***/
   pool2D plcGqa[{cyl}] {rhabrad} {rhabrad-rhabvillen} {rhablen/rhabcyls} 0 {quant} {umole}
   conservepool PLC[{cyl}] {plctot} {slice_volume} {quant} {umole}

	/*** volume and SA messages */
   addmsg Ga[{cyl}] plcGqa[{cyl}] VOLUME vol SAin SAout
   addmsg Ga[{cyl}] PLC[{cyl}] VOLUME vol

	/*** reaction between PLC and Ga ***/
   create reaction Ga_plc[{cyl}]
   setfield Ga_plc[{cyl}] kf {Kplcf} kb {Kplcb}

   addmsg Ga[{cyl}] Ga_plc[{cyl}] SUBSTRATE quantity
   addmsg PLC[{cyl}] Ga_plc[{cyl}] SUBSTRATE Conc
   addmsg plcGqa[{cyl}] Ga_plc[{cyl}] PRODUCT quantity
   addmsg Ga_plc[{cyl}] Ga[{cyl}] RXN2MOLES kbprod kfsubs
   addmsg Ga_plc[{cyl}] plcGqa[{cyl}] RXN2MOLES kfsubs kbprod

	/*** decrement PLC and Gprot conservepools by plcGa amount ***/
   addmsg plcGqa[{cyl}] PLC[{cyl}] MOLES quantity
   addmsg plcGqa[{cyl}] Gprot[{cyl}] MOLES quantity

	/*** degradation of plcGa via GAP activity ***/
   create reaction GAP[{cyl}]
   setfield GAP[{cyl}] kf {Kgap}
   addmsg plcGqa[{cyl}] GAP[{cyl}] SUBSTRATE quantity
   addmsg GAP[{cyl}] plcGqa[{cyl}] RXN1 kf
   addmsg GAP[{cyl}] Ginact[{cyl}] RXN0MOLES kfsubs

/*****************IP3 production by PLC action on PIP2 ************/
	/*** pool of PIP2 (IP3 already created) ***/
	/*** don't use conserve pool because IP3 diffuses and degrads in multiple  compartments ***/
   pool2D pip2[{cyl}] {rhabrad} {rhabrad-rhabvillen} {rhablen/rhabcyls} {piptot} {quant} {umole}
   pool2D plcPI[{cyl}] {rhabrad} {rhabrad-rhabvillen} {rhablen/rhabcyls} 0 {quant} {umole}
   create reaction plc_pip[{cyl}]
   setfield plc_pip[{cyl}] kf {Kpif} kb {Kpib}

	/*** messages to compute enzyme complex ***/
   addmsg pip2[{cyl}] plc_pip[{cyl}] SUBSTRATE Conc
   addmsg plcGqa[{cyl}] plc_pip[{cyl}] SUBSTRATE quantity
   addmsg plcPI[{cyl}] plc_pip[{cyl}] PRODUCT quantity

   addmsg plc_pip[{cyl}] plcGqa[{cyl}] RXN2MOLES kbprod kfsubs
   addmsg plc_pip[{cyl}] pip2[{cyl}] RXN2MOLES kbprod kfsubs
   addmsg plc_pip[{cyl}] plcPI[{cyl}] RXN2MOLES kfsubs kbprod

	/* volume messages from enzyme to substrate and product pools */
   addmsg plcGqa[{cyl}] plcPI[{cyl}] VOLUME vol SAin SAout
   addmsg plcGqa[{cyl}] pip2[{cyl}] VOLUME vol SAin SAout
   addmsg plcGqa[{cyl}] {ip3path}[{cyl}] VOLUME vol SAin SAout

	/*** reaction to create ip3 and produce plc and Ginact***/
   create reaction plcPIgap[{cyl}]
   setfield plcPIgap[{cyl}] kf {Kpicat2}

   addmsg plcPI[{cyl}] plcPIgap[{cyl}] SUBSTRATE quantity
   addmsg plcPIgap[{cyl}] plcPI[{cyl}] RXN1 kf
   addmsg plcPIgap[{cyl}] {ip3path}[{cyl}] RXN0MOLES kfsubs
   addmsg plcPIgap[{cyl}] Ginact[{cyl}] RXN0MOLES kfsubs

	/*** reaction to create ip3 and regenerate plcGqa***/
   create reaction plcPIenz[{cyl}]
   setfield plcPIenz[{cyl}] kf {Kpicat1} 

   addmsg plcPI[{cyl}] plcPIenz[{cyl}] SUBSTRATE quantity
   addmsg plcPIenz[{cyl}] plcPI[{cyl}] RXN1 kf
   addmsg plcPIenz[{cyl}] {ip3path}[{cyl}] RXN0MOLES kfsubs
   addmsg plcPIenz[{cyl}] plcGqa[{cyl}] RXN0MOLES kfsubs

   addmsg plcPI[{cyl}] Gprot[{cyl}] MOLES quantity
   addmsg plcPI[{cyl}] PLC[{cyl}] MOLES quantity
end

useclock /rhabmemb/#[] 2

ce /

end


function step2isom
float isom
    while (isom == 0)
        showfield /rhabmemb/light state
        showfield /rhabmemb/mrhod[1] total_time
        step
        isom={getfield /rhabmemb/mrhod[1] last_isom}
    end
    isom=0
    showfield /rhabmemb/light state
end
