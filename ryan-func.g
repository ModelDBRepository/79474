//ryan-func.g CHEMESIS1.0 
// sets up cicr objects and communication between them for ryanodine receptor
// parameters: betaf, betab, gammaf, gammab = l1, l-1, l2, l-2 from Tang & Othmer 
// Units of per uM-sec equal per mM-msec.  Units of per sec - e-3 per msec

function makecicr(path)
   str path
	
   create cicr {path}/x00
   setfield {path}/x00 \
	alpha_state	0 \
	beta_state	0 \
	gamma_state	0 \
	alpha	0 \
	beta	15 \		/* l1 Tang and Ottmer, 15 per sec-uM*/
	gamma	0.8 \		/* l2 Tang and Ottmer 0.8 per sec-uM*/
	conserve	0 \
	xinit		{init00} \
	xmin		0 \
	xmax		1
	
   create cicr {path}/x10
   setfield ^ \
	alpha_state	0 \
	beta_state	1 \
	gamma_state	0 \
	alpha	0 \
	beta	7.6e-3 \	/* L-1 Tang and Ottmer 7.6/ sec = 7.6e-3/msec*/
	gamma	0.8 \		/* L2 Tang and Ottmer */
	conserve	0 \
	xinit		{init10} \
	xmin		0 \
	xmax		1
	
   create cicr {path}/x01
   setfield ^ \
	alpha_state	0 \
	beta_state	0 \
	gamma_state	1 \
	alpha	0 \
	beta	15 \		/* l1 Tang and Ottmer */
	gamma	0.84e-3 \	/* L-2 Tang and Ottmer 0.84/sec = 0.84e-3/msec*/
	conserve	0 \
	xinit		{init01} \
	xmin		0 \
	xmax		1
	
   create cicr {path}/x11
   setfield ^ \
	alpha_state	0 \
	beta_state	1 \
	gamma_state	1 \
	alpha	0 \
	beta	7.6e-3 \	/* L-1 Tan and Ottmer */
	gamma	0.84e-3 \	/* L-2 Tan and Ottmer */
	conserve	1 \
	xinit		{1-init00-init01-init10} \
	xmin		0 \
	xmax		1

addmsg {path}/x10 {path}/x00 BSTATE beta fraction
addmsg {path}/x01 {path}/x00 GSTATE gamma fraction

addmsg {path}/x00 {path}/x10 BSTATE beta previous_state
addmsg {path}/x11 {path}/x10 GSTATE gamma fraction

addmsg {path}/x11 {path}/x01 BSTATE beta fraction
addmsg {path}/x00 {path}/x01 GSTATE gamma previous_state

addmsg {path}/x00 {path}/x11 CONSERVE previous_state
addmsg {path}/x01 {path}/x11 CONSERVE previous_state
addmsg {path}/x10 {path}/x11 CONSERVE previous_state

end

/********************************************************/
// must create ca and er compartments first

function makecicrflux(Capath,erpath,maxcond,expon, unit)
   str Capath,erpath
   float maxcond, unit
   int expon
   
   create cicrflux {Capath}/ryanflux
   setfield {Capath}/ryanflux \
	power {expon} \	/* open fraction = x10^power */
	maxflux {maxcond} \
	units {unit}

/* Messages from cytosolic calcium to ryanodine receptor channel states */
addmsg {Capath} {Capath}/x00 CALCIUM Conc	
addmsg {Capath} {Capath}/x10 CALCIUM Conc
addmsg {Capath} {Capath}/x01 CALCIUM Conc
	
/*Messages to cicr flux  (compute channel permeability) */

addmsg {Capath} {Capath}/ryanflux CONC1 Conc
addmsg {erpath} {Capath}/ryanflux CONC2 Conc
addmsg {Capath}/x10 {Capath}/ryanflux IP3R fraction

/* Messages back to cytosol and er */

addmsg {Capath}/ryanflux {Capath} RXN0MOLES deltaflux1
addmsg {Capath}/ryanflux {erpath} RXN0MOLES deltaflux2

end

/********************************************************************/





