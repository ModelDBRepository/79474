//CHEMESIS1.0
//rxn-func.g
// functions to create pools and setup reactions


function make2ndorderrxn(sub1,sub2,prod,rxn,kfor,kbac,type)

/* This is used for calcium (sub1) binding to buffer (sub2); 
** product (bound buffer) is conserved if type=1*/

   str sub1,sub2,prod,rxn
   float kfor,kbac
   int type
   
   create reaction {rxn} 
   setfield ^ \
	kf	{kfor}	\/* per mM-mSec.*/
	kb	{kbac}	 /* per mSec */

/* Send substrate and product conc to reaction */
addmsg {sub1} {rxn} SUBSTRATE Conc
addmsg {sub2} {rxn} SUBSTRATE Conc
addmsg {prod} {rxn} PRODUCT Conc

/* Send A and B state variables to substrates */
addmsg {rxn} {sub1} RXN2 kbprod kfsubs
addmsg {rxn} {sub2} RXN2 kbprod kfsubs
if (type == 1)
  addmsg {sub2} {prod} CONC Conc
end
if (type == 0)
  addmsg {rxn} {prod} RXN2 kfsubs kbprod
end
end
/********************************************************************/

function rxncomp2D (sub1,sub2,prod,rxn,nshell, ncyl,kfor,kbac,type)

str sub1, sub2, prod, rxn
float kfor,kbac
int ncyl,nshell
int type

int cyl, shell

/* shell index first, cyl index second */

  for (cyl=1; cyl<=ncyl; cyl=cyl+1)
    for (shell=1; shell<=nshell; shell=shell+1)
      make2ndorderrxn {sub1}s{shell}[{cyl}] {sub2}s{shell}[{cyl}] {prod}s{shell}[{cyl}] {rxn}s{shell}[{cyl}] {kfor} {kbac} {type}
    end
  end
end
/********************************************************************/

function rxncomp1D (sub1,sub2,prod,rxn,ncyl,kfor,kbac,type)

str sub1, sub2, prod, rxn
float kfor,kbac
int ncyl
int type

int cyl

  for (cyl=1; cyl<=ncyl; cyl=cyl+1)
      make2ndorderrxn {sub1}[{cyl}] {sub2}[{cyl}] {prod}[{cyl}] {rxn}[{cyl}] {kfor} {kbac} {type}
  end

end
/********************************************************************/


function makepump(cytpath,erpath,maxrate,expon,halfconc, unit)
   str cytpath, erpath
   float maxrate, halfconc, unit
   int expon
   
   create mmpump {cytpath}/serca
   setfield ^ \
      power {expon} \
      half_conc {halfconc} \
      max_rate {maxrate} \
      units {unit}
      
addmsg {cytpath} {cytpath}/serca CONC Conc
addmsg {cytpath}/serca {cytpath} RXN0MOLES moles_out
addmsg {cytpath}/serca {erpath} RXN0MOLES moles_in

end

/********************************************************************/
function makeleak(cytpath,erpath,maxrate,expon, unit)
   str cytpath, erpath
   float maxrate, unit
   int expon
   
   create cicrflux {cytpath}/leak
   setfield ^ \
      power {expon} \
      maxflux {maxrate} \
      units {unit}
      
addmsg {cytpath} {cytpath}/leak CONC1 Conc
addmsg {erpath} {cytpath}/leak CONC2 Conc
addmsg {cytpath} {cytpath}/leak IP3R 1
addmsg {cytpath}/leak {cytpath} RXN0MOLES deltaflux1
addmsg {cytpath}/leak {erpath} RXN0MOLES deltaflux2

end
/**************************************************************/

function makedegrad(path, pool, numcyls, degrad)
str path
int numcyls
float degrad

int cyl

   create reaction {path}{pool}degrad
   setfield ^ kf {degrad}

   for (cyl=1; cyl<=numcyls; cyl=cyl+1)
       addmsg {path}{pool}degrad {path}{pool}[{cyl}] RXN1 kf
   end
end

/*********************************************************************/

function degrad2D (path, pool, nshell, ncyl, degrad)

str path, pool
int ncyl, nshell
float degrad

int cyl, shell

   create reaction {path}{pool}degrad
   setfield ^ kf {degrad}

/* shell index first, cyl index second */

  for (cyl=1; cyl<= ncyl; cyl=cyl+1)
    for (shell=1; shell<=nshell; shell=shell+1)
	addmsg {path}{pool}degrad {path}{pool}s{shell}[{cyl}] RXN1 kf
    end
  end

end
















