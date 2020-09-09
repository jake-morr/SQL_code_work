SELECT Count(person_uid)
    , academic_study.college_desc
    ,academic_study.program "PROGRAM"
    ,(case
         WHEN first_concentration_desc is null THEN academic_study.major_desc||' / '||academic_study.degree
         ELSE
         academic_study.major_desc||' / '||first_concentration_desc||' / '||academic_study.degree
      end) as Major_Concentration
from census_academic_study academic_study
where academic_period = '202020'
and (major_desc LIKE '%Supply%' or major_desc LIKE '%Operation%' or major_desc LIKE '%Human Resources%' or major_desc LIKE '%Entrepreneurship%' or major_desc LIKE '%International Business%'or major_desc LIKE '%Business%') 
and (program NOT LIKE '%UND%')
and program != 'MBA-BUSADM'
and college_desc = 'Business' group by academic_study.college_desc, academic_study.program, (case WHEN first_concentration_desc is null THEN academic_study.major_desc||' / '||academic_study.degree ELSE academic_study.major_desc||' / '||first_concentration_desc||' / '||academic_study.degree end)


-- 13
