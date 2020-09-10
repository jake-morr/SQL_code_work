/*Program:   Enrollment counts (Hispanic students)
Description: Data will be used to build a forecasting model to predict when EWU will reach 25% Hispanic
             students

History
Date        Name                Description
18-Nov-2019 Gordon Kordas       Created Program         
03-Jan-2020 Gordon Kordas       Add parameter to toggle cohort: all, ugrad w/no RS, ugrad w/RS   
============================================================================================================*/

/* gather distinct counts from 200640 to present */
/*select count(distinct person_uid) as students,
       student_race_group as ethnicity,
       academic_period as period
from census_student_summary
group by student_race_group,academic_period
order by academic_period
*/
select case when :cohort = 'ugrad' 
            then count(distinct ugrad.person_uid) 
            when :cohort = 'ugrad_no_ef'
            then count(distinct ugrad_no_ef.person_uid)
            else count(distinct css.person_uid) end as students, 
			css.student_race_group as ethnicity, 
			css.academic_period as period
from census_student_summary css

left join(select enr.person_uid,enr.academic_period 
             from census_enrollment enr
             join census_academic_study acs
               on acs.person_uid = enr.person_uid 
              and acs.academic_period = enr.academic_period
              and primary_program_ind = 'Y'
              and enr.total_credits >= 12
			  and acs.student_classification in ('EF','FR','SO','JR','SR')
			  and student_population not in ('E','Q') ) ugrad

on css.person_uid = ugrad.person_uid
and css.academic_period = ugrad.academic_period
              
left join(select enr.person_uid,enr.academic_period 
             from census_enrollment enr
             join census_academic_study acs
               on acs.person_uid = enr.person_uid 
              and acs.academic_period = enr.academic_period
              and primary_program_ind = 'Y'
              and enr.total_credits >= 12
			  and acs.student_classification in ('FR','SO','JR','SR')
			  and student_population not in ('E','Q')) ugrad_no_ef
              
on css.person_uid = ugrad_no_ef.person_uid
and css.academic_period = ugrad_no_ef.academic_period

group by css.student_race_group, css.academic_period
order by css.academic_period;