//CHEMESIS2.0
//photomain102.g
/* model of B cell phototransduction:
Best model wrt spike shape, and rates during inject & light
Removed branch ICa and increased pump to prevent Ca spike
decreased gKa axon to 40 to compensate for smaller gleak reduction.
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
include kc4act3B1.g
include kv-tauactA32B150.g
include lgt-na17.g
include gabaa-chan.g
include gabab-syn.g
include gabab-chan.g

int i, j
int start, last
float increment, axonval

str plctype="mm"
str type="B"
if (type=="B")
  na_speed=16
  nastart=3
  Vinit=-55
  Naoffset=14.01
  Koffset=2.01
  ka_v0 = -35
  gkca=50e3
  float gSKaxon=0
  float gkcAfastaxon=0
elif (type == "A")
  na_speed=8
  nastart=1
  Vinit=-60
  Naoffset=14.01
  Koffset=2.01
  ka_v0 = -30
  gkca=200e3
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
gleak=200
gkasoma=25e3
gka=65e3
gNaF =    3.3e5
ENarev = 30
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

    create pulsegen /Iin
    setfield ^  \
        delay1 200             \      // msec
        level1 0.1                 \
        width1 400  \
        delay2 9999.0
    addmsg /Iin /soma/vm[1] INJECT output

    setfield /output/plot_out leave_open 1 append 0 flush 0 filename "B102inject0.1nA.dat"
    reset
    step {800/0.005}

    setfield Iin level1 -0.5
    setfield /output/plot_out leave_open 1 append 0 flush 0 filename "B102inject-0.5nA.dat"
    reset
    step {800/0.005}

    setfield Iin level1 +0.5
    setfield /output/plot_out leave_open 1 append 0 flush 0 filename "B102inject0.5nA.dat"
    reset
    step {800/0.005}

    setfield Iin level1 +0.3
    setfield /output/plot_out leave_open 1 append 0 flush 0 filename "B102inject0.3nA.dat"
    reset
    step {800/0.005}

delete /Iin
delete /output/plot_out
/*light stimuli*/
float dur
include output-cal2.g
include photo-outSK.g

for (dur=30; dur<=3000; dur=dur*10)

  setfield /rhabmemb/shutter width1 {dur} delay1 {lightdelay}
  str filenam = (filepath)@"Bcell102-lgt"@(dur)@"-nd0.dat"
  setfield /output/plot_out filename {filenam} initialize 1 append 0 leave_open 1
  str filenam = (filepath)@"Bcell102-lgt"@(dur)@"-nd0.cal"
  setfield /output/cal filename {filenam} initialize 1 append 0 leave_open 1

  reset
  step 3200000
end

for (dur=30; dur<=3000; dur=dur*10)

  setfield /rhabmemb/shutter width1 {dur} delay1 {lightdelay} level1 3.2
  filenam = (filepath)@"Bcell102-lgt"@(dur)@"-nd1.dat"
  setfield /output/plot_out filename {filenam} initialize 1 append 0 leave_open 1
  filenam = (filepath)@"Bcell102-lgt"@(dur)@"-nd1.cal"
  setfield /output/cal filename {filenam} initialize 1 append 0 leave_open 1

  reset
  step 3200000
end

for (dur=30; dur<=3000; dur=dur*10)

  setfield /rhabmemb/shutter width1 {dur} delay1 {lightdelay} level1 1
  filenam = (filepath)@"Bcell102-lgt"@(dur)@"-nd2.dat"
  setfield /output/plot_out filename {filenam} initialize 1 append 0 leave_open 1
  filenam = (filepath)@"Bcell102-lgt"@(dur)@"-nd2.cal"
  setfield /output/cal filename {filenam} initialize 1 append 0 leave_open 1

  reset
  step 3200000
end




