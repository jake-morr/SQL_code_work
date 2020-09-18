/*==================================================================================================
Program:      VET009_Veteran_Email_and_Address taken from Vet004_Veteran_Attribute_Address
Description:  List id, name, email, and mailing address of vets that are enrolled and registered
              based on term.

Modification History
Date         Programmer      Description
11-01-2016   John Carter     Customized for ticket 137807
===================================================================================================
*/
SELECT  ENR.ACADEMIC_PERIOD
        ,  ENR.ID
        , PD.FIRST_NAME
        , PD.LAST_NAME
        , PD.EMAIL_PREFERRED_ADDRESS
        , PD.TAX_ID
        , ABR.STREET_LINE1
        , ABR.STREET_LINE2
        , ABR.CITY
        , ABR.STATE_PROVINCE
        , ABR.POSTAL_CODE
        , ODSMGR.ZGKI_COMMON.F_GET_TELEPHONE(ENR.PERSON_UID,'ARPHONE','US2',NULL,NULL) AS PHONE
        , STU.STUDENT_STATUS_DESC AS STATUS
        , STU.VETERAN_TYPE
FROM ADDRESS_BY_RULE ABR, ENROLLMENT ENR, PERSON_DETAIL PD, STUDENT STU, STUDENT_ATTRIBUTE STT

WHERE ((ENR.PERSON_UID = ABR.ENTITY_UID(+) ) AND ( ENR.PERSON_UID = PD.PERSON_UID )
AND ( STU.PERSON_UID = ENR.PERSON_UID(+) AND STU.ACADEMIC_PERIOD = ENR.ACADEMIC_PERIOD(+) )
AND ( STU.PERSON_UID = STT.PERSON_UID(+) AND STU.ACADEMIC_PERIOD = STT.ACADEMIC_PERIOD(+) ) )
and STU.Veteran_type in ('A','C','E','G','I','O','P','R','T','V')
AND ENR.ACADEMIC_PERIOD = $P{TERM}
AND ABR.ADDRESS_RULE = 'STDNADDR' AND ENR.ENROLLED_IND = 'Y' AND ENR.REGISTERED_IND = 'Y'

ORDER BY PD.LAST_NAME ASC, PD.FIRST_NAME ASC
