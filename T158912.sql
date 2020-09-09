select distinct
 pds.user_name "user name"
--, STC.Person_uid
, STC.academic_period "academic period"
, StC.course_identification "course"
, stc.course_section_number "section number"
, SO.PRIMARY_INSTRUCTOR_LAST_NAME "instructor"
, stc.final_grade "final grade"
, odsmgr.ZGKI_COMMON.f_get_race_federal(stc.person_uid,StC.academic_period) as "ethnicity"
, ZSKO_TRANSCRIPTS.F_GET_OVRL_CUM_GPA_TERM(stc.person_uid,&academic_period) as "overall gpa"
, stem.stem_gpa "stem gpa"
, case when pell.person_uid is not null then '1' else '0' end as "pell recipient"
, pd.gender "gender"

from student_course STC

inner join schedule_offering SO
on stc.ACADEMIC_PERIOD = so.academic_period
and stc.course_reference_number = so.course_reference_number

JOIN
    (SELECT
        PERSON_UID
        , USER_NAME
        FROM PERSON_DETAIL_SUPP_EWU) pds
    on pds.person_uid = StC.person_uid

join
    (select
        person_uid
        , gender
        from person_detail) pd
        on pd.person_uid = StC.person_uid

left join				
    (select  
        person_uid
        , aid_year
    from award_by_aid_year
    where fund = 'G100'
        and total_paid_amount > 0) pell
    on pell.person_uid = StC.person_uid

LEFT JOIN ( 
			select STC.person_uid, round(sum(quality_points) / sum(credits_for_gpa),2) as stem_gpa
              from person_detail_supp_ewu pds
			left join student_course stc
			    on pds.person_uid = stc.person_uid
             where stc.academic_period < '&academic_period'
               and subject in ('BIOL','ENVS','DESN','MTED','CSCD','GEOL','MATH','MNTC','APTC','SCED','TECH',
			                   'CHEM','PHYS','CMTC','DNTC','EENG','MENG','METC') --HONS
               and stc.credits_for_gpa > 0
          group by stc.person_uid) stem
		on stem.person_uid = pds.person_uid


where stc.course_identification = '&course_identification' --in ('BIOL421', 'BIOL436', 'CHEM162', 'GEOL115', 'MATH347')
and so.primary_instructor_last_name in ('Castillo', 'Matos', 'Lamm', 'Keattch', 'Lynch')
and stc.academic_period = '&academic_period' --in ('201710', '201810', '201910', '201640', '201840','201820','201720', '201740','201920')
and so.Instruction_method is null
and stc.final_grade is not null
--group by stc.final_grade, stc.course_section_number, STC.academic_period, SO.PRIMARY_INSTRUCTOR_LAST_NAME, stc.course_identification
order by stc.academic_period, stc.course_identification, STC.COURSE_SECTION_NUMBER, stc.final_grade
