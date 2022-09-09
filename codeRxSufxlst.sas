%let RxSufxlst = 
/* Wave Status: Interview Status */
/* 0.Inap.
1.Resp,alive
4.NR,alive 
5.NR,died this wv
6.NR,died prev wv
7.NR,dropped from samp */
IWSTAT 

/* Interview End Date*/
IWEND 

/* Age at interview (in months and years) */
/* Note: According to HRS, when there are different beginning and ending interview dates, most of the interview is usually
		conducted on the ending date. Thus, it is probably best to use the RwAGEM_E and RwAGEY_E variables for Respondent
		age at each interview.*/
AGEM_E 
AGEY_E

/* Activities of daily living (ADLs): Raw recodes Wave */
WALKR	/* Diff-Walk across room */
WALKRH	/* Gets Help-Walk across room */
WALKRE	/* Eqp-Walk across room */
DRESS	/* Diff-Dressing */
DRESSH	/* Gets Help-Dressing */
BATH	/* Diff-Bathing or showerng */
BATHH	/* Gets Help-Bathing, showerng */
EAT	/* Diff-Eating */
EATH	/* Gets Help-Eating */
BED	/* Diff-Get in/out of bed */
BEDH	/* Gets Help-Get in/out of bed */
BEDE	/* Use Eqp-Get in/out of bed */
TOILT	/* Diff-Using the toilet */
TOILTH	/* Gets Help-Using the toilet */


/* Activities of daily living (ADLs): Some difficulty */
WALKRA	/* Some Diff-Walk across room */
DRESSA	/* Some Diff-Dressing */
BATHA	/* Some Diff-Bathing, shower */
EATA	/* Some Diff-Eating */
BEDA	/* Some Diff-Get in/out bed */
TOILTA	/* Some Diff-Using the toilet */


;