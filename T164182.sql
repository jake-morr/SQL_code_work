select ACADEMIC_PERIOD, PRIMARY_ADVISOR_NAME_LFMI, PRIMARY_ADVISOR_EMAIL, SECONDARY_ADVISORS
,cohorts, characteristics, RET_PROGRAM, STUDENT_NAME, EWU_ID,NET_ID,EMAIL
,MAJOR_DESC, FIRST_MINOR_DESC, FIRST_CONCENTRATION_DESC, ACADEMIC_STANDING_DESC

,(SELECT max(ast2.academic_standing_desc) 
       from ACADEMIC_STUDY AST2
       where AST2.PERSON_UID = PERSON_UID
       and AST2.ACADEMIC_PERIOD = previous_term
       )AS previous_acad_standing
       
, SUBJECT,COURSE_NUMBER, COURSE_SECTION_NUMBER, COURSE_REFERENCE_NUMBER, COURSE_TITLE_SHORT, campus_desc
, start_date, end_date
, days1
, CASE WHEN substr(begin_time1,1,2) IN ('07','08','09','10','11') THEN substr(begin_time1,1,2)||':'||substr(begin_time1,3,2)||'AM'
       WHEN substr(begin_time1,1,2) = '12' THEN substr(begin_time1,1,2)||':'||substr(begin_time1,3,2)||'PM' 
       WHEN (substr(begin_time1,1,2) > '12' AND substr(begin_time1,1,2) <= '24') THEN substr(begin_time1,1,2)-12||':'||substr(begin_time1,3,2)||'PM' 
       ELSE null END AS beg_time1
, CASE WHEN substr(end_time1,1,2) IN ('07','08','09','10','11') THEN substr(end_time1,1,2)||':'||substr(end_time1,3,2)||'AM'
       WHEN substr(end_time1,1,2) = '12' THEN substr(end_time1,1,2)||':'||substr(end_time1,3,2)||'PM' 
       WHEN (substr(end_time1,1,2) > '12' AND substr(end_time1,1,2) <= '24') THEN substr(end_time1,1,2)-12||':'||substr(end_time1,3,2)||'PM' 
       else null end as end_time1
, days2
, CASE WHEN substr(begin_time2,1,2) IN ('07','08','09','10','11') THEN substr(begin_time2,1,2)||':'||substr(begin_time2,3,2)||'AM'
       WHEN substr(begin_time2,1,2) = '12' THEN substr(begin_time2,1,2)||':'||substr(begin_time2,3,2)||'PM' 
       WHEN (substr(begin_time2,1,2) > '12' AND substr(begin_time2,1,2) <= '24') THEN substr(begin_time2,1,2)-12||':'||substr(begin_time2,3,2)||'PM' 
       ELSE null END AS beg_time2
, CASE WHEN substr(end_time2,1,2) IN ('07','08','09','10','11') THEN substr(end_time2,1,2)||':'||substr(end_time2,3,2)||'AM'
       WHEN substr(end_time2,1,2) = '12' THEN substr(end_time2,1,2)||':'||substr(end_time2,3,2)||'PM' 
       WHEN (substr(end_time2,1,2) > '12' AND substr(end_time2,1,2) <= '24') THEN substr(end_time2,1,2)-12||':'||substr(end_time2,3,2)||'PM' 
       else null end as end_time2
, REGISTRATION_STATUS, REGISTRATION_STATUS_DESC
, COURSE_CREDITS, CREDITS_EARNED, CREDITS_FOR_GPA, CUM_CREDITS_ATTEMPTED,CUM_CREDITS_EARNED,CUM_GPA
, FINAL_GRADE_DATE
, FINAL_GRADE
, GENDER_desc
, race
, pell
, HS_GPA
, high_act_engl
, high_sat_writ

       
from (
SELECT DISTINCT STC.ACADEMIC_PERIOD, ast.primary_advisor_name_lfmi,pd.email_preferred_address as primary_advisor_email, pd.gender_desc
, odsmgr.ZGKI_COMMON.f_get_race_federal(ast.person_uid,ast.academic_period) race 
, ODSMGR.ZRKO_COMMON.F_FINAID_PELL_RECIPIENT_TERM(Ast.PERSON_UID,ast.ACADEMIC_PERIOD) AS PELL
, PES.SS_SCHOOL_GPA HS_GPA
, T.high_act_engl
, T.high_sat_writ

,(select listagg(adv3.ADVISOR_NAME_LFMI, '; ')within group (order by adv3.advisor_name_lfmi)
FROM ADVISOR adv3
WHERE adv3.person_uid = stu.person_uid
AND adv3.academic_period = stu.academic_period
AND adv3.primary_advisor_ind != 'Y') AS secondary_advisors

,(SELECT listagg(CASE WHEN COH.COHORT_DESC IS NULL THEN COH.COHORT ELSE COH.COHORT||' - '||COH.COHORT_DESC END, '; ') WITHIN GROUP (ORDER BY COH.COHORT)
FROM STUDENT_COHORT COH
   where COH.PERSON_UID = stc.person_uid
   AND COH.ACADEMIC_PERIOD = stc.academic_period
AND COH.COHORT_ACTIVE_IND = 'Y'
and (coh.cohort like 'AEA%' or coh.cohort like 'FOCUS%' or coh.cohort in ('CAMPACC','EOP','OFIR', 'OSRD','TRIO'))
GROUP BY COH.PERSON_UID
) AS COHORTS

, (SELECT listagg(c.cohort, ';  ')  WITHIN GROUP (ORDER BY cohort)
   from STUDENT_COHORT C
   where C.PERSON_UID = stc.person_uid
   AND C.ACADEMIC_PERIOD = stc.academic_period
   AND COHORT_ACTIVE_IND = 'Y'
   and c.cohort in ('OFIR', 'OSRD', 'RET', 'CAMPSLF') 
   GROUP BY person_uid  ) AS characteristics
   
, (SELECT listagg(c.cohort, ';  ')  WITHIN GROUP (ORDER BY cohort)
   from STUDENT_COHORT C
   where C.PERSON_UID = stc.person_uid
   AND C.ACADEMIC_PERIOD = stc.academic_period
   AND COHORT_ACTIVE_IND = 'Y'
   AND (c.cohort IN ('EOP', 'TRIO','CAMPACC') OR c.cohort LIKE 'AEA%' OR C.COHORT LIKE 'FOCUS%')
   group by C.PERSON_UID  ) as RET_PROGRAM

, STC.name as STUDENT_NAME, STC.id as EWU_ID,LOWER(PDS.USER_NAME) as NET_ID, pd2.email_preferred_address as email
,AST.MAJOR_DESC, AST.FIRST_MINOR_DESC, AST.FIRST_CONCENTRATION_DESC, AST.ACADEMIC_STANDING_DESC

  ,         ( --get the term prior to the current term
                                   select prev_term
                                  FROM
                                    ( --inline view for term code translation table
                                      select
                                      T2.ACADEMIC_PERIOD,lag(t2.academic_period,1) OVER (ORDER BY t2.academic_period) as lag1,
                                      CASE WHEN substr(lag(t2.academic_period,1) OVER (ORDER BY t2.academic_period),5,2) in ('35') THEN
                                      (LAG(T2.ACADEMIC_PERIOD,4) over (order by T2.ACADEMIC_PERIOD))
                                      when SUBSTR(LAG(T2.ACADEMIC_PERIOD,1) over (order by T2.ACADEMIC_PERIOD),5,2) in ('10') then
                                      (LAG(T2.ACADEMIC_PERIOD,3) over (order by T2.ACADEMIC_PERIOD))
                                      when SUBSTR(LAG(T2.ACADEMIC_PERIOD,1) over (order by T2.ACADEMIC_PERIOD),5,2) in ('15','30') then
                                      (LAG(T2.ACADEMIC_PERIOD,2) over (order by T2.ACADEMIC_PERIOD))
                                      when SUBSTR(LAG(T2.ACADEMIC_PERIOD,1) over (order by T2.ACADEMIC_PERIOD),5,2) in ('40') then
                                      (lag(t2.academic_period,1) OVER (ORDER BY t2.academic_period))
                                      else (lag(t2.academic_period,2) OVER (ORDER BY t2.academic_period)) end AS prev_term
                                      FROM year_type_definition t2 
                                      where 1=1 and YEAR_TYPE = 'ACYR'
                                      and t2.academic_period > '201340'
                                      ORDER BY academic_period
                                      ) T3
                                      where T3.ACADEMIC_PERIOD = stu.ACADEMIC_PERIOD
                                     ) as PREVIOUS_TERM
                                     
, STC.SUBJECT,STC.COURSE_NUMBER, STC.COURSE_SECTION_NUMBER, STC.COURSE_REFERENCE_NUMBER, STC.COURSE_TITLE_SHORT
, STC.REGISTRATION_STATUS, STC.REGISTRATION_STATUS_DESC
, STC.COURSE_CREDITS, STC.CREDITS_EARNED, STC.CREDITS_FOR_GPA, GPC.CREDITS_ATTEMPTED AS CUM_CREDITS_ATTEMPTED,GPC.CREDITS_EARNED AS CUM_CREDITS_EARNED,ROUND(GPC.GPA,3) AS CUM_GPA
, STC.CAMPUS_DESC
, mt1.start_date, mt1.end_date
, mt1.monday_ind||mt1.tuesday_ind||mt1.wednesday_ind||mt1.thursday_ind||mt1.friday_ind||mt1.saturday_ind||mt1.sunday_ind as days1
, mt1.begin_time as begin_time1, mt1.end_time as end_time1
, mt2.monday_ind||mt2.tuesday_ind||mt2.wednesday_ind||mt2.thursday_ind||mt2.friday_ind||mt2.saturday_ind||mt2.sunday_ind as days2
, mt2.begin_time as begin_time2, mt2.end_time as end_time2
, STC.FINAL_GRADE_DATE
, LTRIM(RTRIM(STC.FINAL_GRADE,')'),'(') AS FINAL_GRADE

FROM STUDENT STU

JOIN STUDENT_COURSE STC
ON STU.PERSON_UID = STC.PERSON_UID
AND STU.ACADEMIC_PERIOD = STC.ACADEMIC_PERIOD

left join meeting_time mt1
on mt1.course_reference_number = stc.course_reference_number
and mt1.academic_period = stc.academic_period
and mt1.category = '01'

left join meeting_time mt2
on mt2.course_reference_number = stc.course_reference_number
and mt2.academic_period = stc.academic_period
and mt2.category = '02'

JOIN ACADEMIC_STUDY AST
ON STU.PERSON_UID = AST.PERSON_UID
AND STU.ACADEMIC_PERIOD = AST.ACADEMIC_PERIOD

left JOIN PERSON_DETAIL PD
ON ast.primary_advisor_person_uid = PD.PERSON_UID

left JOIN PREVIOUS_EDUCATION_SLOT PES
ON PES.PERSON_UID = STU.PERSON_UID

JOIN person_detail_supp_ewu pds
ON pds.person_uid = stu.person_uid

LEFT JOIN gpa gpc
ON STU.PERSON_UID = GPC.PERSON_UID
      AND gpc.gpa_grouping = 'C'
      AND gpc.gpa_type = 'O'
      and gpc.ACADEMIC_STUDY_VALUE = AST.student_level

left Join (SELECT   --inline view for test scores
             person_uid,
             MAX(CASE WHEN TEST = 'S02' AND TEST_SOURCE != 'STDN' THEN test_score
                 WHEN TEST = 'S02' AND TEST_SOURCE =  'STDN' THEN TEST_SCORE
                 ELSE NULL END) AS high_sat_math,
		     MAX(CASE WHEN TEST = 'S02' AND TEST_SOURCE != 'STDN' THEN test_score
                 WHEN TEST = 'S01' AND TEST_SOURCE =  'STDN' THEN TEST_SCORE
                 ELSE NULL END) AS high_sat_read,
             MAX(CASE WHEN TEST = 'S11' AND TEST_SOURCE != 'STDN' THEN test_score
                 WHEN TEST = 'S11' AND TEST_SOURCE =  'STDN' THEN TEST_SCORE
                 ELSE NULL END) AS high_sat_writ,
             MAX(CASE WHEN TEST = 'A02' AND TEST_SOURCE != 'STDN' THEN test_score
                 WHEN TEST = 'A02' AND TEST_SOURCE =  'STDN' THEN TEST_SCORE
                 ELSE NULL END) AS high_act_math,
             MAX(CASE WHEN TEST = 'A01' AND TEST_SOURCE != 'STDN' THEN test_score
                 WHEN TEST = 'A01' AND TEST_SOURCE =  'STDN' THEN TEST_SCORE
                 ELSE NULL END) AS high_act_engl
           FROM TEST
           group by test.person_uid, person_uid
          ) t
on t.person_uid = STU.person_uid

JOIN person_detail pd2
ON STU.PERSON_UID = PD2.PERSON_UID

where STC.ACADEMIC_PERIOD = $P{TermsAllODS}
and (stu.id = $P{Manual_Input} or $P{Manual_Input} = 'ALL')

AND STC.COURSE_NUMBER < '500'
AND STC.COLLEGE_DESC NOT IN ('ACADEMIC AFFAIRS')
AND STC.COURSE_REFERENCE_NUMBER NOT IN ('SG001','SG004','SG007')
AND STC.GRADE_TYPE_DESC != 'Transfer'
AND STC.subject NOT LIKE 'Z%'
order by UPPER(STC.name)
)
