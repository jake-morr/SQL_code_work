SELECT DISTINCT ENR.NAME, ENR.ID, pd.email_preferred_address ,ast.program, ast.campus
FROM ENROLLMENT ENR

JOIN PERSON_DETAIL PD
ON PD.PERSON_UID = ENR.PERSON_UID

JOIN ACADEMIC_STUDY AST
ON AST.PERSON_UID = ENR.PERSON_UID
AND AST.ACADEMIC_PERIOD = ENR.ACADEMIC_PERIOD
AND AST.PRIMARY_PROGRAM_IND = 'Y'
AND AST.STUDENT_LEVEL in ('GS','GR')
and ast.campus = 'ONA'

JOIN ACADEMIC_OUTCOME AO
ON AO.PERSON_UID = ENR.PERSON_UID
--AND AO.AWARD_CATEGORY = '42'
and ao.status = 'AW'

WHERE ENR.ACADEMIC_PERIOD IN ('202025', '202030', '202035', '202040')
AND ENR.ENROLLED_IND = 'Y'
and enr.registered_ind = 'Y'
order by enr.id