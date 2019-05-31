//inject-outSK.g
include total-currents.g

/* rhabdomere current totals*/
create diffamp /rhab/kleak_total
setfield /rhab/kleak_total gain 1 saturation 10000
create diffamp /rhab/gleak_total
setfield /rhab/gleak_total gain 1 saturation 10000
create diffamp /rhab/cashell
//setfield ^ gain 1.0 saturation 10
setfield ^ gain {1.0/12.0} saturation 10

for (i=1; i<=rhabcyls; i=i+1)
  	addmsg /rhab/Cacyts1[{i}] /rhab/cashell PLUS Conc
    addmsg /rhab/Cacyts1[{i}]/kleak /rhab/kleak_total PLUS I
    addmsg /rhab/Cacyts1[{i}]/kleak /rhab/gleak_total PLUS G
end

if (({gSKaxon}>0) || ({gkcAfastaxon} > 0))
for (i=1; i<={axonslice}; i=i+1)
  create diffamp /axon/vm[{i}]/gKCaxon_total
  setfield ^ gain 1.0 saturation 999
    axonval={axonslice}
    increment= {axoncyls}/{axonval}
    start=(i-1)*increment+1
    last=(i*increment)
  for (j={start}; j<={last}; j=j+1)
    if ({gkcAfastaxon} > 0)
//      addmsg /axon/Cacyts1[{j}]/kctypeA /axon/vm[{i}]/gKCaxon_total PLUS G
// the following line is a substitute for photomainBtoA11.g only
      addmsg /axon/Cacyts1[{j}]/kc /axon/vm[{i}]/gKCaxon_total PLUS G
    end
    if ({gSKaxon}>0)
      addmsg /axon/Cacyts1[{j}]/SK /axon/vm[{i}]/gKCaxon_total PLUS Gk
    end
  end
end
end

create asc_file /output/plot_out
addmsg /soma/vm[1] /output/plot_out SAVE Vm 
addmsg /axon/vm[2] /output/plot_out SAVE Vm 
addmsg /axon/vm[6] /output/plot_out SAVE Vm 
addmsg /rhab/vm /output/plot_out SAVE Vm 
addmsg /branch_syn/vm[2] /output/plot_out SAVE Vm 

/*7*/
addmsg /soma/cashell /output/plot_out SAVE output
addmsg /rhab/cashell /output/plot_out SAVE output
addmsg /rhab/bufcyts2[6] /output/plot_out SAVE Conc
addmsg /soma/bufcyts1[6] /output/plot_out SAVE Conc
addmsg /rhab/kleak_total /output/plot_out SAVE output
addmsg /rhab/gleak_total /output/plot_out SAVE output

/*13*/
addmsg /axon/vm[1]/gkleak_total  /output/plot_out SAVE output 
addmsg /axon/vm[3]/gkleak_total /output/plot_out SAVE output 
addmsg /axon/vm[5]/gkleak_total  /output/plot_out SAVE output 
addmsg /axon/vm[7]/gkleak_total  /output/plot_out SAVE output
addmsg /axon/vm[2]/K_channel /output/plot_out SAVE Gk
addmsg /axon/vm[5]/K_channel /output/plot_out SAVE Gk
addmsg /axon/vm[2]/ka /output/plot_out SAVE G
addmsg /axon/vm[5]/ka /output/plot_out SAVE G

/*21*/
if (type == "A")
    addmsg /soma/vm[1]/ihA /output/plot_out SAVE I
else
    addmsg /soma/vm[1]/ihB /output/plot_out SAVE I
end
addmsg /soma/vm[1]/pca /output/plot_out SAVE output
addmsg /soma/vm[1]/tca /output/plot_out SAVE output
addmsg /soma/vm[1]/gleak_total /output/plot_out SAVE output
addmsg /soma/vm[1]/gkc_total /output/plot_out SAVE output
addmsg /soma/vm[1]/K_channel /output/plot_out SAVE Gk
addmsg /soma/vm[1]/ka /output/plot_out SAVE G
addmsg /soma/vm[1]/ncx /output/plot_out SAVE output
addmsg /soma/vm[1]/pmca /output/plot_out SAVE output

/*30 */
addmsg /axon/vm[2]/gKCaxon_total /output/plot_out SAVE output
addmsg /axon/vm[5]/gKCaxon_total /output/plot_out SAVE output

addmsg /axon/Cacyts1[18] /output/plot_out SAVE Conc
addmsg /axon/Cacyts1[62] /output/plot_out SAVE Conc

addmsg /soma/vm[1]/gSK_total /output/plot_out SAVE output

useclock /output/plot_out 5

