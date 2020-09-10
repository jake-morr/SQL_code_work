select AcSt.person_uid
, AcSt.ID
, AcSt.student_population
, AcSt.academic_period
, AcSt.registered_ind
, MAX (AO.graduated_ind) over (partition by AcSt.person_uid,AcSt.academic_period) graduated

from census_academic_study AcSt

left join
    (select person_uid
    , academic_period
    , graduated_ind
    from academic_outcome) AO
on AO.person_uid = AcSt.person_uid
and AO.academic_period = AcSt.academic_period

order by AcSt.person_uid
