/* macro to reshape from wide to long 
	Variable names are in the format of RxSTEM
	e.g., 
	ID, R1MSTAT, R2MSTAT, R3MSTAT, R4MSTAT, R1AGEY_B, R2AGEY_B, R3AGEY_B, R4AGEY_B
	will be transposed into
	ID, WAVE, RxMSTAT, RxAGEY_B

	it uses the %wvlist() macro supplied with the RAND HRS Longitudinal File
	It can be downloaded from https://hrs.isr.umich.edu/data-products/access-to-public-data

	wideData	= data in wide form (input)
	longData	= data in long form (output)
	id			= variable name of individual identifier
	
	The following macro arguments are taken from %wvlist() 
	pref		= first character of variable
    sufxlst		= list of stem characters of variables
	begwv		= first wave to be listed
	endwv		= last wave to be listed

*/
%macro multilong(wideData, longData, id, pref, sufxlst, begwv = &firstwv, endwv = &maxwv);

   data &longData ;
      set &wideData(keep=&id %wvlist(&pref, &sufxlst, begwv = &begwv, endwv = &endwv));

		%do i = &begwv %to &endwv;
			%let ns = 1;
			%let sufx = %scan(&sufxlst,&ns);

			WAVE = &i;
			%do %while (%length(&sufx)>0);				
				&pref.x&sufx = &pref&i&sufx;

				%let ns=%eval(&ns+1);
				%let sufx=%scan(&sufxlst,&ns);
			%end;

			output;
		%end;

		drop %wvlist(&pref, &sufxlst, begwv = &begwv, endwv = &endwv);
	run;

%mend;