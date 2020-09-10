Select ID "ID"
, hold_desc 
, hold_from_date
, hold_to_date
, active_hold_ind "active indicator"
, registration_hold_ind "registration_hold"
from HOLD
where hold_from_date between '01-JAN-16' and '04-JUN-20'
order by PERSON_UID