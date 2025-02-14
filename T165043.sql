--
select
	enrolled.*
	,total_credits/10 fte
from
(
  select 
    ast.id
    ,ast.name
    ,ast.program
    ,ast.program_desc as program_desc
    ,ast.college
    ,ast.campus
    ,ast.major
    ,ast.degree
    ,ast.first_concentration as first_conc
    , ast.academic_period
    ,case when $P{AcademicPeriod}='ALL' then $P{AcademicYear} else $P{AcademicPeriod} end as "academic_period"
    ,ast.academic_year
    ,sum(sc.course_credits) as total_credits
    ,ast.student_level
    ,sum(count(ast.id)) over(partition by 'dual' ) as total_count
    ,user
    , AO.graduated_ind
    ,ast.new_student_ind
    , AO.academic_period_graduation
    , case when ast.new_student_ind = 'Y' and AO.graduated_ind = 'Y' then round(((ao.outcome_graduation_date - ast.start_date_admitted)/365),2) else null end time_to_graduation
    --, case when ast.new_student_ind = 'Y' and AO.graduated_ind = 'Y' then (ao.outcome_graduation_date - sc.start_date) else null end time
  
  from 
    academic_study ast
    join enrollment enr
    on enr.person_uid = ast.person_uid
    and enr.academic_period = ast.academic_period
    join student_course sc
    on  ast.person_uid = sc.person_uid 
    and ast.academic_period = sc.academic_period
    left join
        (select person_uid
                , graduated_ind
                , academic_period_graduation
                , program
                , outcome_graduation_Date
            from academic_outcome) AO
    on AO.person_uid = ast.person_uid
    and AO.program = ast.program
  
  where   
    ast.primary_program_ind = 'Y'
    and (ast.program = $P{GradPrograms} or $P{GradPrograms}='ALL')
    and $X{IN,ast.campus,Campus}
    and enr.student_classification = 'GM'
    and trunc(ast.enrollment_add_date) <= trunc($P{Date})
    and (ast.new_student_ind=$P{NewStudentsOnly} or $P{NewStudentsOnly}='ALL')
    and ast.student_level in ('GR','GS')
    and enr.total_credits > 0
    and sc.course_credits > 0
    
    
    and 
    (
    	(ast.academic_year=$P{AcademicYear} and $P{AcademicPeriod}='ALL') 
    	or (ast.academic_period=$P{AcademicPeriod} and $P{AcademicYear}='ALL')
    )
  and (sc.sub_academic_period = $P{PartOfTerm} or $P{PartOfTerm}  = 'ALL' )
  
  
  group by
    ast.id
    ,ast.name
    ,ast.program
    ,ast.program_desc
    ,ast.college
    ,ast.campus
    ,ast.major
    ,ast.degree
    ,ast.first_concentration
    ,case when $P{AcademicPeriod}='ALL' then '1' else $P{AcademicPeriod} end
    ,ast.academic_year
    ,ast.student_level
    ,user
    ,ast.academic_period
    , AO.graduated_ind
    , AO.academic_period_graduation
    , ast.new_student_ind
    , case when ast.new_student_ind = 'Y' and AO.graduated_ind = 'Y' then round(((ao.outcome_graduation_date - ast.start_date_admitted)/365),2) else null end
    --, case when ast.new_student_ind = 'Y' and AO.graduated_ind = 'Y' then (ao.outcome_graduation_date - sc.start_date) else null end


  
  order by 
    ast.college asc 
    ,ast.program_desc asc
    ,ast.program asc 
    ,ast.name asc
) enrolled
--
