/********************************************************************/
/* calcium units are mmole */
function cytpumpcomp (cytcomp, extracell,pumptype, ncyl, vmax, km, power, unit)
float vmax, km, unit
str cytcomp, pumptype, extracell
int ncyl

float area, pumprate
int cyl

  for (cyl=1; cyl<=ncyl; cyl=cyl+1)

/* compute value of cytosolic pump from area */

	area = {getfield {cytcomp}[{cyl}] SAout}
	pumprate = vmax *  area

/* create cytosolic mmpump */

	create mmpump {cytcomp}[{cyl}]/{pumptype}
	setfield ^ \
		power {power} \
		half_conc {km} \
		max_rate {pumprate} \
		units {unit}

	addmsg {cytcomp}[{cyl}] {cytcomp}[{cyl}]/{pumptype} CONC Conc
	addmsg {cytcomp}[{cyl}]/{pumptype} {cytcomp}[{cyl}] RXN0MOLES moles_out
 
/* create leak from extracellular space to cytoplasm, if not already created */

     if (!{exists {cytcomp}[{cyl}]/cytleak})
	create cicrflux {cytcomp}[{cyl}]/cytleak
	setfield ^ power 1 maxflux 1 units {unit}

	addmsg {cytcomp}[{cyl}] {cytcomp}[{cyl}]/cytleak CONC1 Conc
	addmsg {extracell} {cytcomp}[{cyl}]/cytleak CONC2 Conc
	addmsg {cytcomp}[{cyl}] {cytcomp}[{cyl}]/cytleak IP3R 1
	addmsg {cytcomp}[{cyl}]/cytleak {cytcomp}[{cyl}] RXN0MOLES deltaflux1
     end
  end

end

/********************************************************************/
/* calcium units are mmole */
function ncxcomp (cacomp, vcomp, extracell, startcyl, endcyl, vmax, kmca)
str cacomp, vcomp, extracell
int startcyl, endcyl
float vmax, kmca

float pumprate, area
int cyl

  for (cyl=startcyl; cyl<=endcyl; cyl=cyl+1)

   /* compute value of cytosolic pump from area */
    area = {getfield {cacomp}[{cyl}] SAout}
	pumprate = {vmax} *  area

   /* create cytosolic ncx */
    create ncx {cacomp}[{cyl}]/ncx
    setfield ^ \
        T 293 \
        ncxtype 0 \
        Na_msg 0 \
        stoich 4 \
        hill 1 \
        Vunits 1e-3 \
        Na_int 37 \
        Na_ext 430 \
        Kmca {kmca} \
        Gbar {pumprate}

    addmsg {cacomp}[{cyl}] {cacomp}[{cyl}]/ncx CAINT Conc
    addmsg {extracell} {cacomp}[{cyl}]/ncx CAEXT Conc
    addmsg {vcomp} {cacomp}[{cyl}]/ncx VM Vm
    addmsg {cacomp}[{cyl}]/ncx {cacomp}[{cyl}] CURRENT valence I
    addmsg {cacomp}[{cyl}]/ncx {vcomp} CHANNEL Gcurrent Vnaca
  end
end
/********************************************************************/
function setcytpumpleak(cytpath, excell, ncyls, Vpmca, Kpmca, Vncx, Kncx)
  str cytpath, excell
  float Vpmca, Kpmca, Vncx, Kncx
  int ncyls

  float ncxrate, pmcarate
  float pca, tca, Iflux
  float leak1, leak2, leak, leakrate
  float unit
  float area, Ceq, Caext
  int cyl

  for (cyl=1; cyl<= ncyls; cyl=cyl+1)

   /* first area and equilibrium calcium of compartment.*/
    	area = {getfield {cytpath}[{cyl}] SAout}
    	Ceq = {getfield {cytpath}[{cyl}] Cinit}
	Caext = {getfield {excell} Cinit}
	leak1 = 0
	leak2 = 0

   /* next, set value of pmca pump and ncx exchange */

	pmcarate = Vpmca*{area}
	if ({exists {cytpath}[{cyl}]/pmca})
   		setfield {cytpath}[{cyl}]/pmca max_rate {pmcarate} half_conc {Kpmca}
	end

	ncxrate = Vncx*{area}
	if ({exists {cytpath}[{cyl}]/ncx})
	   	setfield {cytpath}[{cyl}]/ncx Gbar {ncxrate} Kmca {Kncx}
	end

    if (cyl==1)
        echo "IN setcytpumpleak" "Ceq=" {Ceq} "kpmca=" {Kpmca} "kncx=" {Kncx}
        echo {cytpath}[{cyl}] "area="{area} "Vpmca="{pmcarate} "Vncx="{ncxrate}
    end

/* reset will compute the resting values of the pump */
    call {cytpath}[{cyl}]/pmca RESET
    call {cytpath}[{cyl}]/ncx RESET

/* compute the molecules of calcium pumped out at rest */

    leak1 = {getfield {cytpath}[{cyl}]/pmca moles_out}
    leak2 = -1.02*{getfield {cytpath}[{cyl}]/ncx I}*1e-12*6.023e23/(-2*96485)

   /* next, compute flux from calcium currents */
	if ({exists {cytpath}[{cyl}]/persist_ghk_ica})
		pca = {getfield {cytpath}[{cyl}]/persist_ghk_ica I}
	else
		pca = 0
	end

	if ({exists {cytpath}[{cyl}]/trans_ghk_ica})
		tca = {getfield {cytpath}[{cyl}]/trans_ghk_ica I}
	else 
		tca = 0
	end

	Iflux = -(pca+tca) *1e-12*6.023e23/(2*96495)
    if (cyl==1)
        echo "pca=" {pca} "tca=" {tca} "flux=" {Iflux} "inward is >0"
    end

   /* compute Leak value s.t. when C = Ceq = Cinit, leak + Ica = total pump value */
   
	unit = {getfield {cytpath}[{cyl}]/cytleak units}
	leak = -(leak1 + leak2 + Iflux)/(Caext - Ceq)/({unit}*6.023e23)

	if (leak < 0); leak=0; end
    leakrate = {leak} / {area}
    if (cyl==1)
        echo "pmcaflux="{leak1} "ncxflux="{leak2} "maxflux="{leak} "leakrate="{leakrate}
    end
   	setfield {cytpath}[{cyl}]/cytleak maxflux {leak}   
  end
end
