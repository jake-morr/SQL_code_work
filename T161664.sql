select StC.ID
, StC.Name
, StC.course_identification Course
, StC.course_section_number Section
, StC.academic_period
, pes.ss_school_gpa HS_GPA
, ZSKO_TRANSCRIPTS.F_GET_OVRL_CUM_GPA_TERM(StC.person_uid,StC.academic_period) CUM_GPA
, ZSKO_TRANSCRIPTS.F_GET_OVRL_CUM_CR_TERM(StC.person_uid,StC.academic_period) CUM_CREDITS
, StC.registration_status_date
--, AcSt.admissions_population_desc

from student_course StC

left join previous_education_slot pes
on pes.person_uid = StC.person_uid

left join academic_study AcSt
on AcSt.person_uid = StC.person_uid
and AcSt.academic_period = StC.academic_period


where (AcSt.admissions_population in ('AI','AL','CA','CR','FB','FC','FI','FO','FR','GD','IE','IN','RH'))
and StC.course_identification = 'MTHD103'
and StC.academic_period = '202040'

and (not exists (select 'X'
from TEST t
where t.test = 'ALEK'
and StC.person_uid = t.person_uid))

and (not exists ( select 'X'
from student_course StC2
where StC2.course_identification = 'MTHD103'
--and StC2.final_grade is not null
and StC2.academic_period < '202040'
and StC2.person_uid = StC.person_uid))

--where T.test_type_desc -- alek does not exist
--where StC.course_identification MTHD103 does not exist prior to 202040
