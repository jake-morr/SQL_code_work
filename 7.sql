select
name
, id
, academic_period
, course_identification
, final_grade

from student_course

where course_identification = 'MATH114'
and academic_period >= '201440'
--and (final_grade not like '%T%' and final_grade not like '%W%' and final_grade not like '%N%' and final_grade not like '%F%' and final_grade not like '%D%' and final_grade not like '%C-%' and final_grade not like '%P%')
--and (final_grade >= 'C' or final_grade >= '(2.0)')
and final_grade is not null