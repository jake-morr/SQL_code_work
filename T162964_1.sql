select case
         when sys_context('USERENV', 'DB_NAME') = 'REPT' then
          'PROD'
         else
          sys_context('USERENV', 'DB_NAME')
       end as source,
       s.spriden_id AS ewuid,
       net.gobtpac_external_user AS "NetID",
       s.spriden_last_name AS "Last Name",
       s.spriden_first_name AS "First Name",
       ewuapp.f_get_email(s.spriden_pidm, 'A', 'STU', 'PERS') AS email,
       sg.sgbstdn_levl_code AS "Student level",
       sg.sgbstdn_styp_code AS "Student type",
       sg.sgbstdn_camp_code AS "Campus Code",
       cr.term_credits AS "Term_Credits",
       s2.spbpers_citz_code AS "Citizenship",
       cr.term_credits AS "credit_Enrolled",
       req1.rrrareq_trst_code AS "FAFSA Status",
       req2.rrrareq_trst_code AS "WASFA Status",
       ap1.rcrapp1_used_trans_no AS "Current EDE Trans",
       ap2.rcrapp2_pell_pgi AS "EFC - 9 Mo",
       r1.rorstat_aprd_code AS "Aid Period",

       rnkneed.f_calc_budget_amt(s.spriden_pidm, t.stvterm_fa_proc_yr, 'F', 'ACTUAL') AS "Total Budget",
       ay_accept_amt AS "Total Aid",
       rnkneed.f_calc_unmet_need(s.spriden_pidm, t.stvterm_fa_proc_yr, 'A') AS "Unmet Need",
       r7.period_bud AS "Bugdet for Term",
       r3.term_accept_amt AS "Total Aid for Term",

       (r7.period_bud - r3.term_accept_amt) AS "Unfunded COA for Term",
       req3.rrrareq_trst_code AS "PJCARE Status",
       r4.rhrcomm_comment AS "PJCARE Comment",

       nvl(r5.rorsapr_term_code, r6.rorsapr_term_code) AS "SAP Term",
       nvl(r5.rorsapr_sapr_code, r6.rorsapr_sapr_code) AS "SAP Code",
       r1.rorstat_disb_req_comp_date AS "Disb Req Complete Date",
       r1.rorstat_pckg_req_comp_date AS "Pkg Req Complete Date",
       r1.rorstat_ver_pay_ind AS "Verification Status Code",
       ap1.rcrapp1_verification_msg AS "Verification Message",
       ap1.rcrapp1_verification_prty AS "Verification Tracking Flag",

       loans.awd_cd01                 AS loan01_fund,
       loans.awd_amt01                AS loan01_amount,
       loans.awd_status01             AS loan01_status,
       loans.awd_cd02                 AS loan02_fund,
       loans.awd_amt02                AS loan02_amount,
       loans.awd_status02             AS loan02_status,
       loans.awd_cd03                 AS loan03_fund,
       loans.awd_amt03                AS loan03_amount,
       loans.awd_status03             AS loan03_status,
       loans.awd_cd04                 AS loan04_fund,
       loans.awd_amt04                AS loan04_amount,
       loans.awd_status04             AS loan04_status,
       loans.awd_cd05                 AS loan05_fund,
       loans.awd_amt05                AS loan05_amount,
       loans.awd_status05             AS loan05_status,
       loans.awd_cd06                 AS loan06_fund,
       loans.awd_amt06                AS loan06_amount,
       loans.awd_status06             AS loan06_status,
       loans.awd_cd07                 AS loan07_fund,
       loans.awd_amt07                AS loan07_amount,
       loans.awd_status07             AS loan07_status,
       loans.awd_cd08                 AS loan08_fund,
       loans.awd_amt08                AS loan08_amount,
       loans.awd_status08             AS loan08_status,
       loans.awd_cd09                 AS loan09_fund,
       loans.awd_amt09                AS loan09_amount,
       loans.awd_status09             AS loan09_status,
       loans.awd_cd10                 AS loan10_fund,
       loans.awd_amt10                AS loan10_amount,
       loans.awd_status10             AS loan10_status,
       ra1.rprawrd_accept_amt         AS "G801 Acc Amt",
       ra2.rprawrd_accept_amt         AS "G802 Acc Amt",
       ap2.rcrapp2_eligibility_msg   AS "SAR C code",
       ap3.rcrapp3_offl_unoffl_ind   AS "Official Source Indicator",
       ap1.rcrapp1_ins               AS "DHS MATCH",
       ap4.rcrapp4_sec_ins_match_ind AS "DHS SEC MATCH",
       ap4.rcrapp4_ssa_citizen_ind   AS "SSA Citizenship Match",

       s.spriden_pidm
/* Print fields

Budget for term in parameter set
Unmet need for term in parameter set

*/

  FROM spriden s
 INNER JOIN gobtpac net
    ON net.gobtpac_pidm = s.spriden_pidm
   AND s.spriden_change_ind IS NULL
 INNER JOIN spbpers s2
    ON s2.spbpers_pidm = s.spriden_pidm

 left JOIN (SELECT cr.sfrstcr_pidm,
                    cr.sfrstcr_term_code,
                    SUM(cr.sfrstcr_credit_hr) AS term_credits
               FROM sfrstcr cr
              WHERE cr.sfrstcr_term_code = '202040'
              GROUP BY cr.sfrstcr_pidm,
                       cr.sfrstcr_term_code) cr
    ON cr.sfrstcr_pidm = s.spriden_pidm
   AND cr.sfrstcr_term_code = '202040'

---------------------------------------------------
--Pull SGASTDN data
---------------------------------------------------

  LEFT JOIN (SELECT DISTINCT sgbstdn_pidm,
                             sgbstdn_term_code_eff,
                             sgbstdn_levl_code,
                             sgbstdn_majr_code_1,
                             sgbstdn_majr_code_minr_1,
                             CASE
                               WHEN sgbstdn_rate_code = 'RSS' THEN
                                'Y'
                               WHEN sgbstdn_styp_code = 'M' THEN
                                'Y'
                               ELSE
                                'N'
                             END AS running_start,
                             MAX(sgbstdn_term_code_eff) over(PARTITION BY sgbstdn_pidm) AS max_sgbstdn_term,
                             sgbstdn_camp_code,
                             sgbstdn_stst_code,
                             sgbstdn_styp_code,
                             sg.sgbstdn_resd_code
               FROM sgbstdn sg
              INNER JOIN stvstst st
                 ON sg.sgbstdn_stst_code = st.stvstst_code
                --AND st.stvstst_reg_ind = 'Y'

              WHERE sg.sgbstdn_term_code_eff <= '202040') sg
    ON sgbstdn_pidm = s.spriden_pidm
   AND sgbstdn_term_code_eff = max_sgbstdn_term

/* from sgrsatt a*/
  LEFT JOIN sfbetrm
    ON sfbetrm_pidm = s.spriden_pidm
   AND sfbetrm_ests_code IN (SELECT q.stvests_code FROM stvests q WHERE q.stvests_wd_ind = 'N') /*= 'EL'*/
   AND sfbetrm_term_code = '202040' --this is the curr term

 INNER JOIN stvterm t
    ON t.stvterm_code = '202040'

  LEFT JOIN rrrareq req1
    ON req1.rrrareq_aidy_code = t.stvterm_fa_proc_yr
   AND req1.rrrareq_pidm = s.spriden_pidm
   AND req1.rrrareq_treq_code = 'FAFSA'

  LEFT JOIN rrrareq req2
    ON req2.rrrareq_aidy_code = t.stvterm_fa_proc_yr
   AND req2.rrrareq_pidm = s.spriden_pidm
   AND req2.rrrareq_treq_code = 'WASFA'

  LEFT JOIN rrrareq req3
    ON req3.rrrareq_aidy_code = t.stvterm_fa_proc_yr
   AND req3.rrrareq_pidm = s.spriden_pidm
   AND req3.rrrareq_treq_code = 'PJCARE'

  LEFT JOIN rcrapp1 ap1
    ON ap1.rcrapp1_aidy_code = t.stvterm_fa_proc_yr
   AND ap1.rcrapp1_pidm = s.spriden_pidm
   AND ap1.rcrapp1_curr_rec_ind = 'Y'

  LEFT JOIN rcrapp2 ap2
    ON ap2.rcrapp2_aidy_code = ap1.rcrapp1_aidy_code
   AND ap2.rcrapp2_pidm = ap1.rcrapp1_pidm
   AND ap2.rcrapp2_infc_code = ap1.rcrapp1_infc_code
   AND ap2.rcrapp2_seq_no = ap1.rcrapp1_seq_no

  LEFT JOIN rcrapp3 ap3
    ON ap3.rcrapp3_aidy_code = ap1.rcrapp1_aidy_code
   AND ap3.rcrapp3_pidm = ap1.rcrapp1_pidm
   AND ap3.rcrapp3_infc_code = ap1.rcrapp1_infc_code
   AND ap3.rcrapp3_seq_no = ap1.rcrapp1_seq_no

  LEFT JOIN rcrapp4 ap4
    ON ap4.rcrapp4_aidy_code = ap1.rcrapp1_aidy_code
   AND ap4.rcrapp4_pidm = ap1.rcrapp1_pidm
   AND ap4.rcrapp4_infc_code = ap1.rcrapp1_infc_code
   AND ap4.rcrapp4_seq_no = ap1.rcrapp1_seq_no

  LEFT JOIN rorstat r1
    ON r1.rorstat_aidy_code = t.stvterm_fa_proc_yr
   AND r1.rorstat_pidm = s.spriden_pidm

  LEFT JOIN (SELECT r2.rprawrd_aidy_code,
                    r2.rprawrd_pidm,
                    SUM(r2.rprawrd_accept_amt) AS ay_accept_amt
               FROM rprawrd r2
              WHERE r2.rprawrd_aidy_code =
                    (SELECT t.stvterm_fa_proc_yr FROM stvterm t WHERE t.stvterm_code = '202040')
              GROUP BY r2.rprawrd_aidy_code,
                       r2.rprawrd_pidm) r2
    ON r2.rprawrd_aidy_code = t.stvterm_fa_proc_yr
   AND r2.rprawrd_pidm = s.spriden_pidm

  LEFT JOIN (SELECT r3.rpratrm_aidy_code,
                    r3.rpratrm_pidm,
                    r3.rpratrm_period,
                    SUM(r3.rpratrm_accept_amt) AS term_accept_amt
               FROM rpratrm r3
              WHERE r3.rpratrm_period = '202040'
              GROUP BY r3.rpratrm_aidy_code,
                       r3.rpratrm_pidm,
                       r3.rpratrm_period) r3
    ON r3.rpratrm_aidy_code = t.stvterm_fa_proc_yr
   AND r3.rpratrm_pidm = s.spriden_pidm

  LEFT JOIN rhrcomm r4
    ON r4.rhrcomm_pidm = s.spriden_pidm
   AND r4.rhrcomm_aidy_code = t.stvterm_fa_proc_yr
   AND upper(r4.rhrcomm_category_code) = 'PJCARE'

  LEFT JOIN rorsapr r5
    ON r5.rorsapr_pidm = s.spriden_pidm
   AND r5.rorsapr_term_code = '202040'

  LEFT JOIN rorsapr r6
    ON r6.rorsapr_pidm = s.spriden_pidm
   AND r6.rorsapr_term_code =
       (SELECT MAX(r6m.rorsapr_term_code) FROM rorsapr r6m WHERE r6m.rorsapr_pidm = s.spriden_pidm)

  LEFT JOIN (SELECT r7.rbrapbc_pidm,
                    r7.rbrapbc_period,
                    SUM(r7.rbrapbc_amt) period_bud
               FROM rbrapbc r7
              WHERE r7.rbrapbc_period = '202040'
                AND r7.rbrapbc_run_name = 'ACTUAL'
              GROUP BY r7.rbrapbc_pidm,
                       r7.rbrapbc_period)

r7
    ON r7.rbrapbc_pidm = s.spriden_pidm
  LEFT JOIN rprawrd ra1
    ON ra1.rprawrd_aidy_code = t.stvterm_fa_proc_yr
   AND ra1.rprawrd_pidm = s.spriden_pidm
   AND ra1.rprawrd_fund_code = 'G801'
  LEFT JOIN rprawrd ra2
    ON ra2.rprawrd_aidy_code = t.stvterm_fa_proc_yr
   AND ra2.rprawrd_pidm = s.spriden_pidm
   AND ra2.rprawrd_fund_code = 'G802'

  LEFT JOIN (SELECT term,
                    pidm,
                    "01_FUND_CODE"    AS awd_cd01,
                    "01_AMOUNT"       AS awd_amt01,
                    "01_AWARD_STATUS" AS awd_status01,
                    "02_FUND_CODE"    AS awd_cd02,
                    "02_AMOUNT"       AS awd_amt02,
                    "02_AWARD_STATUS" AS awd_status02,
                    "03_FUND_CODE"    AS awd_cd03,
                    "03_AMOUNT"       AS awd_amt03,
                    "03_AWARD_STATUS" AS awd_status03,
                    "04_FUND_CODE"    AS awd_cd04,
                    "04_AMOUNT"       AS awd_amt04,
                    "04_AWARD_STATUS" AS awd_status04,
                    "05_FUND_CODE"    AS awd_cd05,
                    "05_AMOUNT"       AS awd_amt05,
                    "05_AWARD_STATUS" AS awd_status05,
                    "06_FUND_CODE"    AS awd_cd06,
                    "06_AMOUNT"       AS awd_amt06,
                    "06_AWARD_STATUS" AS awd_status06,
                    "07_FUND_CODE"    AS awd_cd07,
                    "07_AMOUNT"       AS awd_amt07,
                    "07_AWARD_STATUS" AS awd_status07,
                    "08_FUND_CODE"    AS awd_cd08,
                    "08_AMOUNT"       AS awd_amt08,
                    "08_AWARD_STATUS" AS awd_status08,
                    "09_FUND_CODE"    AS awd_cd09,
                    "09_AMOUNT"       AS awd_amt09,
                    "09_AWARD_STATUS" AS awd_status09,
                    "10_FUND_CODE"    AS awd_cd10,
                    "10_AMOUNT"       AS awd_amt10,
                    "10_AWARD_STATUS" AS awd_status10

               FROM (SELECT *
                       FROM (SELECT a.rpratrm_pidm AS pidm,
                                    a.rpratrm_period AS term,
                                    row_number() over(PARTITION BY a.rpratrm_period, a.rpratrm_pidm ORDER BY a.rpratrm_period, a.rpratrm_pidm, a.rpratrm_fund_code) AS fund_no,
                                    a.rpratrm_fund_code AS fundcode,
                                    a.rpratrm_offer_amt AS amount,
                                    a.rpratrm_awst_code AS award_status
                               FROM rpratrm a
                              WHERE a.rpratrm_fund_code LIKE 'L%'
                                AND a.rpratrm_period = '202040')
                     pivot(MAX(fundcode) AS fund_code, MAX(amount) AS amount, MAX(award_status) AS award_status
                        FOR fund_no IN('1' AS "01", '2' AS "02", '3' AS "03", '4' AS "04", '5' AS "05", -- 
                                      '6' AS "06", '7' AS "07", '8' AS "08", '9' AS "09", '10' AS "10" --
                                      )))) loans
    ON loans.pidm = s.spriden_pidm

 where 1 = 1
 and (spriden_pidm in ('113000',	'649731',	'679248',	'697129',	'731507',	'745043',	'753384',	'804303',	'820689',	'832048',	'837025',	'849837',	'878385',	'886241',	'894565',	'920755',	'921595',	'932221')
)
