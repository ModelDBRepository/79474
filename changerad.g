function changeradius(path, index, outerrad, shells, shellsize)
str path
int shells, index
float outerrad, shellsize

int j
float innerrad, length
float volume
float areaout, areain, areaside 

for (j=1; j<=shells; j=j+1)

  if (j==shells)
    innerrad=0
  else
    innerrad=outerrad-shellsize
  end

  echo {path}s{j}[{index}] {outerrad} {innerrad}

  str capath={path}@"/Cacyts"@{j}@"["@{index}@"]"
  echo {capath}
  length={getfield {capath} len}
  areaout= 2*PI*outerrad*length
  areain= 2*PI*innerrad*length
  areaside = PI * (outerrad*outerrad - innerrad * innerrad)
  volume = areaside * length / 1000	

   setfield {path}/Cacyts{j}[{index}] \
	vol	{volume} \
	SAout	{areaout} \
	SAin	{areain} \
	SAside  {areaside} \
	radius	{outerrad-innerrad}
   setfield {path}/ip3s{j}[{index}] \
	vol	{volume} \
	SAout	{areaout} \
	SAin	{areain} \
	SAside  {areaside} \
	radius	{outerrad-innerrad}
   setfield {path}/bufbndcyts{j}[{index}] \
	volume	{volume} 
   setfield {path}/bufcyts{j}[{index}] \
	vol	{volume} \
	SAout	{areaout} \
	SAin	{areain} \
	SAside  {areaside} \
	radius	{outerrad-innerrad}
   setfield {path}/CaERs{j}[{index}] \
	vol	{volume} \
	SAout	{areaout} \
	SAin	{areain} \
	SAside  {areaside} \
	radius	{outerrad-innerrad}
   setfield {path}/bufERs{j}[{index}] \
	vol	{volume} \
	SAout	{areaout} \
	SAin	{areain} \
	SAside  {areaside} \
	radius	{outerrad-innerrad}
   setfield {path}/bufbndERs{j}[{index}] \
	volume	{volume}

  outerrad=innerrad

end
end
