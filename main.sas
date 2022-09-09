/*rndhrs_hlth_trs_data*/

/* ====================================================================== */
/* DELETE CACHE */
/* ====================================================================== */

/* delete all the files in the work library */
proc datasets library=work kill;
run;
quit;

/* delete macro 
	Downloaded from <https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/mcrolref/p0j1htu10wsx9tn1mig5g0b8mxxb.htm>
*/

%macro delvars;
  data vars;
    set sashelp.vmacro;
  run;

  data _null_;
    set vars;
    temp=lag(name);
    if scope='GLOBAL' and substr(name,1,3) ne 'SYS' and temp ne name then
      call execute('%symdel '||trim(left(name))||';');
  run;

%mend delvars;

%delvars

/* ====================================================================== */
/* USER DEFINED MACRO VARIABLES */
/* ====================================================================== */

/* CHANGE the home directory */
%let DIR = C:\Users;

/* CHANGE the name of the folder where the downloded dataset is saved */
/*    there can be multiple projects associated with the same dataset */
%let VERSION = randhrs1992_2018v2;

/* CHANGE the working project folder */
%let PROJECT = git health trs;

/* CHANGE the list of time-dependent and time-independent variables 
codeRaVars.sas 
	define a macro variable RaVars that lists time-independent variables (except for &idVar)

codeRxSufxlst.sas
	define a macro variable RxSufxlst that lists suffix of time dependent variables
*/
%include "&DIR\&PROJECT\codeRaVars.sas"; 
%include "&DIR\&PROJECT\codeRxSufxlst.sas"; 

/* list the year of interview */
%let YEAR1 = 1992;
%let YEAR2 = 1994;
%let YEAR3 = 1996;
%let YEAR4 = 1998;
%let YEAR5 = 2000;
%let YEAR6 = 2002;
%let YEAR7 = 2004;
%let YEAR8 = 2006;
%let YEAR9 = 2008;
%let YEAR10 = 2010;
%let YEAR11 = 2012;
%let YEAR12 = 2014;
%let YEAR13 = 2016;
%let YEAR14 = 2018;

/* use data from 1998 onwards */
%let firstwv = 4;
%let lastwv = 14;

/* define the variable that represents individual identifier */
%let idVar = HHIDPN;

/* define health states */
%let FD_STATE = 2; *functional disabled state ;
%let DEAD_STATE = 3; *dead state;




/* ====================================================================== */
/* IMPORT MACRO FUNCTIONS */
/* ====================================================================== */
%let MACRODIR = &DIR\&PROJECT\sas_macro;
%include "&MACRODIR\wvlist.mac"; /* to use %wvlist() */
%include "&MACRODIR\multilong.sas"; 
%include "&MACRODIR\calAge.sas"; 

libname randhrs "&DIR\&VERSION" ACCESS=READONLY;
libname dataset "&DIR\&PROJECT\data";

options fmtsearch = (WORK randhrs library);


/* create a formats catalogue (skip if formats has been created)	
NB: turn off ACCESS=READONLY in 
	libname randhrs "&DIR\&VERSION" ACCESS=READONLY;
	before runing proc format
*/
/*proc format library=randhrs cntlin=randhrs.sasfmts;*/
/*run;*/



/* ====================================================================== */
/* SELECT USEFUL VARIABLES */
/*	skip if no changes made to RaVars or RxSufxlst*/
/* ====================================================================== */

data dataset.rndhrs_select_var;
set randhrs.&VERSION;

/* keep useful variables */
keep &idVar &RaVars %wvlist(R, &RxSufxlst, begwv=&firstwv, endwv=&lastwv);
run;


/* ====================================================================== */
/* WIDE TO LONG TRANSPOSE */
/* ====================================================================== */

/* remove RABDATE (date of birth) missing*/
data rndhrs_birth rndhrs_birth_nr;
set dataset.rndhrs_select_var;
if missing(RABDATE) then output rndhrs_birth_nr;
else output rndhrs_birth;
run;

/* transpose from wide to long */
%multilong(rndhrs_birth, rndhrs_Rx, &idVar, R, &RxSufxlst, begwv = &firstwv, endwv = &lastwv);


/* select time independent variables and merge with the long file*/
data rndhrs_Ra;
set dataset.rndhrs_select_var;

keep &idVar &RaVars;
run;

/* merge files */
data rndhrs_RaRx; 
merge rndhrs_Ra(in=a) rndhrs_Rx(in=b);
by &idVar;
if b;
run;


/*-------------------------------------*/
/* save to the library*/

data dataset.rndhrs_long;
set rndhrs_RaRx; 
run;




/* ====================================================================== */
/* CLEAN THE LONG FORM  */
/* - SUBSET THE RESPONSE SAMPLE */
/* - ADD HEALTH STATE VARIABLE (RxHSTATE) */
/* - CHECK MISSING DEATH YEAR */
/* - ADD DATE VARIABLE (RxDATE) */
/* ====================================================================== */

/* subset the response sample based on RxIWSTAT */

data resp_sample drop_sample;
set dataset.rndhrs_long;

if RxIWSTAT in (1, 5) then output resp_sample;
else output drop_sample;

run;

/* select those who were 50 and above in their first responses */
%let MIN_AGE = 50;

data age_join;
set resp_sample;
by &idVar;
if first.&idVar;
keep &idVar RxAGEY_E;
run;

data age_join_ge;
set age_join;
if RxAGEY_E >= &MIN_AGE;
run;

data resp_sample_age_ge;
merge age_join_ge (in=a) resp_sample;
by &idVar;
if a;
run;


/* create RxHSTATE based on ADLs */
data resp_health resp_health_nr;
set resp_sample_age_ge;

RxADL = RxWALKRA + RxDRESSA + RxBATHA + RxEATA + RxBEDA + RxTOILTA;

/* RxHSTATE
1. healthy		(difficulty in 0 - 1 ADLs)
2. disabled		(difficulty in 2 - 6 ADLs)
3. dead
*/
if RxADL in (0, 1) then RxHSTATE = 1;
else if RxADL >= 2 then RxHSTATE = &FD_STATE;
else if RxIWSTAT = 5 then RxHSTATE = &DEAD_STATE;
else RxHSTATE = .;

if missing (RxHSTATE) then output resp_health_nr; /* no record of health status*/
else output resp_health;

run;


/*------------------------------------------*/
/* CHECK MISSING DEATH YEAR                 */
/* remove death year missing - NO OBS FOUND */
data null;
set resp_health;
if missing(RADDATE) and RxHSTATE = &DEAD_STATE;
run;
/*------------------------------------------*/


/* add RxDATE */
data resp_health_date;
set resp_health;

if RxHSTATE ~= &DEAD_STATE then RxDATE = RxIWEND;
else RxDATE = RADDATE;

RxYEAR = year(RxDATE);
run;


data resp_select_var;
set resp_health_date;

if RAGENDER = 2 then RAFEMALE = 1;
else RAFEMALE = 0;

keep &idVar RAFEMALE WAVE RABDATE RxHSTATE RxYEAR RxDATE;

run;


/* check */
proc freq data=resp_select_var;
table WAVE*RxYEAR / norow nocol nocum nopercent missing;
run;

/* end of check */




/*-------------------------------------*/
/* save to the library*/

data dataset.resp_select_var;
set resp_select_var;
run;


/*====================================================*/
/* CREATE TRANSIT DATASETS */
/*====================================================*/

data transit_prep;
set dataset.resp_select_var;
run;

data rndhrs_wave_transit rndhrs_wave_transit_nr;
format 
&idVar RAFEMALE RABDATE 
WAVE WAVE2 RxYEAR RxYEAR2 RxDATE RxDATE2 RxHSTATE RxHSTATE2;

set transit_prep;
by &idVar;
set transit_prep ( firstobs = 2 keep = WAVE RxYEAR RxDATE RxHSTATE
								rename = (WAVE=WAVE2 RxYEAR=RxYEAR2 RxDATE=RxDATE2 RxHSTATE=RxHSTATE2) )
    transit_prep (      obs = 1 drop = _all_                                     );

RxHSTATE2 = ifn(  last.&idVar, (.), RxHSTATE2 );

if not missing(RxHSTATE2) then output rndhrs_wave_transit;
else output rndhrs_wave_transit_nr;

run;

/* CLEAN date */
data transit_date_valid transit_date_invalid;
set rndhrs_wave_transit;
if RxDATE >= RxDATE2 then output transit_date_invalid;
else output transit_date_valid;
run;


/*------------------------------------------*/
/* CHECK INVALID TRANSITION                 */
/* remove RxHSTATE = &DEAD_STATE - NO OBS FOUND */
data null;
set transit_date_valid;
if RxHSTATE = &DEAD_STATE;
run;
/*------------------------------------------*/


/* add age */
data transit_wave;
set transit_date_valid;

%calAge(agevar=RxAGE, dob=RABDATE, eventdate=RxDATE);
%calAge(agevar=RxAGE2, dob=RABDATE, eventdate=RxDATE2);

run;

/*-----------------------------------------*/
/*save to library*/

data dataset.transit_wave;
set transit_wave;
run;


/* checks */

/* count no. of transitions */
proc tabulate data=dataset.transit_wave;
class RxAGE RxHSTATE RxHSTATE2;
var &idVar;
table RxAGE*RxHSTATE all, RxHSTATE2 all;
where RxHSTATE~=RxHSTATE2;
format RxAGE 3.;

run;

/* end of checks */

/*====================================================*/
/* EXPORT TO CSV */
/*====================================================*/

data csv_prep;
set dataset.transit_wave;
keep &idVar RAFEMALE WAVE WAVE2 RxYEAR RxYEAR2 RxHSTATE RxHSTATE2 RxAGE RxAGE2;
run;

proc export data=csv_prep
   outfile="&DIR\&PROJECT\rndhrs_transit.csv"
   dbms=csv
   replace;
run;
