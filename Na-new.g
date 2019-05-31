function BNaAct(v)
float v
float alphaM = 0.36*{{v}+{Naoffset}+33}/{1-{exp {{-{{v}+{Naoffset}+33}/4.5}}}}
float betaM = -0.4*{ {v}+{Naoffset}+42 }/{1-{exp {{ {v}+{Naoffset}+42 }/20} }}
float act = {alphaM}/{{alphaM}+{betaM}}
return act
end

function BNaTauAct(v, speed)
float v, speed
float alphaM = 0.36*{{v}+{Naoffset}+33}/{1-{exp {{-{{v}+{Naoffset}+33}/4.5}}}}
float betaM = -0.4*{ {v}+{Naoffset}+42 }/{1-{exp {{ {v}+{Naoffset}+42 }/20} }}
float tauM={speed}/{{alphaM}+{betaM}}
return tauM
end

function BNaInact(v)
float v
float alphaH={-0.1*{ {v}+{Naoffset}+55 }}/{1-{exp {{ {v}+{Naoffset}+55 }/6}}}
float betaH=4.5/{1+ {exp {-{ {v}+{Naoffset} }/10}}}
float inact = {alphaH}/{{alphaH}+{betaH}}
return inact
end

function BNaTauInact(v)
float v
float alphaH={-0.1*{ {v}+{Naoffset}+55 }}/{1-{exp {{ {v}+{Naoffset}+55 }/6}}}
float betaH=4.5/{1+ {exp {-{ {v}+{Naoffset} }/10}}}
float tauH = 2.0/{{alphaH}+{betaH}}
return tauH
end

function make_Na(type,comp,gbar, speed)
    str type
    str comp	
    float gbar, speed
    str path ={comp}@"/Na_channel"  

    float xmin = -100   /* minimum voltage we will see in the simulation
*/
    float xmax = 50   /* maximum voltage we will see in the simulation */
    float step = 5  /* use a 5mV step size */
    int xdivs = 30      /* the number of divisions between -0.1 and 0.05 */
    int c = 0

    create tabchannel {path}

    /* make the table for the activation with a range of -100mV - +50mV
     * with an entry for ever 5mV
     */
    call {path} TABCREATE X {xdivs} {xmin} {xmax}
    call {path} TABCREATE Y {xdivs} {xmin} {xmax}

    /* set the tau and m_inf for the activation and inactivation */


    for(c = 0; c <= {xdivs}; c = c + 1)
      setfield {path} X_A->table[{c}] {BNaTauAct {{c * {step}} + xmin} {speed} }
	  setfield {path} X_B->table[{c}] {BNaAct {{c * {step}} + xmin}}
	  setfield {path} Y_A->table[{c}] {BNaTauInact {{c * {step}} +xmin}}
	  setfield {path} Y_B->table[{c}] {BNaInact {{c * {step}} + xmin} }
    end

    float area
    float PI = 3.14159
    area = {getfield {comp} len} *  PI * {getfield {comp} dia}    
    setfield {path} Gbar {{gbar}*{area}}

    addmsg {path} {comp} CHANNEL Gk Ek
    addmsg {comp} {path} VOLTAGE Vm

    setfield {path} Ek {ENarev} Xpower 3 Ypower 1
    /* fill the tables with the values of A and B
     * calculated from tau and m_inf
     */

    tweaktau {path} X
    tweaktau {path} Y

    setfield {path} X_A->calc_mode {NO_INTERP} X_B->calc_mode {NO_INTERP} 
    setfield {path} Y_A->calc_mode {NO_INTERP} Y_B->calc_mode {NO_INTERP}

    call {path} TABFILL X 3000 0
    call {path} TABFILL Y 3000 0

end

function Na_comp (type,path,gbar,first,last, speed)
    str type
    str path
    float gbar, speed
    int first, last

    int i
    str comp

echo "NaA: speed=" {speed} "Naoffset=" {Naoffset}

    for (i = {first} ; i <= {last} ; i =i+1)
        comp = (path)@"["@{i}@"]"
        make_Na {type} {comp} {gbar} {speed}
    end
end






