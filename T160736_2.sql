select
 stc.name
, stc.id
, stc.academic_period
, stc.course_identification
, stc.final_grade

from student_course stc

inner join
(select name, id, final_grade, academic_period from student_course where course_identification = 'MATH131' and academic_period = '202020') math131
on math131.id = stc.id
and math131.academic_period = stc.academic_period

where stc.course_identification in ('MATH114','MATH131')
and stc.academic_period = '202020'
--and stc.final_grade is not null

order by stc.id, stc.course_identification
