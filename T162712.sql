
/*SRR_Potential Graduate_Over124Credits
Email of student who have specified number (>=125 ) credits 
A have not applied (AG,AO,AW) to graduate
Do not include student types ('Q', '1','2','3','6','7')
DOES NOT LOOK AT CONFIDENTIALITY INDICATOR OR STUDENT DECEASED IND
Author: Linda Darr 12/13/2018
120 or higher, 145 or higher, 160 or higher, 180 or higher 
*/
SELECT DISTINCT acs.id,
  acs.academic_period AS TERM, acs.name as namesort,
  CASE WHEN PREFERRED_FIRST_NAME IS NOT NULL THEN INITCAP(PREFERRED_FIRST_NAME) ELSE pd.FIRST_NAME END  ||' '|| pd.last_name as name,
  acs.student_level      AS STU_LEVEL,
  acs.student_population AS STU_TYPE,
  -- acs.grad_academic_period_intended,
  acs.graduated_ind,
  --  acs.enrolled_ind,
  --  acs.registered_ind,
  --  acs.student_status,
  gp.credits_earned,
  ao.status AS APPLIED_GRAD_STATUS,
  ao.graduation_status,
  --  acs.primary_program_ind,
  pd.deceased_date,
  pd.confidentiality_ind,
  pd.email_preferred_address AS EMAIL,
  pds.user_name as net_id
FROM academic_study acs
JOIN person_detail pd
ON pd.person_uid = acs.person_uid
JOIN person_detail_supp_ewu pds
ON pds.person_uid = acs.person_uid
LEFT JOIN academic_outcome ao
ON acs.person_uid        = ao.person_uid
AND acs.academic_period >= ao.academic_period
AND acs.student_level    = ao.student_level
LEFT JOIN gpa gp
ON gp.person_uid                = acs.person_uid
AND gp.academic_study_value     = acs.student_level
AND gp.gpa_type                 = 'O'
AND gp.gpa_grouping             = 'C'
WHERE (acs.academic_period   = substr($P{Select_Q_S_TERMS},1,6) or acs.academic_period = substr($P{Select_Q_S_TERMS},9,6))
AND acs.student_level  in ('UG','US','PB','PS')
and((acs.student_level = $P{Select_Student_Level_UG} or  acs.student_level = substr($P{Select_Student_Level_UG},1,1)||'S') or $P{Select_Student_Level_UG} = 'ALL')
AND acs.enrolled_ind            = 'Y'
AND acs.registered_ind          = 'Y'
AND acs.graduated_ind           = 'N'
AND acs.primary_program_ind     = 'Y'
AND gp.credits_earned           >= $P{Number_of_Credits}
AND acs.student_population NOT IN ('Q', '1','2','3','6','7')
AND (ao.status   IS NULL
OR ao.status NOT IN ('AG','AW','AO'))
ORDER BY acs.student_level, namesort
