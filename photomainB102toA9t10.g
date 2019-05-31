//CHEMESIS2.0
//photomainB102toA9.g
/* model of A cell phototransduction: A-B differences
1: Add Na channels to axon comps 1-3, decreases gNaF, different IH
2: Increase gKCa, lower gKasoma
4: (skip 3) speed up kv activation, from 150 to 32
5: Add fast KCa in axon with slow inact, decrease slower KCa in soma
6: Faster light current
9: lower kleak (and higher KCa) than 6
*/

include new-const.g
include rxn-func.g
include comp-func.g
include changerad.g
include cicr-func.g
include ryan-func.g
include iicrflux-func.g
include cytpump-func.g
include cal-ip3-2D.g
include cal-ip3-rhab.g
include cal-ip3-taper.g
include volt-func-shunt.g
include kleak-newlig4.g
include phototrans2.g
include yamoah-ihA.g
include ica.g
include kaA.g
include Na-new.g
include kc4act3AtypeAslowerinact.g
include kc4act3B1.g
include kv-tauactA32B150.g
include lgt-na17a.g
include gabaa-chan.g
include gabab-syn.g
include gabab-chan.g

int i, j
int start, last
float increment, axonval

str plctype="mm"
str type="A"
if (type=="B")
  na_speed=16
  nastart=3
  Vinit=-55
  ka_v0 = -35
  gkca=50e3
  float gSKaxon=0
  float gkcAfastaxon=0
  gka=65e3
  gNaF=3.3e5
elif (type == "A")
  na_speed=10
  nastart=1
  Vinit=-60
  ka_v0 = -35
  gkca=180e3
  float gSKaxon=0
  float gkcAfast=0e3
  float gkcAfastaxon=250e3
  kinact=0
  gka=65e3
  gNaF=2.8e5
end

Vncx = 1300
Vpmca = 1.5e-11
kpmca = 0.1e-3
Vncxaxon = 150
Vpmcaxon = 2.1e-12
Vpmcarhab = 0.7e-12
Vncxrhab = 50
gKdrsoma=3.0e5
gKdr =    3.8e5
g_ihsoma=590
g_ih=2311
gleak=100
gkasoma=20e3
ENarev = 30
Naoffset=14.01
Koffset=2.01
axondiama=3e-4
axondiamb=5e-4
syn_br_rad	=1.2e-4
nosyn_br_rad=1.2e-4	

lightdelay=1000

str filepath="/home/avrama/chemesis2.0/photo-spikes/final/"

echo "reading in model"

RI = 40e-5
include morphCa4.g

for (i=1; i<={axonslice}; i=i+1)
    axonval={axonslice}
    increment= {axoncyls}/{axonval}
    start=(i-1)*increment+1
    last=(i*increment)
    ica_axon /axon/vm[{i}] /axon/Cacyts1 {start} {last} {pca_s} /extracell
    icak_typeA /axon/vm[{i}] /axon/Cacyts1 {start} {last} {gkcAfastaxon}
end
for (i=1; i<={branchcomps}; i=i+1)
  start=(i-1)*{branchcyls/branchcomps}+1
  last=i*{branchcyls/branchcomps}
  ica_axon /branch_syn/vm[{i}] /branch_syn/Cacyts1 {start} {last} {pca_s} /extracell
  ica_axon /branch/vm[{i}] /branch/Cacyts1 {start} {last} {pca_s} /extracell
end

phototrans /rhab/ip3s1
lgtna_comp /rhab/vm /rhab/ip3s2 {rhabcyls} {gna}

echo "initializing output file"
str gaba="/branch_syn/vm[2]"
include inject-outSK.g

reset
setcytpumpleak /soma/Cacyts1 /extracell {somacyls} {Vpmca} {kpmca} {Vncx} {kncx}
setcytpumpleak /rhab/Cacyts1 /extracell {rhabcyls} {Vpmcarhab} {kpmca} {Vncxrhab} {kncx}
setcytpumpleak /neck/Cacyts1 /extracell 1 {Vpmcarhab} {kpmca} {Vncxrhab} {kncx}
setcytpumpleak /axon/Cacyts1 /extracell {axoncyls} {Vpmcaxon} {kpmca} {Vncxaxon} {kncx}
setcytpumpleak /branch/Cacyts1 /extracell {branchcyls} {2*Vpmcarhab} {kpmca} {2*Vncxrhab} {kncx}
setcytpumpleak /branch_syn/Cacyts1 /extracell {branchcyls} {2*Vpmcarhab} {kpmca} {2*Vncxrhab} {kncx}
//check

echo "gkcsoma=" {gkca} {getfield soma/Cacyts1[10]/kc Gbar} "gkcaxon=" {gkcAfastaxon}

    create pulsegen /Iin
    setfield ^  \
        delay1 200             \      // msec
        level1 0.1                 \
        width1 400  \
        delay2 9999.0
    addmsg /Iin /soma/vm[1] INJECT output

/*    setfield /output/plot_out leave_open 1 append 0 flush 0 filename "B102toA9inject0.1nA.dat"
    reset
    step {800/0.005}

    setfield Iin level1 -0.5
    setfield /output/plot_out leave_open 1 append 0 flush 0 filename "B102toA9inject-0.5nA.dat"
    reset
    step {800/0.005}
*/
    setfield Iin level1 +0.5
    setfield /output/plot_out leave_open 1 append 0 flush 0 filename "B102toA9t10inject0.5nA.dat"
    reset
    step {800/0.005}

    setfield Iin level1 +0.3
    setfield /output/plot_out leave_open 1 append 0 flush 0 filename "B102toA9t10inject0.3nA.dat"
    reset
    step {800/0.005}

delete /Iin

delete /output/plot_out
/*light stimuli*/
float dur
/*include output-cal2.g
include photo-outSK.g

for (dur=30; dur<=3000; dur=dur*10)

  setfield /rhabmemb/shutter width1 {dur} delay1 {lightdelay}
  str filenam = (filepath)@"B102toA9cell-lgt"@(dur)@"-nd0.dat"
  setfield /output/plot_out filename {filenam} initialize 1 append 0 leave_open 1
  str filenam = (filepath)@"B102toA9cell-lgt"@(dur)@"-nd0.cal"
  setfield /output/cal filename {filenam} initialize 1 append 0 leave_open 1

  reset
  step 3200000
end

for (dur=30; dur<=3000; dur=dur*10)

  setfield /rhabmemb/shutter width1 {dur} delay1 {lightdelay} level1 3.2
  filenam = (filepath)@"B102toA9cell-lgt"@(dur)@"-nd1.dat"
  setfield /output/plot_out filename {filenam} initialize 1 append 0 leave_open 1
  filenam = (filepath)@"B102toA9cell-lgt"@(dur)@"-nd1.cal"
  setfield /output/cal filename {filenam} initialize 1 append 0 leave_open 1

  reset
  step 3200000
end

for (dur=30; dur<=3000; dur=dur*10)

  setfield /rhabmemb/shutter width1 {dur} delay1 {lightdelay} level1 1
  filenam = (filepath)@"B102toA9cell-lgt"@(dur)@"-nd2.dat"
  setfield /output/plot_out filename {filenam} initialize 1 append 0 leave_open 1
  filenam = (filepath)@"B102toA9cell-lgt"@(dur)@"-nd2.cal"
  setfield /output/cal filename {filenam} initialize 1 append 0 leave_open 1

  reset
  step 3200000
end

*/


