//cal-ip3-rhab.g CHEMESIS1.0
//repeat below for each axon compartment, and each branch compartment.

function ca_ip3_rhab (path, ncyls, nshells, radius, shellsize, length, ERfactor, quant, concen, unit)
str path
int ncyls, nshells
float radius, length, ERfactor, shellsize
float unit
int quant, concen

int cyl

/**  ip3 with diffusion and degradation ***/
  comp2D {path}/ip3 {radius} {nshells} {shellsize} {length/ncyls} {ncyls} {ip3init} {quant} {unit}
  /* axial diffusion for rhabdomere core (shell s2) */
  difcompcyl {path}/ip3s2 {ncyls} {ip3dif} {unit}
  /* radial diffusion for all rhabdomere cylinders */
  for (cyl=1; cyl<=ncyls; cyl=cyl+1)
	difsphere {path}/ip3s1[{cyl}] {path}/ip3s2[{cyl}] {path}/ip3s1_raddif[{cyl}] {ip3dif} {unit}
  end
  degrad2D {path} /ip3 {nshells} {ncyls} {ip3degrad}

/***  Calcium, Buffers, diffusion in cytosol ****/
  comp2D {path}/Cacyt {radius} {nshells} {shellsize} {length/ncyls} {ncyls} {Cacyt} {concen} 1e-3
  /* axial diffusion for rhabdomere core (shell s2) */
  difcompcyl {path}/Cacyts2 {ncyls} {Cadif} 1e-3
  /* radial diffusion for all rhabdomere cylinders */
  for (cyl=1; cyl<=ncyls; cyl=cyl+1)
	difsphere {path}/Cacyts1[{cyl}] {path}/Cacyts2[{cyl}] {path}/Cacyts1_raddif[{cyl}] {Cadif} 1e-3
  end
  comp2D {path}/bufcyt {radius} {nshells} {shellsize} {length/ncyls} {ncyls} {bufcyt} {concen} 1e-3
  consv2D {path}/bufbndcyt {nshells} {ncyls} {bufcyttot} {radius} {length/ncyls} {shellsize} {concen} 1e-3
  rxncomp2D {path}/Cacyt {path}/bufcyt {path}/bufbndcyt {path}/Cacyt_buf {nshells} {ncyls} {buf_kf} {buf_kb} 1

/***  Calcium, Buffers, diffusion in in ER ****/
  comp2D {path}/CaER {radius} {nshells} {shellsize} {ERfactor*length/ncyls} {ncyls} {CaER} {concen} 1e-3
  comp2D {path}/bufER {radius} {nshells} {shellsize} {ERfactor*length/ncyls} {ncyls} {bufER} {concen} 1e-3
  consv2D {path}/bufbndER {nshells} {ncyls} {bufERtot} {radius} {ERfactor*length/ncyls} {shellsize} {concen} 1e-3
  rxncomp2D {path}/CaER {path}/bufER {path}/bufbndER {path}/CaER_buf {nshells} {ncyls} {buf_kf} {buf_kb} 1

/* Calcium release through ip3 and ryanodine receptors, also serca and leak */
  makecyt2er {path}/Cacyt {path}/ip3 {path}/CaER {maxiicr} {iicrpower} {maxcicr} {cicrpower} {nshells} {ncyls} {serca} {pumppower} 1e-3

  useclock {path}/ip3s#[] 3
  useclock {path}/ip3s2_axdif[] 3
  useclock {path}/ip3s1_raddif[] 3
  useclock {path}/ip3degrad[] 3
  useclock {path}/Cacyts#[] 0
  useclock {path}/bufcyts#[] 0
  useclock {path}/bufbndcyts#[] 0
  useclock {path}/Cacyt_bufs#[] 0
  useclock {path}/Cacyts2_axdif[] 1
  useclock {path}/Cacyts1_raddif[] 1
  useclock {path}/bufERs#[] 1
  useclock {path}/bufbndERs#[] 1
  useclock {path}/CaERs#[] 1
  useclock {path}/CaER_bufs#[] 1
  useclock {path}/Cacyts#[]/x# 1
  useclock {path}/Cacyts#[]/iicrflux 1
  useclock {path}/Cacyts#[]/x00 2
  useclock {path}/Cacyts#[]/x01 2
  useclock {path}/Cacyts#[]/x10 2
  useclock {path}/Cacyts#[]/x11 2
  useclock {path}/Cacyts#[]/ryanflux 2
  useclock {path}/Cacyts#[]/serca 2
  useclock {path}/Cacyts#[]/leak 2

/* fast clocks required for Cacyt due to speed of buffers and low conc.
 * ER can use slower clock because of higher concentration
 * IICR uses clock 1 because high IP3 conc makes time const rather small
 * CICR uses clock 2 because it has lower time const, so changes slowly
 * pumps and serca use clock 1 to accurately update other calcium inputs
 * IP3 conc is accurately computed with slow clock 3. */

end
