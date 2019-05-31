//bopt3-const.g
/** Used with the terminal branches model **/
/* Units: Millimole, nanoamps, megaohms, microsiemens, milliseconds, 
   nanoFarads, Liters, centimeters */

float PI = 3.14159 

float umole	=	1e-6	/* units are umoles and uM */
float mmole	=	1e-3	/* units are mmoles and mM */
int quant	=	1 /* integrate using quantity, not concentration */
int concen	=	0 /* integrate using concentration, not quantity */

/* RM*CM = ~ 35 msec => passive membrane time constant. */
float RI	=	200e-6	/* Mohm-cm, could be 200e-6 */
float RM	=	1e-2	/* Megaohms - cm^2; 5e-2 from Spruston et al, used with increased rhab SA */
float CM	=	1e3	/* nanoFarads/cm^2; 1e3 from Spruston et al. */

float gshunt	=	0.001
float Vinit	=	-55.2 /*-60 for A*/
float EKrev = -80
float ENarev = 60
float Er	=	0

float gleak	=	200		/* uS/cm^2 */
float gna	=	5e5
float gNaF =    3.25e5 
float na_speed=16.0 /*4 for A*/
float nastart=3 /*1 for A*/
float Naoffset = 12.01
float gKdr =    2.36e5
float gKdrsoma ={gKdr}
float Koffset = 0.01
int kinact=0
float g_ih	=	1136
float g_ihsoma= 1512 /*different type for A*/	
float pca_p	=	0.1	
float pca_t	=	0.1
float pca_s = {pca_p}
float gkca	=	50e3 /*200 for A*/
float gka	=	58.4e3
float gkasoma=  50.0e3
float ka_v0 = -35 /*-25 for A?*/
float g_gabaa	=	70e4	/* gamma*(mol/cm^2) */
float g_gabab	=	70e3	/* uS/cm^2 */

float somarad	=	10.0e-4 /* e-4 converts from microns to cm */
float somalen	=	24e-4	/* 24 microns */
int somacyls	=	24 
int somashells	=	2

float rhabrad	=	6.0e-4 
float rhabcorerad=  1.0e-4
float rhablen	=	12e-4
int rhabcyls	=	12
int rhabshells	=	2
float shellsize	=	1e-4
float rhabSA	=	0.000125/4  /*Assuming 5000 microvilli. 0.08 um radius X 
    10 um len or 0.08 diam x 5 um len. only 1/4 of SA accesible to E.C. space*/
float rhabxarea	=	3.14e-8  /* Core cross section assuming 2e-4 dia non-villi portion */
float rhabvillen	=	10e-4	/* actual length, Eakin et al.*/
float rhabvilrad	=	0.04e-4 /* actual radius of microvil, Eakin et al. */
int numvilli	=	5000 		/* number of microvilli */
float villiXarea =  PI*{rhabvilrad}*{rhabvilrad}
float Rvilli    =   rhabvillen*RI/villiXarea
float Rcore     =   RI*rhablen/rhabxarea+Rvilli/5000

float neckrad	=	3e-4	/* 3 microns */
float necklen	=	1e-4	/* 1 micron neck width */
float axonlen	=	100e-4	/* 100 micron length */
float axondiama	=	2e-4	/* 1.5 micron short axis diameter*/
float axondiamb	=	4e-4	/* 3 micron long axis  diameter*/
int axonslice	=	8	/* four axon  voltage compartments */
int axoncyls	=	100

float syn_br_rad	=	0.63e-4		/*0.215e-4  for asym*/
float nosyn_br_rad	=	0.63e-4		/*0.93e-4 for asym */
float branchlen1	=	5e-4	/* branch between synapse & axon*/
float branchlen2	=	10e-4	/* terminal branch with synapse*/
int branchcomps     =   3
int branchcyls		=	{branchcomps}*5

float Cacyt     =       0.11e-3      /* mM, for ca=0.0100 */
float CaER      =       0.020         /* mM for ca=0.0100 */
float bufcyt    =       0.1496       /* mM for ca=0.0100*/
float bufER     =       2.399           /* mM, for ca=0.0100 */

float Cadif     =       6.0e-9  /* cm^2/msec */
float bufcyttot =       153e-3          /* mM */
float bufERtot  =       12.0            /* mM, 2x previous value */
float buf_kf    =       1e2     /* per mM-msec, from Nowycky et al. and */
float buf_kb    =       0.5     /* per msec, from Blumenfeld et al. */

float init00	=	0.7434	/*  for ca=0.0110 */
float init10	=	0.1615	/*  for ca=0.0110 */
float init01	=	0.0781	/*  for ca=0.0110 */
float init000	=	0.325	/*  for ca=0.0110 */
float init100	=	0.0	/*  for ca=0.0110 */
float init010	=	0.435	/*  for ca=0.0110 */
float init001	=	0.103	/*  for ca=0.0110 */
float init101	=	0.0	/*  for ca=0.0110 */
float init011	=	0.137	/*  for ca=0.0110 */
float init110	=	0.0	/*  for ca=0.0110 */

float maxiicr   =   0.16             /* Units are /msec */
int iicrpower	=	3
float maxcicr	=	0.08
int cicrpower	=	1
float serca     =   0.0006           /* Units are mmole/msec */
float pumppower	=	2
float ERfactor	=	0.185	/*0.185 ratio of ER volume to cyt vol */

float kncx = 1.0e-3     /*mmoles*/
float Vncx = 2400
float kpmca = 0.2e-3    /*mmoles*/
float Vpmca = 2.0e-11   /*mmoles/msec/cm^2 */
float Vpmcarhab = 0
float Vncxrhab = 0
float Vncxaxon = 110
float Vpmcaxon = 1.6e-12  /*mmoles/msec/cm^2 */
int pmca_power =	1

float ip3dif    =       2.83e-9 /* cm^2/msec - Allbritton et al. 1992  */
float ip3init   =       0.0e-3  /* */
float ip3degrad =       0.7e-3 /* IP3 degradation - per msec - Allbritton et al. 1992*/

float Rhodtot	=	10000	/* uM*/
float krhoF	=	1e-6	/* per msec */
int duration	=	3000	/* msec*/
float intensity	=	10.0	/* isomerizations per msec */
			/* 0.01 = ND3, 0.1 = ND2, 1.0 = ND1, 10.0 = ND0 */
int lightdelay	=	10	/*msec*/
float deplete_power	=	0.16	/* decrease in mrho effectiveness = 1/ time^deplete_factor */


float RKArrtot	=	30	/* uM */
float Krkf	=	0.5e-3	/* per msec - uM */
float Krkb	=	5.0e-3	/* per msec */
float Krkcat	=	5e-3	/* per msec */

float Gtot	=	1000	/* uM */
float Kgf	=	6e-3	/* per msec - uM */
float Kgb	=	10e-3	/* per msec */
float Kgcat	=	1920e-3	/* per msec */
float Khyd	=	0.0057e-3  /* per msec */

float Kplcf	=	100e-3 /* per uM per msec */
float Kplcb	=	0.2e-3 /* per msec */
float plctot	=	100	/* uM */
float piptot	=	160	/* uM */
float Kpif	=	0.83e-3	/* per uM per msec */
float Kpib	=	0.1e-3	/* per msec */
float Kpicat1   =       10.0e-3   
float Kpicat2	=	6.0e-3  /* per msec */
float Kgap	=	3e-3	/* per msec */

float Gprot_syn	=	100
float plc_syn	=	10
float gabab_kf 	=	0.06	/* modified to produce EC50 of 1.5 uM */
float gabab_kb 	=	0.5
float recept_tot 	=	1.0	/* unitless or uM */
float gabab_gf	=	2.0
float gabab_gb	=	0.5		/* g5 modified to slow down peak curren
t, g4 not significant */
float gabab_gcat =	0.5
