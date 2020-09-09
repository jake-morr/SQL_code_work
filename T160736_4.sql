select 
 stc.name
, stc.id
, stc.academic_period
, course_identification
, stc.final_grade

from student_course stc
 
inner join
 (select name, id, final_grade, academic_period from student_course where course_identification = 'MATH114' and academic_period = '202020') math114
on math114.id = stc.id
 
where ((stc.course_identification = 'MTHD104' and stc.academic_period between '201840' and '202010') 
or (stc.course_identification = 'MATH114' and stc.academic_period = '202020'))
and stc.final_grade is not null
and stc.final_grade not like '%T%'
 
order by  stc.id
