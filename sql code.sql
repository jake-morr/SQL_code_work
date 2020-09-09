select college_desc
, course_identification
, offering_number
, census_enrollment1
, max_credits
, academic_period

from census_schedule_offering

where (offering_number like '%75%' or offering_number like '%76%')
and academic_period between '201930' and '202020'
and census_enrollment1 != 0
order by college_desc, academic_period
