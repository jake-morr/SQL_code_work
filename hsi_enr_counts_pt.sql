select round((sum(enr.total_credits)/12),2) "STUDENTS", css.student_race_group "ETHNICITY" , enr.academic_period "PERIOD"
             from census_enrollment enr
             join census_academic_study acs
               on acs.person_uid = enr.person_uid
               and acs.academic_period = enr.academic_period
            join census_student_summary css
                on css.person_uid = enr.person_uid
                and css.academic_period = enr.academic_period
              and acs.academic_period = enr.academic_period
              and primary_program_ind = 'Y'
              and enr.total_credits < 12
			  and acs.student_classification in ('FR','SO','JR','SR')
			  and student_population not in ('E','Q')
              group by css.student_race_group, enr.academic_period
              order by ENR.academic_period
