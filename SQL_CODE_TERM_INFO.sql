/*##########################################
# TITLE: REGISTRATION_TIME_ANALYSIS
# AUTHOR: Jake Morrison
# DATE:               DETAIL:
# 05/22/2020          created program
##########################################*/


select DISTINCT csc.NAME AS "name" 
, csc.ID as "ID"
, MIN (CSC.REGISTRATION_STATUS_DATE) OVER (PARTITION BY CSC.PERSON_UID, CSC.ACADEMIC_PERIOD) AS "registration_date"
, CSC.ACADEMIC_PERIOD AS "academic_period" 
, max (CS.STUDENT_LEVEL) OVER (PARTITION BY CSC.PERSON_UID, CSC.ACADEMIC_PERIOD) AS "level"
, ZSKO_TRANSCRIPTS.F_GET_OVRL_CUM_CR_TERM(CSC.person_uid,CSC.academic_period) AS "credits"
, ZSKO_TRANSCRIPTS.f_get_EWU_cum_gpa_term(CSC.person_uid,CSC.academic_period) AS "cum_gpa"
, ROUND (GPA.GPA, 3) "term_gpa"
, gpa.credits_attempted
, gpa.credits_earned
, max (CS.MAJOR_DESC) over (partition by CSC.Person_uid, csc.academic_period) AS "major"
, max(CS.PRIMARY_ADVISOR_NAME_FMIL) over (PARTITION BY CSC.person_uid,CSC.academic_period) as "advisor"
, max(CS.PRIMARY_ADVISOR_TYPE_DESC) over (PARTITION BY CSC.person_uid,CSC.academic_period) as "advisor_type"
, max (CS.Student_Classification) over (partition by CSC.person_uid, CSC.academic_period) AS "class_standing"
, case when ss.race is null then 'Unknown' else ss.race end as race
from census_student_course csc

LEFT JOIN
    (SELECT PERSON_UID,
        ACADEMIC_PERIOD
       ,STUDENT_LEVEL
       ,major_desc
       ,student_classification
       ,primary_advisor_name_fmil
       ,primary_advisor_type_desc
    FROM census_ACADEMIC_STUDY) CS
    ON CS.PERSON_UID = csc.PERSON_UID
    AND CS.ACADEMIC_PERIOD = CSC.ACADEMIC_PERIOD
LEFT JOIN
    (SELECT PERSON_UID
    , GPA
    , ACADEMIC_PERIOD
    , credits_attempted
    , credits_earned
       -- ACADEMIC_PERIOD
    FROM GPA_BY_TERM) GPA
    ON GPA.PERSON_UID = CSC.person_uid
    AND GPA.ACADEMIC_PERIOD = CSC.ACADEMIC_PERIOD

left join
    (select
        person_uid
        , academic_period
        , case when substr(student_race_group,1,1) in ('1','2','3','4','5','6','7') 
                then trim(substr(student_race_group,2,99))
            else trim(student_race_group) end as race
    from census_student_summary) ss
    on ss.person_uid = csc.person_uid
    and ss.academic_period = csc.academic_period

WHERE CSC.ACADEMIC_PERIOD between '201840' and '202020'
    AND REGISTRATION_STATUS IN ('RW', 'RE', 'RI')
ORDER BY csc.ID
;
