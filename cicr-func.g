//genesis cicr-func.g
// sets up cicr objects and communication between them
// parameters are ai, bi, gi = alphai/k3, betai/k3, gammai/k3 from Li & Rinzel
// L&R units are per uM-sec  = per mM-msec

/* revised 02-11-02 for uM-msec units */
/* a_0xx = alpha_0xx/0.1 uM, a_0xx= 40 per sec/0.1 uM = 400 per sec uM
   = 400e-3 per msec uM
   b_1x0 = alpha_11x = 52 per sec -> 52e-3 per msec  (no change)
   b_1x1 = alpha_10x = 377.36 per sec -> 377.36e-3 per msec   (no change)
 other rate constants (beta and gamma) depend on calcium - no change */

function makeiicr(path)
   str path
	
   create cicr {path}/x000
   setfield {path}/x000 \
	alpha_state	0 \
	beta_state	0 \
	gamma_state	0 \
	alpha	400e-3 \
	beta	2e1 \
	gamma	2e-1 \
	conserve	0 \
	xinit		{init000} \
	xmin		0 \
	xmax		1
	
   create cicr {path}/x100
   setfield ^ \
	alpha_state	1 \
	beta_state	0 \
	gamma_state	0 \
	alpha	52e-3 \
	beta	2e1 \
	gamma	2e-1 \
	conserve	0 \
	xinit		{init100} \
	xmin		0 \
	xmax		1 
	
   create cicr {path}/x010
   setfield ^ \
	alpha_state	0 \
	beta_state	1 \
	gamma_state	0 \
	alpha	400e-3 \
	beta	1.6468e-3 \
	gamma	2e-1 \
	conserve	0 \
	xinit		{init010} \
	xmin		0 \
	xmax		1
	
   create cicr {path}/x001
   setfield ^ \
	alpha_state	0 \
	beta_state	0 \
	gamma_state	1 \
	alpha	400e-3 \
	beta	2e1 \
	gamma	0.0289e-3 \
	conserve	0 \
	xinit		{init001} \
	xmin		0 \
	xmax		1
	
   create cicr {path}/x101
   setfield ^ \
	alpha_state	1 \
	beta_state	0 \
	gamma_state	1 \
	alpha	377.36e-3 \
	beta	2e1 \
	gamma	0.2089e-3 \
	conserve	0 \
	xinit		{init101} \
	xmin		0 \
	xmax		1
	
   create cicr {path}/x011
   setfield ^ \
	alpha_state	0 \
	beta_state	1 \
	gamma_state	1 \
	alpha	400e-3 \
	beta	1.6468e-3 \
	gamma	0.0289e-3 \
	conserve	0 \
	xinit		{init011} \
	xmin		0 \
	xmax		1

   create cicr {path}/x110
   setfield ^ \
	alpha_state	1 \
	beta_state	1 \
	gamma_state	0 \
	alpha	52e-3 \
	beta	1.6468e-3 \
	gamma	2e-1 \
	conserve	0 \
	xinit		{init110} \
	xmin		0  \
	xmax		1
	
   create cicr {path}/x111
   setfield ^ \
	alpha_state	1 \
	beta_state	1 \
	gamma_state	1 \
	alpha	377.36e-3 \
	beta	1.6468e-3 \
	gamma	0.2098e-3 \
	conserve	1 \
	xinit		{1-init000-init100-init010-init001-init101-init110-init011} \
	xmin		0  \
	xmax		1

addmsg {path}/x100 {path}/x000 ASTATE alpha fraction
addmsg {path}/x010 {path}/x000 BSTATE beta fraction
addmsg {path}/x001 {path}/x000 GSTATE gamma fraction
	
addmsg {path}/x000 {path}/x100 ASTATE alpha previous_state
addmsg {path}/x110 {path}/x100 BSTATE beta fraction
addmsg {path}/x101 {path}/x100 GSTATE gamma fraction
	
addmsg {path}/x110 {path}/x010 ASTATE alpha fraction
addmsg {path}/x000 {path}/x010 BSTATE beta previous_state
addmsg {path}/x011 {path}/x010 GSTATE gamma fraction
	
addmsg {path}/x101 {path}/x001 ASTATE alpha fraction
addmsg {path}/x011 {path}/x001 BSTATE beta fraction
addmsg {path}/x000 {path}/x001 GSTATE gamma previous_state
	
addmsg {path}/x010 {path}/x110 ASTATE alpha previous_state
addmsg {path}/x100 {path}/x110 BSTATE beta previous_state
addmsg {path}/x111 {path}/x110 GSTATE gamma fraction
	
addmsg {path}/x001 {path}/x101 ASTATE alpha previous_state
addmsg {path}/x111 {path}/x101 BSTATE beta fraction
addmsg {path}/x100 {path}/x101 GSTATE gamma previous_state
	
addmsg {path}/x111 {path}/x011 ASTATE alpha fraction
addmsg {path}/x001 {path}/x011 BSTATE beta previous_state
addmsg {path}/x010 {path}/x011 GSTATE gamma previous_state

addmsg {path}/x000 {path}/x111 CONSERVE previous_state
addmsg {path}/x001 {path}/x111 CONSERVE previous_state
addmsg {path}/x010 {path}/x111 CONSERVE previous_state
addmsg {path}/x100 {path}/x111 CONSERVE previous_state
addmsg {path}/x110 {path}/x111 CONSERVE previous_state
addmsg {path}/x101 {path}/x111 CONSERVE previous_state
addmsg {path}/x011 {path}/x111 CONSERVE previous_state

end

