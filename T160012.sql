/*Program:   Ticket #SR-888156930 Jasper Report Request
Description: Custom report request for students that received XC grades

History
Date        Name                Description
5-May-2020 Jake Morrison        Created Program            
============================================================================================================*/

SELECT DISTINCT 
      StC.NAME
	, StC.ID AS "Student ID"
	, PDt.EMAIL_PREFERRED_ADDRESS AS "Email Address"
	, AcSt.Student_Classification "Class Standing"
    --, max(ADO.ACADEMIC_PERIOD_DESC) over (partition by Stc.person_uid) AS "Academic Period"
    , max(ADO.STATUS_DESC) over (partition by StC.person_uid) "Latest Status"
    , max(ADO.OUTCOME_APPLICATION_DATE) over (partition by Stc.person_uid) AS "Application Date"
    , max(ADO.ACADEMIC_PERIOD_GRAD_DESC) over (partition by Stc.person_uid) as "Graduation Term"
	, StC.COURSE_IDENTIFICATION AS "Course Number"
    , StC.Academic_period_desc "period course taken"
	, SO.PRIMARY_INSTRUCTOR_LAST_NAME as "Instructor"
	, StC.COLLEGE_DESC AS "College of Course" 
	, AcSt.MAJOR_DESC "Major"
	, AcSt.PRIMARY_ADVISOR_NAME_FMIL "Advisor"

FROM STUDENT_COURSE StC

LEFT JOIN
	(select person_uid
	, academic_period
	, student_classification
    , PRIMARY_ADVISOR_NAME_FMIL
    , major_desc
	from ACADEMIC_STUDY
    where primary_program_ind = 'Y') AcSt
ON AcSt.PERSON_UID = StC.PERSON_UID
and AcSt.academic_period = StC.academic_period

--(keep out) LEFT JOIN ADVISOR ADV ON STC.PERSON_UID = ADV.PERSON_UID

LEFT join 
	(select person_uid
	, academic_period
    , academic_period_desc
	, outcome_application_date
	, ACADEMIC_PERIOD_GRAD_DESC
    , status_desc
	from ACADEMIC_OUTCOME
    where status_desc != 'Awarded'
	and graduated_ind != 'Y') ADO
 ON STC.PERSON_UID = ADO.PERSON_UID
  
--(keep out) LEFT JOIN INSTRUCT_ASSIGN_SLOT IAS ON STC.COURSE_REFERENCE_NUMBER = IAS.COURSE_REFERENCE_NUMBER

join schedule_offering SO
on StC.ACADEMIC_PERIOD = SO.academic_period
and StC.course_reference_number = SO.course_reference_number
LEFT JOIN 
	(select person_uid
	, EMAIL_PREFERRED_ADDRESS
	from PERSON_DETAIL) PDt 
ON StC.PERSON_UID = PDt.PERSON_UID

WHERE StC.FINAL_GRADE = 'XC'
and StC.academic_period in ('202020','202010')
--AND ADO.STATUS != 'AW' --***I saw that all the records had this year in common, so I added this filter to shorten the search time
ORDER BY StC.NAME
