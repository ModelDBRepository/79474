//comp-func.g
//CHEMESIS1.0

function poolcyl (path, length, rad, initcon, type, unit)
   str path
   float length
   float rad
   float initcon
   float   PI              =       3.14159
   float area = PI*rad*rad
   float volume = area * length / 1000	/* divide by 1000 to convert from cm^3 to L */
   float areaout = 2*PI*rad*length
   int type
   float unit

   create rxnpool {path}
   setfield {path} \
	Cmin	0 \
	len	{length} \
	Conc	0.0e-3 \ 
	Cinit   {initcon} \	
	vol	{volume} \
	SAside	{area} \
	SAout   {areaout} \
	radius  {rad} \
	quantity 0 \
	Qinit	{initcon*volume} \
	type	{type} \
	units   {unit} \
	Iunits	1e-12
end

/****************************************************************************/
function poolsphere (path, outerrad, innerrad, initcon, type, unit)
   str path
   float outerrad
   float innerrad
   float initcon
   float   PI              =       3.14159
   float areaout = 4 * PI*outerrad*outerrad
   float areain = 4 * PI*innerrad*innerrad
   float volume = (areaout*outerrad - areain * innerrad) / 3 / 1000
		/* divide by 1000 to convert from cm^3 to L */
   int type
   float unit

   create rxnpool {path}
   setfield {path} \
	Cmin	0 \
	Conc	0.0e-3 \ 
	Cinit   {initcon} \	
	vol	{volume} \
	SAout	{areaout} \
	SAin	{areain} \
	radius	{outerrad-innerrad} \
	quantity 0 \
	type	{type} \
	units   {unit} \
	Iunits	1e-12 \
	Qinit {initcon*volume}
end

/****************************************************************************/
function pool2D (path, outerrad, innerrad, width, initcon, type, unit)
   str path
   float outerrad
   float innerrad
   float initcon
   float width
   int type
   float unit

   float   PI              =       3.14159
   float areaout = 2 * PI*outerrad*width
   float areain = 2 * PI*innerrad*width
   float areaside = PI * (outerrad*outerrad - innerrad * innerrad)
   float volume = areaside * width / 1000
	/* divide by 1000 to convert from cm^3 to L */

   create rxnpool {path}
   setfield {path} \
	Cmin	0 \
	Conc	0.0e-3 \ 
	Cinit   {initcon} \	
	vol	{volume} \
	SAout	{areaout} \
	SAin	{areain} \
	SAside  {areaside} \
	len	{width}	\
	radius	{outerrad-innerrad} \
	quantity  0 \
	Qinit	{initcon*volume} \
	type {type} \
	units {unit} \
	Iunits	1e-12
end

/****************************************************************************/

function difsphere (path1,path2,difpath,dif, unit)
   str path1, path2, difpath
   float dif, unit
   
   create diffusion {difpath}
   setfield ^ \
	D {dif} \
	units {unit}

addmsg {path1} {difpath} POOL1 radius SAin Conc /* Should be "outer" pool */
addmsg {path2} {difpath} POOL2 radius SAout Conc /* Should be "inner" pool */
addmsg {difpath} {path1} RXN0MOLES difflux1
addmsg {difpath} {path2} RXN0MOLES difflux2

end
/********************************************************************/

function difcyl (path1,path2,difpath,dif, unit)
   str path1, path2, difpath
   float dif, unit
   
   create diffusion {difpath}
   setfield ^ \
	D {dif} \
	units {unit}

addmsg {path1} {difpath} POOL1 len SAside Conc /* Should be "left" pool */
addmsg {path2} {difpath} POOL2 len SAside Conc /* Should be "right" pool */
addmsg {difpath} {path1} RXN0MOLES difflux1
addmsg {difpath} {path2} RXN0MOLES difflux2

end

/****************************************************************************/

function compcyl (path, radius, ncyls, cylsize, calconc, type, unit)
 float radius, cylsize
 float calconc
 int ncyls
 str path
 int type
 float unit
 
 int cyl

 for (cyl = 1; cyl <= ncyls; cyl=cyl+1)
	poolcyl {path}[{cyl}] {cylsize} {radius} {calconc} {type} {unit}
    end
end
/********************************************************************/

function compsphere(path, radius, nshells, shellsize, initcon, type, unit)
  float radius, shellsize
  float initconc
  int nshells
  str path
  int type
  float unit

  int shell
  float outer, inner

  outer=radius
  inner=radius-shellsize

  for (shell = 1; shell <= nshells; shell=shell+1)
	if (shell == nshells) ; inner = 0; end
	poolsphere {path}[{shell}] {outer} {inner} {initcon} {type} {unit}
	outer = inner
	inner = inner - shellsize
  end
end
/********************************************************************/

function comp2D(path, radius, nshells, shellsize, len, ncyls, initcon, type, unit)
  float radius, cylsize, len
  float initconc
  int nshells, ncyls
  str path
  int type
  float unit

  int shell, cyl
  float outer, inner

  outer=radius
  inner=radius-shellsize

/* shell index first, cyl index second */

  for (shell = 1; shell <= nshells; shell=shell+1)
	if (shell == nshells) ; inner = 0; end

	for (cyl = 1; cyl <= ncyls; cyl = cyl+1)
	     pool2D {path}s{shell}[{cyl}] {outer} {inner} {len} {initcon} {type} {unit}
	end

	outer = inner
	inner = inner - shellsize
  end
end

/********************************************************************/

function conservepool(path,Total, vol, type, unit)
   str path
   float Total, vol
  int type
  float unit

   create conservepool {path}
   setfield {path} \
	Ctot	{Total} \
	Cmin	0 \
	Conc	0 \
	Cinit	0 \
	Qinit	0 \
	quantity 0 \
	Qtot	{Total*vol} \
	type	{type} \
	volume {vol} \
	units {unit}
end

/********************************************************************/

function consv1D (path, ncomp, total, radius, length, type, unit)
  float total, radius, length
  str path
  int ncomp
  int type
  float unit

  float volume = PI * radius*radius*length / 1000
	/* convert  from cm^3 to Liters */
  int i

  for (i = 1; i <= ncomp; i = i + 1)
    conservepool {path}[{i}] {total} {volume} {type} {unit}
  end
end

/*********************************************************************/

function consv2D (path, nshell, ncyl, total, radius, length, shellsize, type, unit)
  float total, radius, length, shellsize
  str path
  int ncyl, nshell
  int type
  float unit

  float outer, inner, volume
  int i, j

  outer=radius
  inner=radius-shellsize

/* shell index first, cyl index second */

  for (i = 1; i <= nshell; i = i + 1)
   if (i == nshell) ; inner = 0; end

   float volume = PI * (outer*outer - inner * inner) * length / 1000
	/* divide by 1000 to convert from cm^3 to L */

    for (j = 1; j <= ncyl; j = j + 1)
       conservepool {path}s{i}[{j}] {total} {volume} {type} {unit}
    end

    outer = inner
    inner = inner - shellsize
 
  end
end

/********************************************************************/
function difcomp2D(path, nshells, ncyls, difconst, unit)
  float difconst, unit
  int nshells, ncyls
  str path

  int shell, cyl

/* shell index first, cyl index second */
/*  axdif is diffusion axially, within a shell;
  raddif is difusion radially, within a cylinder */

  for (cyl = 1; cyl <= ncyls; cyl = cyl+1)

     for (shell = 1; shell < nshells; shell=shell+1)
        difsphere {path}s{shell}[{cyl}] {path}s{shell+1}[{cyl}] {path}_raddifs{shell}[{cyl}] {difconst} {unit}
     end
     if (cyl < ncyls)
       for (shell = 1; shell <= nshells; shell=shell+1)
          difcyl {path}s{shell}[{cyl}] {path}s{shell}[{cyl+1}] {path}_axdifs{shell}[{cyl}] {difconst} {unit}
       end
     end
  end
end

/********************************************************************/

function difcompcyl(path, ncyls, difconst, unit)
  float difconst, unit
  int ncyls
  str path

  int cyl

  for (cyl = 1; cyl < ncyls; cyl = cyl+1)
        difcyl {path}[{cyl}] {path}[{cyl+1}] {path}_axdif[{cyl}] {difconst} {unit}
  end
end

/********************************************************************/

function difcompsphere(path, nshells, difconst, unit)
  float difconst, unit
  int nshells
  str path

  int shell

  for (shell = 1; shell < nshells; shell = shell+1)
        difsphere {path}[{shell}] {path}[{shell+1}] {path}_raddif[{shell}] {difconst} {unit}
  end
end









































































































