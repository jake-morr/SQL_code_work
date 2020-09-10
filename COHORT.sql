
select distinct person_uid
, ID 
--, case when substr(academic_period,5,2) = '30' then 'Y' else academic_period end
, case when 
    substr((max (academic_period) over (partition by person_uid)),5,2) = '30' 
    then replace(max (academic_period) over (partition by person_uid),'30','40') 
    else (max (academic_period) over (partition by person_uid)) 
    end COHORT
, max (academic_period_desc) over (partition by person_uid) academic_period_desc
, student_population_desc

from academic_study
where student_population in ('F','B','I','P') 
and academic_period >= '200640'
and registered_ind = 'Y'
and student_level in ('UG','US')
--group by person_uid, ID, student_population_desc
order by person_uid
;
