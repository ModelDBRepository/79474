//volt-func-shunt.g

function Vcomp(path, length, radius, RM, CM, RI, Er, Vinit)
str path
float length,radius
float RM,CM, RI, Er, Vinit
float area, xarea, diam

float PI = 3.14159

create  compartment {path}
diam = 2*radius
area = PI*diam*length
xarea = PI*radius*radius
setfield {path} \
		len {length} \
		dia {diam} \
		Em {Er}	\
		initVm {Vinit} \
		Rm {RM/area} \ /* Mohms is passive resistance */
		Cm {CM*area} \ /* nF */
		Ra {RI*length/xarea}
end

/* commented sections implemented prior to 08/14/02 */
function ellipse_vcomp(path, len, slice, diama, diamb, RM, CM, RI, Er, Vinit)
//function ellipse_vcomp(path, len, slice, rada, radb, RM, CM, RI, Er, Vinit)
str path
float len, diama, diamb
//float len, rada, radb
int slice
float RM,CM, RI, Er, Vinit

int i
float complen = len/slice
//float circum = 2*PI*{sqrt {(rada*rada + radb*radb)/2}}
//float xarea = PI*rada*radb
float circum = PI*{sqrt {(diama*diama + diamb*diamb)/2}}
float xarea = (PI*diama*diamb)/4
float vol = xarea*complen
float SA = circum*complen
for (i=1; i<=slice; i=i+1)
  create compartment {path}[{i}] 
  setfield {path}[{i}] 	\
		len {complen}	\
		dia {(diama+diamb)/2} 	\
		Em {Er}		\
		initVm {Vinit} \
		Rm {RM/SA} 	\
		Cm {CM*SA}	\
		Ra {RI*complen/xarea}
//dia {(rada+radb)/2}     \
 
end

for (i=1; i<slice; i=i+1)
  addmsg {path}[{i}] {path}[{i+1}] RAXIAL Ra previous_state
  addmsg {path}[{i+1}] {path}[{i}] AXIAL previous_state
end

end
