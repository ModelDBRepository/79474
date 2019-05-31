function BKAct(v)
float v
float act ={1/{1+{exp {{-{{v}+{Koffset}}-10}/11.6}}}}
return act
end

function BKTauAct(v)
float tauN = {12 + {150/{1+{exp {{{v}+38}/9.6}}}}}
return tauN
end

function AKTauAct(v)
float tauN = {12 + {32/{1+{exp {{{v}+33.5}/10.0}}}}}
return tauN
end

function BKInact(v)
float inact = {1/{1+{exp {{30.0+{{v} + {Koffset}}}/14}}}}
return inact
end

function BKTauInact(v)
float v
float alphaF={-0.1*{{{v}+{Koffset}}+55}/{1-{exp {{{{v}+{Koffset}}+55}/12}}}}
float betaF={4.5/{1+{exp {-{{v}+{Koffset}}/10}}}}
float tauF = {750/{{alphaF}+{betaF}}}
return tauF
end

function make_K(inact,comp,gbar, type)
    str comp, type   
    int inact
    float gbar   
    str path = {comp}@"/K_channel"  

    float xmin = -100   /* minimum voltage we will see in the simulation*/
    float xmax = 50   /* maximum voltage we will see in the simulation */
    float step = 5  /* use a 5mV step size */
    int xdivs = 30      /* the number of divisions between -0.1 and 0.05 */
    int c = 0

    echo "kv-tauactA32B150.g" {type}

    create tabchannel {path}

    /* make the table for the activation with a range of -100mV - +50mV
     * with an entry for ever 5mV
     */
    call {path} TABCREATE X {xdivs} {xmin} {xmax}
    /* set the tau and m_inf for the activation and inactivation */
	for(c = 0; c <= {xdivs}; c = c + 1)
      if (type == "A")
	    setfield {path} X_A->table[{c}] {AKTauAct {{c * {step}} + xmin}}
      else //(type == "B")
	    setfield {path} X_A->table[{c}] {BKTauAct {{c * {step}} + xmin}}
      end
      setfield {path} X_B->table[{c}] {BKAct {{c * {step}} + xmin}}
    end

    float area
    float PI = 3.14159
    area = {getfield {comp} len} *  PI * {getfield {comp} dia}
    setfield {path} Gbar {{gbar}*{area}} Ek {EKrev} Xpower 2 Ypower 0
   	
    /* fill the tables with the values of A and B
     * calculated from tau and m_inf
     */
    tweaktau {path} X
    call {path} TABFILL X 3000 0

    if (inact==1)   
      call {path} TABCREATE Y {xdivs} {xmin} {xmax}
	  for(c = 0; c < {xdivs}; c = c + 1)
	    setfield {path} Y_A->table[{c}] {BKTauInact {{c * {step}}+xmin}}
	    setfield {path} Y_B->table[{c}] {BKInact {{c * {step}} + xmin}}
      end
      setfield {path} Ek {EKrev} Xpower 2 Ypower 1

      tweaktau {path} Y
      call {path} TABFILL Y 3000 0
    end

    addmsg {path} {comp} CHANNEL Gk Ek
    addmsg {comp} {path} VOLTAGE Vm

end

function K_comp (inact,path,gbar,first,last, type)
    int inact
    str path, type
    float gbar
    int first, last

    int i
    str comp

echo "Kv: inact=" {inact} "Koffset=" {Koffset} "type=" {type}

    for (i = {first} ; i <= {last} ; i =i+1)
        comp = (path)@"["@{i}@"]"
        make_K {inact} {comp} {gbar} {type}
    end
end






