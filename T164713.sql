select * from (
select distinct ADA.ACADEMIC_PERIOD as APP_TERM, ada.LATEST_DECISION,ADA.id as EWU_ID,TO_CHAR(ADA.id) as ID2,LOWER(PDS.USER_NAME) as NETID, PD.LAST_NAME, PD.FIRST_NAME
,TO_CHAR(ada.APPLICATION_DATE, 'MM/DD/YYYY') as application_dt
,case when ADA.LATEST_DECISION in ('OC','CO') then TO_CHAR(ADA.LATEST_DECISION_DATE, 'MM/DD/YYYY') else null end as CONFIRM_DATE

/*,(select TO_CHAR(fts.ESTABLISHED_DATE, 'MM/DD/YYYY')
from FINAID_TRACKING_REQUIREMENT fts
where fts.AID_YEAR = 2020
and fts.REQUIREMENT = 'FAFSA'
and FTS.person_uid = ADA.person_uid) as FAFSA_ESTABLISHED_DT*/

/*,(select TO_CHAR(ftr.ESTABLISHED_DATE, 'MM/DD/YYYY')
from FINAID_TRACKING_REQUIREMENT FTR
where FTR.AID_YEAR = 2020
and FTR.REQUIREMENT = 'TERMS'
AND ftr.person_uid = ADA.person_uid) as TERMS_ESTABLISHED_DT*/

,odsmgr.zgko_common.f_get_firststep_date(ada.person_uid) AS firststep_date
  , CASE WHEN AST.college <> '00' THEN AST.college_desc
     WHEN AST.major NOT LIKE 'U%' THEN AST.college_desc
     WHEN AST.major IN ('U3DA','UART','UEAR','UARH','UECD','UECE','UEED','UEXM','UEEL','UEXN','UEEN','UFLM',
         'UFRE','UGCO','UGDS','UHUM','UJOU','UEDL','UMUS','UEMU','UPHI','UEPH','UERE','UEEM','UESS','USPA','UESP','UES',
         'UTCO','UTHT','UEDC','UEVA','UEFR','UEHF') THEN 'Arts, Letters and Education'
    WHEN AST.MAJOR IN ('UACT','UEBM','UBAD','UEBN','UBEC','UFIN','UHIT','UHMR','UMGM','UMKT','UOPS','URBS') THEN 'Business & '||'Public Admin'
    WHEN AST.MAJOR IN ('UATR','UCHE','UCMD','UDNH','UEEO','UEXT','UEXX','UHLT','UHSA','UNUR','UPBH','UPHE','UREC','URLS') THEN 'Health Science & '||'Public Health'
    WHEN AST.major IN ('UANT','UADP','UCDS','UCMS','UCRI','UEAC','UGEG','UGOV','UHIS','UINA','UITD','UMIL','UPOL','UPLA','UPSY','URAC','USOW',
         'USOC','UWMS') THEN 'Social Sciences'
    when AST.MAJOR in ('UBIO','UEBI','UCHM','UCET','UCIS','UCSC','UEES','UEXL','UEXO','UGEL','UMIS','UMAT',
         'UEMT','UMEN','UMEC','UENS','UPHY','UTEC','UVCD','UMED') then 'Science, Tech, Eng, & '||'Math' else 'No College Designated' end as COLLEGE 

,NVL(AST.department_DESC,ADA.department_DESC) as department
,NVL(AST.MAJOR,ADA.MAJOR)||' - '||NVL(AST.MAJOR_DESC,ADA.MAJOR_DESC) as MAJOR
, AST.first_minor_desc as MINOR
, AST.FIRST_CONCENTRATION_DESC as CONCENTRATION
, case when NVL(AST.MAJOR,ADA.MAJOR) like 'U%' then 'NO'
       when NVL(AST.MAJOR,ADA.MAJOR) = '0000' then 'NO' else 'YES' end as UNDECLARED

, NVL(ast.site_desc,AST.campus_desc) AS "SITE/CAMPUS"

,CASE WHEN (PED.TRANSCRIPT_RECEIVED_DATE is not null and PED.TRANSCRIPT_REVIEWED_DATE is null) then 'Y' else 'N' end as UNEVALUATED_TRANSCRIPT
,CASE WHEN ada.primary_advisor_last_name IS NOT NULL THEN ada.primary_advisor_last_name||', '||ada.primary_advisor_first_name ELSE NULL END AS advisor_Name
,CASE WHEN ada.primary_advisor_last_name IS NOT NULL THEN ada.PRIMARY_ADVISOR_TYPE ELSE NULL END AS ADVISOR_TYPE

,con.contact_type AS TYPE
,con.contact_date AS appt_date
,case when con.CONTACT_FROM_TIME||con.CONTACT_TO_TIME is null then null else con.CONTACT_FROM_TIME||' - '||con.CONTACT_TO_TIME end as appt_time
,con.interviewer_name as appt_advisor

,CASE WHEN (
    SELECT DISTINCT 'Y'
    from student_cohort c
    WHERE
      c.person_uid = ada.person_uid
      AND c.academic_period = ada.academic_period
      and COHORT_ACTIVE_IND = 'Y'
      AND c.cohort LIKE 'EOP'
  ) = 'Y' then 'Y' else 'N' end  AS Pathways

    
, (SELECT listagg(c.cohort, '#  ')  WITHIN GROUP (ORDER BY cohort)
   FROM student_cohort c
   WHERE c.person_uid = ADA.person_uid
   AND C.ACADEMIC_PERIOD = ADA.ACADEMIC_PERIOD
   AND COHORT_ACTIVE_IND = 'Y'
   and c.cohort in ('OFIR', 'OSRD', 'RET', 'CAMPSLF')
   GROUP BY person_uid  ) AS characteristics

   ,case when (SELECT LISTAGG(A.STUDENT_ATTRIBUTE, ' - ') WITHIN GROUP (ORDER BY STUDENT_ATTRIBUTE)
    FROM STUDENT_ATTRIBUTE A
    WHERE A.PERSON_UID = ADA.PERSON_UID
    AND A.ACADEMIC_PERIOD = ADA.ACADEMIC_PERIOD
    AND A.STUDENT_ATTRIBUTE IN ('PHON')
    GROUP BY PERSON_UID) IS NOT NULL THEN 'HONORS' ||'; '||
    
         (SELECT listagg(c.cohort, ' - ')  WITHIN GROUP (ORDER BY cohort)
        FROM student_cohort c
         WHERE c.person_uid = ADA.person_uid
        AND C.ACADEMIC_PERIOD = ADA.ACADEMIC_PERIOD
        AND COHORT_ACTIVE_IND = 'Y'
        AND (C.COHORT IN ('EOP', 'TRIO','CAMPACC') OR C.COHORT LIKE 'AEA%' OR C.COHORT LIKE 'FOCUS%')
        group by C.PERSON_UID  )  
   
            ELSE (SELECT listagg(c.cohort, ' - ')  WITHIN GROUP (ORDER BY cohort)
            FROM student_cohort c
            WHERE c.person_uid = ADA.person_uid
            AND C.ACADEMIC_PERIOD = ADA.ACADEMIC_PERIOD
            AND COHORT_ACTIVE_IND = 'Y'
            AND (C.COHORT IN ('EOP', 'TRIO','CAMPACC') OR C.COHORT LIKE 'AEA%' OR C.COHORT LIKE 'FOCUS%')
            GROUP BY C.PERSON_UID  )  END AS RET_PROGRAM

,pedH.SECONDARY_SCHOOL_GRAD_DATE as hs_grad_date
/*,ODSMGR.ZRKO_COMMON.F_FINAID_PELL_RECIPIENT_TERM(ADA.PERSON_UID,ADA.ACADEMIC_PERIOD) as PELL*/
,NVL(AST.STUDENT_POPULATION_DESC,ADA.STUDENT_POPULATION_DESC) as STUDENT_TYPE

, CASE   WHEN NVL(AST.STUDENT_POPULATION,ADA.STUDENT_POPULATION) in ('M') THEN 'N'
              WHEN C.COHORT = 'FTIC' THEN 'Y'
              WHEN NVL(AST.STUDENT_POPULATION,ADA.STUDENT_POPULATION) IN ('B','F','I','P') THEN 'Y' 
              ELSE 'N' END AS PRE_POP

,ADA.STUDENT_POPULATION
,NVL(AST.STUDENT_POPULATION,ADA.STUDENT_POPULATION) as STU_POP

, case when NVL(AST.STUDENT_POPULATION,ADA.STUDENT_POPULATION) in ('C','B','F','I','P','K','L','N','Q','R','S','T','U','V') then 'N'
when NVL(AST.STUDENT_POPULATION,ADA.STUDENT_POPULATION) in ('C','B','F','I','P','M','K','L','N','Q','R','S','T','U','V') then 'Y' ELSE 'Y'END AS STU_POP_LIM

,NVL(AST.student_level,ADA.student_level) as student_level

,case when (SELECT DISTINCT 'Y'
 from STUDENT_ATTRIBUTE SA

 where 1=1
 and sa.student_attribute = 'TCRS'
 AND SA.PERSON_UID = ADA.PERSON_UID
 and SA.ACADEMIC_PERIOD = (case when SUBSTR(ADA.ACADEMIC_PERIOD,5,2) = '40' then ADA.ACADEMIC_PERIOD - '20' else ADA.ACADEMIC_PERIOD +1 end)
 ) = 'Y' then 'Y' else 'N' end  as EWU_RS_PRIORITY_REG

 ,case when (
         SELECT DISTINCT 'Y'
  FROM admissions_application adap
        where 1=1
    and ADAP.PERSON_UID = ADA.PERSON_UID
    and ADAP.ACADEMIC_PERIOD in (ADA.ACADEMIC_PERIOD, ADA.ACADEMIC_PERIOD -10, ADA.ACADEMIC_PERIOD-80
    , ADA.ACADEMIC_PERIOD-180, ADA.ACADEMIC_PERIOD-110, ADA.ACADEMIC_PERIOD-100,ADA.ACADEMIC_PERIOD+10
    ,ada.academic_period-70,ada.academic_period -170,ada.academic_period-90,ada.academic_period-20,ada.academic_period-30)
    and ADAP.STUDENT_POPULATION = 'M'
    ) = 'Y' then 'Y' else 'N' end  as EWU_RS_ON_CAMPUS

,case when (odsmgr.zsko_admissions.f_get_first_gen_ind(ada.person_uid,ada.academic_period,ada.application_number)) = 'Y' then 'Y' else 'N' end AS first_gen
,odsmgr.zsko_admissions.f_get_camp_ind(ada.person_uid,ada.academic_period,ada.application_number) AS camp
,case when (
    SELECT DISTINCT 'Y'
    from student_cohort c
    WHERE
      c.person_uid = ada.person_uid
      AND c.academic_period = ada.academic_period
      and COHORT_ACTIVE_IND = 'Y'
      AND c.cohort LIKE 'AWAP%'
  ) = 'Y' THEN 'Y' ELSE 'N' END AS wap
,case when (
    SELECT DISTINCT 'Y'
    from student_cohort c
    WHERE
      c.person_uid = ada.person_uid
      AND c.academic_period = ada.academic_period
      and COHORT_ACTIVE_IND = 'Y'
      AND c.cohort LIKE 'AEAP%'
  ) = 'Y' then 'Y' else 'N' end AS ewu_advantage

,NVL(LTRIM(ps.SECONDARY_SCHOOL_REPORTED_GPA),HS_SELF_GPA) AS hs_gpa
,t.high_sat_math
,t.high_act_math
,t.high_sat_writ
,t.high_act_engl

, CASE WHEN  T.MX_S11 >= 650 OR T.MX_A01 >= 28 THEN 'ENGL 201' 
             WHEN  (T.MX_S11 BETWEEN 480 AND 649) OR (T.MX_A01 BETWEEN 15 AND 27) THEN 'ENGL 101' 
             WHEN  (T.MX_S11 BETWEEN 200 AND 479) OR ((CASE WHEN LENGTH(T.MX_A01) = '1' THEN 0||T.MX_A01 ELSE T.MX_A01 END) BETWEEN 00 AND 14)             
                   THEN 'ENGL 113/114' 
             WHEN T.MX_S01 >= 600 AND T.MX_S11 IS NULL THEN 'ENGL 201'
             WHEN (T.MX_S01 BETWEEN 450 AND 599)  AND T.MX_S11 IS NULL THEN 'ENGL 101'
             WHEN (T.MX_S01 BETWEEN 200 AND 449)  AND T.MX_S11 IS NULL THEN 'ENGL 113/114'
    ELSE NULL END AS WRIT_COMP
 
,T.MX_S01
,T.MX_S11
,T.MX_A01
,T.SB_ENGL
,T.SB_MATH
,T.ALEKS

,odsmgr.zgko_common.f_get_latest_coll(ada.person_uid,'desc') AS prior_college

, ( SELECT listagg(hold_desc, '# ')  WITHIN GROUP (ORDER BY hold)
   FROM hold h
   WHERE h.person_uid = ada.person_uid
   AND active_hold_ind = 'Y' AND registration_hold_ind = 'Y'
   GROUP BY person_uid  ) as HOLDS  --person_uid,

,NVL(trunc(gp.gpa,2),COLL_SELF_GPA) AS transfer_gpa
,gp.CREDITS_EARNED AS transfer_credits
,TRUNC(GP2.GPA,2) as EWU_GPA
,gp2.CREDITS_EARNED AS ewu_credits
,TRUNC(GP3.GPA,2) as OVERALL_GPA
,gp3.CREDITS_EARNED AS overall_credits

,ada.enrolled_ind AS enrolled
,enr.registered_ind as registered
,ENR.TOTAL_CREDITS AS TERM_CREDITS
,ODSMGR.ZGKI_COMMON.F_GET_RACE_FEDERAL(ADA.PERSON_UID,'desc') as ETHNICITY

,vis.visa_type as visa
,ABR.CITY,ABR.STATE_PROVINCE AS STATE

,( SELECT MAX(T.phone_area||'-'||T.phone_number)
  FROM TELEPHONE T
  WHERE
    t.entity_uid = ABR.ENTITY_UID
    AND T.PHONE_STATUS_IND IS NULL
    AND T.PHONE_TYPE = 'MA'
    AND T.PHONE_PRIMARY_IND = 'Y'
      ) AS MA_phone

,( SELECT MAX(T.phone_area||'-'||T.phone_number)
  FROM TELEPHONE T
  WHERE
    t.entity_uid = ABR.ENTITY_UID
    AND T.PHONE_STATUS_IND IS NULL
    AND T.PHONE_TYPE = 'PE'
    AND T.PHONE_PRIMARY_IND = 'Y'
      ) AS pe_phone

,( SELECT MAX(T.phone_area||'-'||T.phone_number)
  FROM TELEPHONE T
  WHERE
    t.entity_uid = ABR.ENTITY_UID
    AND T.PHONE_STATUS_IND IS NULL
    AND T.PHONE_TYPE = 'CE'
    AND T.PHONE_PRIMARY_IND = 'Y'
      ) AS Ce_phone

,PD.EMAIL_PREFERRED_ADDRESS as EMAIL
,(SELECT distinct lower(listagg(iat.INTERNET_ADDRESS, '# ') WITHIN GROUP (ORDER BY iat.internet_address))
    from internet_address_current iat
    where iat.entity_uid = ada.person_uid
    AND internet_address_type = 'PERS'
    group by internet_address_type
       ) AS pers_email

FROM admissions_application ada

JOIN person_detail pd
ON pd.person_uid = ada.person_uid

left JOIN contact con
ON con.person_uid = ada.person_uid
and con.contact_type in ('ADV')

left JOIN visa vis
on vis.person_uid = ada.person_uid
and vis.visa_type in ('F1','F2','J1','J2')

left JOIN PREVIOUS_EDUCATION PED
     ON ada.PERSON_UID = PED.PERSON_UID
     AND (PED.INSTITUTION_TYPE = 'C'
     AND PED.INSTITUTION <> '004301'
     AND PED.TRANSCRIPT_RECEIVED_DATE IS NOT NULL
     AND ((PED.TRANSCRIPT_RECEIVED_DATE > PED.TRANSCRIPT_REVIEWED_DATE OR
        PED.TRANSCRIPT_REVIEWED_DATE IS NULL)))

LEFT JOIN pre_student ps
ON ps.person_uid = ada.person_uid

LEFT OUTER JOIN gpa gp
ON gp.person_uid = ada.person_uid
AND gp.gpa_type = 'T' AND gp.gpa_grouping = 'C'
--and gp.ACADEMIC_STUDY_VALUE in ('UG','US')

LEFT OUTER JOIN gpa gp2
ON gp2.person_uid = ada.person_uid
AND gp2.gpa_type = 'I' AND gp2.gpa_grouping = 'C'
--and gp2.ACADEMIC_STUDY_VALUE in ('UG','US')

LEFT OUTER JOIN gpa gp3
ON gp3.person_uid = ada.person_uid
AND gp3.gpa_type = 'O' AND gp3.gpa_grouping = 'C'
--and GP3.ACADEMIC_STUDY_VALUE in ('UG','US')

LEFT OUTER JOIN ENROLLMENT ENR
ON ENR.PERSON_UID = ADA.PERSON_UID
AND ENR.ACADEMIC_PERIOD = ADA.ACADEMIC_PERIOD

LEFT JOIN ACADEMIC_STUDY AST
ON AST.PERSON_UID = ADA.PERSON_UID
AND AST.ACADEMIC_PERIOD = ADA.ACADEMIC_PERIOD
--and ast.student_level in ('UG','US')
AND AST.PRIMARY_PROGRAM_IND = 'Y'

LEFT JOIN ADDRESS_BY_RULE ABR
ON abr.entity_uid = ADA.PERSON_UID
AND ADDRESS_RULE = 'STDNADDR'

LEFT JOIN HOLD HLD
ON HLD.PERSON_UID = ADA.PERSON_UID
AND HLD.HOLD = 'HH'

JOIN person_detail_supp_ewu pds
on pds.person_uid = ada.person_uid

left outer join PREVIOUS_EDUCATION PEDH
on PEDH.PERSON_UID = ADA.PERSON_UID
and pedH.institution = ZGKO_COMMON.f_get_latest_hs(ada.person_uid,'CODE')

LEFT OUTER JOIN STUDENT_COHORT C
ON C.PERSON_UID = ADA.PERSON_UID
AND C.ACADEMIC_PERIOD = ADA.ACADEMIC_PERIOD
AND C.COHORT_ACTIVE_IND = 'Y'
AND C.COHORT = 'FTIC'

left outer join
    ( --inline view for test scores
      SELECT
        person_uid,
        MAX(CASE WHEN TEST = 'S02' AND TEST_SOURCE != 'STDN' THEN test_score
                 WHEN TEST = 'S02' AND TEST_SOURCE =  'STDN' THEN TEST_SCORE
                 ELSE NULL END) AS high_sat_math,
        MAX(CASE WHEN TEST = 'S11' AND TEST_SOURCE != 'STDN' THEN test_score
                 WHEN TEST = 'S11' AND TEST_SOURCE =  'STDN' THEN TEST_SCORE
                 ELSE NULL END) AS high_sat_writ,
        MAX(CASE WHEN TEST = 'A02' AND TEST_SOURCE != 'STDN' THEN test_score
                 WHEN TEST = 'A02' AND TEST_SOURCE =  'STDN' THEN TEST_SCORE
                 ELSE NULL END) AS high_act_math,
        MAX(CASE WHEN TEST = 'A01' AND TEST_SOURCE != 'STDN' THEN test_score
                 WHEN TEST = 'A01' AND TEST_SOURCE =  'STDN' THEN TEST_SCORE
                 ELSE NULL END) AS high_act_engl,
        MAX(CASE WHEN TEST = 'ALEK' THEN test_score ELSE NULL END) AS ALEKS,
        MAX(CASE WHEN TEST = 'SBEL' AND test_score < 2493 THEN 'Level 1'
                 WHEN TEST = 'SBEL' AND test_score >= 2493 AND test_score <= 2582 THEN 'Level 2'
                 WHEN TEST = 'SBEL' AND test_score >= 2583 AND test_score <= 2681 THEN 'Level 3'
                 WHEN TEST = 'SBEL' AND test_score >= 2682  THEN 'Level 4' ELSE NULL END) AS SB_ENGL,
        MAX(CASE WHEN TEST = 'SBMA' AND test_score < 2543 THEN 'Level 1'
                 WHEN TEST = 'SBMA' AND test_score >= 2543 AND test_score <= 2627 THEN 'Level 2'
                 WHEN TEST = 'SBMA' AND test_score >= 2628 AND test_score <= 2717 THEN 'Level 3'
                 WHEN TEST = 'SBMA' AND test_score >= 2718  THEN 'Level 4' ELSE NULL END) AS SB_MATH,
    MAX(CASE WHEN TEST = 'S01' THEN TEST_SCORE ELSE NULL END) AS MX_S01,
    MAX(CASE WHEN TEST = 'S11' THEN TEST_SCORE ELSE NULL END) AS MX_S11,
    MAX(CASE WHEN TEST = 'A01' THEN TEST_SCORE ELSE NULL END) AS MX_A01,
        MAX(CASE WHEN TEST = 'HGPA' THEN test_score ELSE NULL END) AS HS_SELF_GPA,
        MAX(CASE WHEN TEST = 'CGPA' THEN test_score ELSE NULL END) AS COLL_SELF_GPA,
        max(case when test like 'MPG%' then test_score else null end) as old_mpt_gen, --old mpt general
        MAX(CASE WHEN TEST LIKE 'MPI%' THEN test_score ELSE NULL END) AS old_mpt_int, --old mpt intermediate
        max(case when test like 'MPA%' then test_score else null end) as old_mpt_adv, --old mpt advanced
        max(case when test in ('MG09','MG10') then test_score else null end) as mpt_gen, --new general
        max(case when test in ('MI10','MI11') then test_score else null end) as mpt_int, --new intermediate
        max(case when test in ('MA09','MA10') then test_score else null end) as mpt_adv  --new advanced
      FROM TEST
      group by test.person_uid
    ) t
    on t.person_uid = ada.person_uid

WHERE (ada.academic_period >= $P{Beginning_Term} AND ada.academic_period <= $P{Ending_Term})
--AND ada.student_level IN ('UG','US','PB','PS')
AND ADA.LATEST_DECISION IN ('CO','OC','AD')
AND NVL(aST.STUDENT_POPULATION,ADA.STUDENT_POPULATION) NOT IN ('1','2','3','6','7')
and((ada.latest_decision = $P{Confirmed} or ada.latest_decision = 'OC') or $P{Confirmed} = 'ALL')
)

where ($P{RS_YN} = 'Y' AND STU_POP_LIM is not null) OR ($P{RS_YN} = 'N' AND STU_POP_LIM = 'N')

order by last_name, first_name,ewu_id
