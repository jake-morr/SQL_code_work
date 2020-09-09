select 
 stc.name
, stc.id
, stc.academic_period
, course_identification
, stc.final_grade

from student_course stc
 
inner join
 (select name, id, final_grade, academic_period from student_course where course_identification = 'MATH107' and academic_period = '202020') math107
on math107.id = stc.id
 
where ((stc.course_identification = 'MTHD106' and stc.academic_period between '201840' and '202010') 
or (stc.course_identification = 'MATH107' and stc.academic_period = '202020'))
and stc.final_grade is not null
and stc.final_grade not like '%T%'
 
order by  stc.id