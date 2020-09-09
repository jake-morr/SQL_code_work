select distinct stc.course_section_number
 , STC.academic_period "Academic Period"
, stc.course_identification "Course"
, SO.PRIMARY_INSTRUCTOR_LAST_NAME "Instructor"
, stc.final_grade "Final Grade"
, count(stc.Final_grade) "Count of Final Grade" 
from student_course STC
inner join schedule_offering SO
on stc.ACADEMIC_PERIOD = so.academic_period
and stc.course_reference_number = so.course_reference_number
where stc.course_identification in ('BIOL421', 'BIOL436', 'CHEM162', 'GEOL115', 'MATH347')
and so.primary_instructor_last_name in ('Castillo', 'Matos', 'Lamm', 'Keattch', 'Lynch')
and stc.academic_period in ('201710', '201810', '201910', '201640', '201840','201820','201720', '201740','201920')
and so.Instruction_method is null
group by stc.final_grade, stc.course_section_number, STC.academic_period, SO.PRIMARY_INSTRUCTOR_LAST_NAME, stc.course_identification
order by stc.academic_period,  stc.course_identification, STC.COURSE_SECTION_NUMBER, stc.final_grade
