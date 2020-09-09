/*select distinct student_population 
,student_population_desc 
from census_academic_study 
where student_population in ('B', 'F', 'I', 'P') 
order by student_population*/

/*select distinct admissions_population, admissions_population_desc
from census_academic_study
where admissions_population in ('AI','AL','CA','CR','FB','FC','FI','FO','FR','GD','IE','IN')*/

select distinct AcSt.NAME "Name"
, stc.academic_period
--, StC.COURSE_IDENTIFICATION
, StC.FINAL_GRADE
--, StC.PERSON_UID
, AcSt.Student_classification_desc
, AcSt.admissions_population_desc
, AcSt.student_population_desc
, case when pell.person_uid is not null then '1' else '0' end as pell_recipient
, case when first_gen.person_uid is not null then '1' else '0' end as first_gen

from ACADEMIC_STUDY AcSt

inner join STUDENT_COURSE StC
on StC.PERSON_UID = AcSt.PERSON_UID
and StC.ACADEMIC_PERIOD = AcSt.ACADEMIC_PERIOD

left join				
    (select  
        person_uid
        , aid_year
    from award_by_aid_year
    where fund = 'G100'
        and total_paid_amount > 0) pell
    on pell.person_uid = AcSt.person_uid
    
left join
    (select 
        person_uid
        , academic_period
    from student_cohort
    where cohort = 'OFIR') first_gen 
    on first_gen.person_uid = AcSt.person_uid
    and first_gen.academic_period = AcSt.academic_period


where StC.SUBJECT = 'MATH'
and StC.ACADEMIC_YEAR = '2020'
AND (AcSt.student_level in ('UG','US')
                        --and AcSt.student_classification in ('FR')
                        and AcSt.admissions_population in ('AI','AL','CA','CR','FB','FC','FI','FO','FR','GD','IE','IN')
                        and AcSt.student_population in ('B','F','I','P','C')
						and AcSt.academic_period_admitted in ('201940','201945','202010','202015','202020','202030','202035') )
AND (StC.final_grade LIKE '%T%' or StC.final_grade <= 'C')
;
