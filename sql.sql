/*Program:   Ticket #SR-888156930 Jasper Report Request
Description: Custom report request for students that received XC grades

History
Date        Name                Description
5-May-2020 Jake Morrison        Created Program            
============================================================================================================*/

SELECT DISTINCT 
      STC.NAME
	, STC.ID AS "Student ID"
	, PDT.EMAIL_PREFERRED_ADDRESS AS "Email Address"
	, max (ADS.Student_Classification) over (partition by STC.person_uid) AS "Class Standing"
    , ADO.ACADEMIC_PERIOD_DESC AS "Academic Period"
    , max(ADO.STATUS_DESC) over (partition by STC.person_uid) as "Latest Status"
    , ADO.OUTCOME_APPLICATION_DATE AS "Application Date"
    , ADO.ACADEMIC_PERIOD_GRAD_DESC as "Graduation Term"
	, STC.COURSE_IDENTIFICATION AS "Course Number"
	, SO.PRIMARY_INSTRUCTOR_LAST_NAME as "Instructor"
	, STC.COLLEGE_DESC AS "College of Course" 
	, max(ADS.MAJOR_DESC) over (partition by STC.Person_uid) AS "Major"
	, max(ads.PRIMARY_ADVISOR_NAME_FMIL) over (partition by STC.person_uid) as "Advisor"

FROM STUDENT_COURSE STC
LEFT JOIN ACADEMIC_STUDY ADS 
  ON STC.PERSON_UID = ADS.PERSON_UID
--(keep out) LEFT JOIN ADVISOR ADV ON STC.PERSON_UID = ADV.PERSON_UID
LEFT join ACADEMIC_OUTCOME ADO
  ON STC.PERSON_UID = ADO.PERSON_UID
--(keep out) LEFT JOIN INSTRUCT_ASSIGN_SLOT IAS ON STC.COURSE_REFERENCE_NUMBER = IAS.COURSE_REFERENCE_NUMBER
join schedule_offering SO
  on stc.ACADEMIC_PERIOD = so.academic_period
and stc.course_reference_number = so.course_reference_number
LEFT JOIN PERSON_DETAIL PDT ON STC.PERSON_UID = PDT.PERSON_UID
WHERE STC.FINAL_GRADE = 'XC'
--    AND ADV.PRIMARY_ADVISOR_IND = 'Y'
   --AND ADO.STATUS != 'AW' -- this doesnt get rid of previous AO or AP records
    and stc.academic_year = '2020' --***I saw that all the records had this year in common, so I added this filter to shorten the search time
ORDER BY STC.NAME