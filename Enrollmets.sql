select distinct StC.person_uid
    , StC.academic_period
    , AcSt.major_desc "Major"
	, AcSt.COLLEGE_DESC "college"
    , max(AO.graduated_ind)
from student_course StC

left join
    (select person_uid
    , academic_period
    , major_desc
    , primary_program_ind
	, COLLEGE_DESC
    from academic_study
	where primary_program_ind = 'Y') AcSt
on AcSt.person_uid = StC.person_uid 
and AcSt.academic_period = StC.academic_period

left join
    (select person_uid
    , academic_period
    , graduated_ind
    from academic_outcome) AO
on AO.person_uid = StC.person_uid

--where registration_status in ('RW', 'RE', 'RI') 
where StC.academic_period between '201140' and '202020' group by StC.person_uid, StC.academic_period, AcSt.major_desc, AcSt.COLLEGE_DESC
order by person_uid