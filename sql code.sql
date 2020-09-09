select *
from
(select distinct enr.person_uid
, enr.name
, enr.id
, enr.person_uid person
, MAX (AO.graduated_ind) over (partition by enr.person_uid,enr.academic_period) graduated_ind

from census_enrollment enr 

join academic_study AcSt
on enr.person_uid = AcSt.person_uid
and enr.academic_period = AcSt.academic_period

left join academic_outcome AO
on AO.person_uid = enr.person_uid 



where (not exists (select 'X'
                from enrollment enr1
                where enr1.academic_period in ('202040','202035')
                and enr1.registered_ind = 'Y'
                and enr.person_uid = enr1.person_uid))
and enr.academic_period in ('202010','202020')
and enr.registered_ind = 'Y'
and AcSt.student_level in ('UG','US')) data
where (graduated_ind is null or graduated_ind = 'N')
order by data.person
