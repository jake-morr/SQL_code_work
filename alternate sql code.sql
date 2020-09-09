select college_desc "COLLEGE"
, course_identification
, course_section_number
, count (distinct person_uid) "COUNT_OF_STUDENTS"
, sum (course_billing_credits ) "SUM_OF_BILLING_CREDITS"
, academic_period

from census_student_course

where (course_section_number like '%75%' or course_section_number like '%76%')
and academic_period between '201930' and '202020'
group by college_desc, course_identification, course_section_number, academic_period
order by college_desc, academic_period