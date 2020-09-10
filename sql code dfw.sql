select distinct stc.person_uid 
--, STC.academic_period
, stc.course_identification course
, Stc.academic_period
, stc.final_grade  
, AcSt.MAJOR_DESC major_at_time
, AcSt.COLLEGE_DESC college_at_time
, AcSt.student_classification
, case when athlete.person_uid is not null then 'Yes' else 'No' end as current_athlete
, AcSt.student_level
, StC.campus_desc
, Stc.instruction_method_desc
, StC.course_section_number
, StC.transfer_course_ind "transfer_course"

from student_course STC

/*&inner join schedule_offering SO
on stc.ACADEMIC_PERIOD = so.academic_period
and stc.course_reference_number = so.course_reference_number */

left join 
	(select person_uid
	, academic_period
	, major_desc
    , student_classification
	, student_level
	, college_desc
	from Academic_study
	where primary_program_ind = 'Y'
	and registered_ind = 'Y') AcSt
on AcSt.person_uid = stc.person_uid
and AcSt.ACADEMIC_PERIOD = stc.academic_period

left join 
    (select 
        person_uid
        , academic_period
    from sport 
    where sport_status in ('AC')) athlete --Note: Navigate uses the AC and NQ codes it identify current athletes
    on athlete.person_uid = stc.person_uid				
    and athlete.academic_period = stc.academic_period

--where stc.course_identification in ('EENG209', 'HSAD300', 'METC341', 'ACCT251', 'CSCD210')
where stc.academic_period >= '200640'
and stc.final_grade is not null
and AcSt.student_level in ('US','UG')
--group by stc.final_grade, STC.academic_period, stc.course_identification
order by stc.course_identification, stc.academic_period, stc.final_grade
