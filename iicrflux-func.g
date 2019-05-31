//iicrflux-func.g  CHEMESIS1.0
// must create ca,er,ip3 compartments first

function makeiicrflux(Capath,erpath,ip3path,maxcond,exponen, unit)
   str Capath,erpath,ip3path
   float maxcond, unit
   int exponen
   
   create cicrflux {Capath}/iicrflux
   setfield {Capath}/iicrflux \
	power {exponen} \	/* open fraction = x110^power */
	maxflux {maxcond} \
	units {unit}

/* Messages from cytosolic calcium to iicr receptor channel states */
addmsg {Capath} {Capath}/x100 CALCIUM Conc	
addmsg {Capath} {Capath}/x000 CALCIUM Conc	
addmsg {Capath} {Capath}/x010 CALCIUM Conc
addmsg {Capath} {Capath}/x001 CALCIUM Conc
addmsg {Capath} {Capath}/x110 CALCIUM Conc	
addmsg {Capath} {Capath}/x101 CALCIUM Conc	
addmsg {Capath} {Capath}/x011 CALCIUM Conc	

/* Messages from cytosolic IP3 compartment to iicr receptor states */
addmsg {ip3path} {Capath}/x000 IP3 Conc	
addmsg {ip3path} {Capath}/x100 IP3 Conc	
addmsg {ip3path} {Capath}/x010 IP3 Conc	
addmsg {ip3path} {Capath}/x001 IP3 Conc	
addmsg {ip3path} {Capath}/x110 IP3 Conc	
addmsg {ip3path} {Capath}/x101 IP3 Conc	
addmsg {ip3path} {Capath}/x011 IP3 Conc	
  
	
/*Messages to iicr flux  (compute channel permeability) */

addmsg {Capath} {Capath}/iicrflux CONC1 Conc
addmsg {erpath} {Capath}/iicrflux CONC2 Conc
addmsg {Capath}/x110 {Capath}/iicrflux IP3R fraction

/* Messages back to core and er */

addmsg {Capath}/iicrflux {Capath} RXN0MOLES deltaflux1
addmsg {Capath}/iicrflux {erpath} RXN0MOLES deltaflux2

end

/********************************************************************/
function setsercaleak(cytpath, erpath, nshells, ncyls, sercarate)
  str cytpath, erpath
  float sercarate
  int nshells, ncyls

  float serca, area, leak, Ceq, CaER
  int shell, cyl, cylER
  str shellpath, ERshellpath
  float L1, L2, cicrflux, x10ss, sercaflux

/* shell index first, cyl index second */

   for (shell=1; shell<=nshells; shell=shell+1)
      shellpath = (cytpath)@"s"@(shell)
      ERshellpath = (erpath)@"s"@(shell)
      for (cyl=1; cyl<= ncyls; cyl=cyl+1)

   /* first compute serca from the values specified as per unit area,
    * by multiplying by cytosolic area*/

    	  area = {getfield {shellpath}[{cyl}] vol}
    	  serca = sercarate * area

   /* compute Leak value is s.t. when C = Ceq = Cinit, leak = serca+ryrflux */
   /*leak is smaller than if no ryr, make sure it doesn't go negative */

   	  Ceq = {getfield {shellpath}[{cyl}] Cinit}
   	  CaER = {getfield {ERshellpath}[{cyl}] Cinit}
	  L1={getfield {shellpath}[{cyl}]/x10 beta}/{getfield {shellpath}[{cyl}]/x00 beta}
	  L2={getfield {shellpath}[{cyl}]/x01 gamma}/{getfield {shellpath}[{cyl}]/x00 gamma}
	  x10ss=L2*Ceq/(L1*L2 + (L1+L2)*Ceq+Ceq*Ceq)
	  cicrflux={getfield {shellpath}[{cyl}]/ryanflux maxflux}*x10ss
	  sercaflux=(serca * Ceq*Ceq) / (Ceq*Ceq + 0.1e-3*0.1e-3)
   	  leak = sercaflux/(CaER - Ceq) - cicrflux

	if (cyl==1)
echo {shellpath} "cicrflux="{cicrflux} "sercaflux="{sercaflux} "sercarate=" {leak}
	end

	  if (leak < 0) 
 		leak = 0
	  end

   	  setfield {shellpath}[{cyl}]/serca max_rate {serca}
   	  setfield {shellpath}[{cyl}]/leak maxflux {leak}   
  	end
  end

end
/********************************************************************/
function makecyt2er (cytpath, ip3path, erpath, iicrcond, niicr, cicrcond, ncicr, nshells, ncyls, sercarate, sercapower, unit)
 float iicrcond, cicrcond, sercarate, unit
 int niicr, ncicr, sercapower
 int nshells, ncyls
 str erpath, cytpath, ip3path

 int shell, cyl, cylER
 float iicrflux, cicrflux, area, leak
 str shellpath, ip3shellpath, ERshellpath

 for (shell=1; shell<=nshells; shell=shell+1)
    shellpath = (cytpath)@"s"@(shell)
    ip3shellpath=(ip3path)@"s"@(shell)
    ERshellpath = (erpath)@"s"@(shell)

    for (cyl=1; cyl<=ncyls; cyl=cyl+1)
          /*set up iicr and cicr (states of ip3 and ryan channels) */
	makeiicr {shellpath}[{cyl}]
	makecicr {shellpath}[{cyl}]

	  /*flux between er and each cytosol shell */
   	  /* first compute maxflux and serca from the values specified
    	   *  per unit area, by multiplying by cytosolic volume*/
    	area = {getfield {shellpath}[{cyl}] vol}
    	iicrflux = iicrcond * area
	cicrflux = cicrcond * area
   	makeiicrflux {shellpath}[{cyl}] {ERshellpath}[{cyl}] {ip3shellpath}[{cyl}] {iicrflux} {niicr} {unit}
	makecicrflux {shellpath}[{cyl}] {ERshellpath}[{cyl}] {cicrflux} {ncicr} {unit}

    /* set up serca pump and leak from er to cytosol with incorrect values */
    	makepump {shellpath}[{cyl}] {ERshellpath}[{cyl}] {sercarate} {sercapower} 0.1e-3 {unit}
    	makeleak {shellpath}[{cyl}] {ERshellpath}[{cyl}] {leak} 1 {unit}
     end

  end
	  /* set correct values of serca and leak */
  setsercaleak {cytpath} {erpath} {nshells} {ncyls} {sercarate}

end

