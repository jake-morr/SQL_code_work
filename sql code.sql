select distinct 
 AcSt.name
, AcSt.ID
, AcSt.academic_period
, case when (ITGS.ITGS110 is not null or ITGS.ITGS120 is not null or ITGS.ITGS130 is not null) then 'Y' else 'N' end as "FYE"
, case when AcSt2.registered_ind = 'Y' then 'Y'
    else 'N' end as registered_201940
, enr.total_credits as CREDITS_201940
, ZSKO_TRANSCRIPTS.F_GET_EWU_CUM_GPA_TERM(AcSt.person_uid,'201930') CUM_GPA_201940
, ZSKO_TRANSCRIPTS.F_GET_OVRL_CUM_CR_TERM(AcSt.person_uid,'201930') CUM_CREDITS_201940
, ITGS.ITGS110
, ITGS.ITGS120
, ITGS.ITGS130
, case when AcSt3.registered_ind = 'Y' then 'Y'
    else 'N' end as registered_202040
, enr2.total_credits as CREDITS_202040
, ZSKO_TRANSCRIPTS.F_GET_EWU_CUM_GPA_TERM(AcSt.person_uid,'202040') CUM_GPA_202040
, ZSKO_TRANSCRIPTS.F_GET_OVRL_CUM_CR_TERM(AcSt.person_uid,'202040') CUM_CREDITS_202040

from census_academic_study AcSt

left join 
   ( select person_uid
    , registered_ind
    , academic_period
    from census_academic_study 
where academic_period = '201940' ) AcSt2
on AcSt2.person_uid = AcSt.person_uid


left join 
   ( select person_uid
    , registered_ind
    , academic_period
    from academic_study 
where academic_period = '202040' ) AcSt3
on AcSt3.person_uid = AcSt.person_uid


left join 
    ( select person_uid
    , total_credits
    , academic_period
    from census_enrollment 
    where registered_ind = 'Y'
    and academic_period ='201940') enr
on enr.person_uid = AcSt.person_uid

left join 
    ( select person_uid
    , total_credits
    , academic_period
    from enrollment 
    where registered_ind = 'Y'
    and academic_period ='202040') enr2
on enr2.person_uid = AcSt.person_uid


left join
    (select person_uid
    , academic_period
   -- , course_identification
    , case when course_identification = 'ITGS110' and academic_period ='201840' then 'Y' else null end as "ITGS110"
    , case when course_identification = 'ITGS120' and academic_period ='201840' then 'Y' else null end as "ITGS120"
    , case when course_identification = 'ITGS130' and academic_period ='201840' then 'Y' else null end as "ITGS130"
    from student_course
    where course_identification in ('ITGS110','ITGS120','ITGS130')
    and final_grade is not null
    and academic_period = '201840'
   -- where academic_period = '201940'
   ) ITGS
on ITGS.person_uid = AcSt.person_uid


where AcSt.admissions_population in ('AI','AL','CA','CR','FB','FC','FI','FO','FR','GD','IE','IN')
and AcSt.student_population in ('B','F','I','P') 
and AcSt.academic_period  = '201840'
and AcSt.registered_ind = 'Y'
--and (ITGS.ITGS110 is not null or ITGS.ITGS120 is not null or ITGS.ITGS130 is not null)
order by AcSt.academic_period, AcSt.id
