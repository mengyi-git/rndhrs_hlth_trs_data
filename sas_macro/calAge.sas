/*
Calculate continuous age or discrete age
	type=c: continuous age
	otherwise, age last birthday

The macro combines the two macros written by Sara Adams and Chris Colby who wrote an article (https://www.lexjansen.com/wuss/2009/cod/COD-Adams.pdf)
 on how to accurately calculate interger and continuous age. 
 Their macros can be found in Appendix A of the article.
*/

%macro calAge(agevar=, dob=, eventdate=, type=c);

%if &type = c %then %do;
	m_age_int = floor((intck('month',&dob.,&eventdate.)-(day(&eventdate.)<day(&dob.)))/12);
	m_prior_bday_correction = (month(&dob.)eq 2)*(day(&dob.)eq 29)*
								(put(MDY(12,31,(year(&dob.)+m_age_int)),JULDAY.)eq "365");
	m_prior_bday = MDY(month(&dob.+m_prior_bday_correction),
						day (&dob.+m_prior_bday_correction),
						year (&dob.)+m_age_int);
	m_next_bday_correction = (month(&dob.)eq 2)*(day(&dob.)eq 29)*
								(put(MDY(12,31,(year(&dob.)+m_age_int+1)),JULDAY.)eq "365");
	m_next_bday = MDY(month(&dob.+m_next_bday_correction),
						day (&dob.+m_next_bday_correction),
						year (&dob.)+m_age_int+1);

	&agevar. = m_age_int + ((&eventdate. - m_prior_bday) / (m_next_bday - m_prior_bday));

	drop m_age_int m_prior_bday_correction m_prior_bday m_next_bday_correction m_next_bday;
%end;
%else %do;
	&agevar. = floor((intck('month',&dob.,&eventdate.)-(day(&eventdate.)<day(&dob.)))/12);
%end;

%mend;