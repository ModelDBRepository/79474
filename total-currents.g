/*total-currents.g*/
/* total kleak currents */
int i, j

float ratio={axoncyls}/{axonslice}
int firstcyl, lastcyl

for (j=1; j<={axonslice}; j=j+1)
  create diffamp /axon/vm[{j}]/kleak_total
  setfield ^ gain 1.0 saturation 999
  create diffamp /axon/vm[{j}]/gkleak_total
  setfield ^ gain 1.0 saturation 999
  firstcyl= (j-1)*ratio+1
  lastcyl= j*ratio

  for (i={firstcyl}; i<={lastcyl}; i=i+1)
     addmsg /axon/Cacyts1[{i}]/kleak /axon/vm[{j}]/kleak_total PLUS I
     addmsg /axon/Cacyts1[{i}]/kleak /axon/vm[{j}]/gkleak_total PLUS G
  end
end

create diffamp /soma/cashell
setfield ^ gain 0.04167 saturation 10
create diffamp /soma/vm[1]/pca
setfield ^ gain 1.0 saturation 999
create diffamp /soma/vm[1]/tca
setfield ^ gain 1.0 saturation 999
create diffamp /soma/vm[1]/kc_total
setfield ^ gain 1.0 saturation 999
create diffamp /soma/vm[1]/gkc_total
setfield ^ gain 1.0 saturation 999
create diffamp /soma/vm[1]/kleak_total
setfield ^ gain 1.0 saturation 999
create diffamp /soma/vm[1]/gleak_total
setfield ^ gain 1.0 saturation 999
create diffamp /soma/vm[1]/ncx
setfield ^ gain 1.0 saturation 999
create diffamp /soma/vm[1]/pmca
setfield ^ gain 1.0 saturation 1e9

for (i=1; i<=24; i=i+1)
  addmsg /soma/Cacyts1[{i}]/ncx /soma/vm[1]/ncx PLUS I
  addmsg /soma/Cacyts1[{i}]/pmca /soma/vm[1]/pmca PLUS moles_out
  addmsg /soma/Cacyts1[{i}] /soma/cashell PLUS Conc
  addmsg /soma/Cacyts1[{i}]/persist_ghk_ica /soma/vm[1]/pca PLUS I
  addmsg /soma/Cacyts1[{i}]/trans_ghk_ica /soma/vm[1]/tca PLUS I
  addmsg /soma/Cacyts1[{i}]/kc /soma/vm[1]/kc_total PLUS I
  addmsg /soma/Cacyts1[{i}]/kc /soma/vm[1]/gkc_total PLUS G
  addmsg /soma/Cacyts1[{i}]/kleak /soma/vm[1]/kleak_total PLUS I
  addmsg /soma/Cacyts1[{i}]/kleak /soma/vm[1]/gleak_total PLUS G
end


