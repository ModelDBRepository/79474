//photo-outSK.g
// to be used after inject-out.g
/* rhabdomere phototrans totals*/

create diffamp totalrho
setfield totalrho gain 1 saturation 10000
create diffamp totaleff
setfield totaleff gain 1 saturation 10000
create diffamp totalinact
setfield totalinact gain 1 saturation 100000
create diffamp activevilli
setfield activevilli gain 1 saturation {numvilli}
create diffamp villivol
setfield villivol gain 1000000 saturation 1
create diffamp /rhab/Gtot
setfield /rhab/Gtot gain 1 saturation 100e6
create diffamp /rhab/PIPtot
setfield /rhab/PIPtot gain 1 saturation 100e6
create diffamp /rhab/lgtna_total
setfield /rhab/lgtna_total gain 1 saturation 10000

for (i=1; i<=rhabcyls; i=i+1)
        addmsg /rhabmemb/mrhod[{i}] totalrho PLUS total_isom
        addmsg /rhabmemb/mrhod[{i}] totaleff PLUS effective
        addmsg /rhabmemb/mrhod[{i}] totalinact PLUS total_inact
        addmsg /rhabmemb/mrhod[{i}] activevilli PLUS active_villi
        addmsg /rhab/ip3s1[{i}] villivol PLUS vol
        addmsg /rhab/ip3s2[{i}]/lgtna /rhab/lgtna_total PLUS G
        addmsg /rhabmemb/Ginact[{i}] /rhab/Gtot PLUS quantity
        addmsg /rhabmemb/pip2[{i}] /rhab/PIPtot PLUS quantity
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

/*30*/
addmsg totalrho /output/plot_out SAVE output
addmsg totaleff /output/plot_out SAVE output
addmsg totalinact /output/plot_out SAVE output
addmsg activevilli /output/plot_out SAVE output
addmsg /rhabmemb/mrhoGprot[1] /output/plot_out SAVE complex_quant
addmsg /rhabmemb/Ga[1] /output/plot_out SAVE quantity
addmsg /rhabmemb/Ginact[1] /output/plot_out SAVE quantity
addmsg /rhabmemb/plcGqa[1] /output/plot_out SAVE quantity
addmsg /rhabmemb/pip2[1] /output/plot_out SAVE Conc
addmsg /rhabmemb/plcPI[1] /output/plot_out SAVE quantity     
addmsg villivol /output/plot_out SAVE output
addmsg /rhab/Gtot /output/plot_out SAVE output
addmsg /rhab/PIPtot /output/plot_out SAVE output

/*43*/
addmsg /rhab/lgtna_total /output/plot_out SAVE output
addmsg /soma/ip3s2[1] /output/plot_out SAVE Conc
addmsg /soma/ip3s2[5] /output/plot_out SAVE Conc

addmsg /axon/vm[2]/gKCaxon_total /output/plot_out SAVE output
addmsg /axon/vm[5]/gKCaxon_total /output/plot_out SAVE output
addmsg /soma/vm[1]/gSK_total /output/plot_out SAVE output

useclock /output/plot_out 5

