set search_path to healthcare;
select*from admissions;
select*from appointments;
select*from bills;
select*from  doctors;
select*from nurses;
select*from patients;
select*from payments;
select*from prescriptions;
select*from treatments;
select*from wards;


--1Retrieve the list of all male patients who were born after 1990 including their name and date of birth
select p."PatientID", p. "FirstName",p."LastName", p."DateOfBirth"
from patients p 
where  p."Gender" ='m'and p."DateOfBirth" ='1990-12-31';

-- 2 Produce a report showing the ten most recent appointments in the system, ordered from the 
newest to the oldest. 
SELECT "AppointmentID", "PatientID", "DoctorID", "AppointmentDate", "Status"
FROM appointments
ORDER BY "AppointmentDate" DESC
LIMIT 10;


-- 3 Generate a report that shows all appointments along with the full names of the patients and 
--doctors involved. 
select 
    a"AppointmentID",
    a."AppointmentDate",
    p."FirstName" AS patient_first_name,
    p."LastName" AS patient_last_name,
    d."FirstName"AS doctor_first_name,
    d."LastName" AS doctor_last_name
FROM appointments a
JOIN patients p ON a."PatientID" = p."PatientID"
JOIN doctors d ON a."DoctorID" = d."DoctorID";


--.4 Prepare a list that shows all patients together with any treatments they have received, ensuring 
 --that patients without treatments also appear in the results. 
select p."PatientID",p. "FirstName", t."TreatmentID",t."TreatmentType"
from patients p 
left join appointments a 
on p."PatientID" =a."PatientID" 
left join  treatments t 
on t."AppointmentID" =a."AppointmentID" 
order by "TreatmentType";

--5 Identify any treatments recorded in the system that do not have a matching appointment.  
with Treatmentinfo_ as (
select a."AppointmentDate",t."TreatmentID",t."TreatmentType", t."AppointmentID", a."AppointmentID" as "matched_appointment"
from treatments t
left join appointments a
on t."AppointmentID" = a."AppointmentID"
)
select *from Treatmentinfo_
where matched_appointment is null;



-- 6 .Create a summary that shows how many appointments each doctor has handled, ordered from 
the highest to the lowest count.



  
--7. Produce a list of doctors who have handled more than twenty appointments, showing their 
doctor ID, specialization, and total appointment count. 

with Doctor_appointments as (
select d."DoctorID" ,d."Specialization", count(a."AppointmentID" ) as total_appointments
from doctors d
join Appointments a
on d."DoctorID" = a."DoctorID"
group by d."DoctorID" , d."Specialization"
)
 select *from Doctor_appointments
where total_appointments > 20
order by total_appointments desc;

select * from doctors d ;
 
--8 Retrieve the details of all patients who have had appointments with doctors whose 
specialization is “Cardiology.”  
-- 9 Produce a list of patients who have at least one bill that remains unpaid.
select distinct 
p."PatientID",p."FirstName",p."LastName"
from patients p 
join bills b 
on p. "PatientID"=b. "PatientID"
where b.payments_status ="unpaid";

--10 Retrieve all bills whose total amount is higher than the average total amount for all bills in 
the system. 

select  *from bills b
where b."TotalAmount" > (
select AVG("TotalAmount")
from bills
);

--11 For each patient in the database, identify their most recent appointment and list it along with 
--the patient’s ID.
select distinct on (a."PatientID")
a."PatientID",
a."AppointmentID",
a."AppointmentDate",
a."Status"
from Appointments a
order by a."PatientID", 
a."AppointmentDate" desc;






--12. For every appointment in the system, assign a sequence number that ranks each patient’s 
appointments from most recent to oldest. 

select  "AppointmentID","PatientID","AppointmentDate",
Row_Number() over(partition by "PatientID" order by "AppointmentDate"desc) as appointment_sequence 
from appointments;





--13. Generate a report showing the number of appointments per day for October 2021, including a 
running total across the month. 

SELECT 
    DATE("AppointmentDate") as appointment_day,
    COUNT(*) as daily_appointments,
    SUM(COUNT(*)) OVER (ORDER BY DATE("AppointmentDate")) as running_total
FROM appointments
WHERE "AppointmentDate" >= '2021-10-01' AND "AppointmentDate"  < '2021-11-01'
GROUP BY DATE("AppointmentDate")
ORDER BY appointment_day;




--14. Using a temporary query structure, calculate the average, minimum, and maximum total bill 
amount, and then return these values in a single result set.

WITH BillStats AS (
    SELECT 
        AVG("TotalAmount") as avg_amount,
        MIN("TotalAmount") as min_amount,
        MAX("TotalAmount") as max_amount
    FROM bills
)
SELECT avg_amount, min_amount, max_amount FROM BillStats;







--15. Build a query that identifies all patients who currently have an
--outstanding balance, based on
--information from admissions and billing records

select distinct p."PatientID", p."FirstName",p."LastName", a."AdmissionID",b."OutstandingAmount"
from patients p
join admissions a
on p."PatientID" = a."PatientID"
join bills b
on a."AdmissionID" = b."AdmissionID"
where b."OutstandingAmount" > '0'
ORDER BY p."PatientID" desc;


--16. Create a query that generates all dates from January 1 to January 15, 2021, and show how 
--many appointments occurred on each of those dates. 


--17. Add a new patient record to the Patients table, providing appropriate information for all 
--required fields. 
 
 insert into patients("PatientID","FirstName", "LastName", "Gender", "DateOfBirth", "Email")
values(
'P1001','Luke', 'Mbandu','M','2000-01-01','lukembandu@gmail.com'
); 

delete from patients  
where "Email"='lukembandu@gmail.com';

select *from patients;
--18. Modify the appointments table so that any appointment with a NULL status is updated to 
--show “Scheduled.”  
update appointments
set "Status"= 'Scheduled'
where "Status" is null;

--19. Remove all prescription records that belong to appointments marked as “Cancelled.” 
 
delete from prescriptions
where "AppointmentID" in (
select "AppointmentID"
from appointments a
where a."Status" = 'Cancelled');

select *from appointments;

--20. Create a stored procedure that adds a new record to the Doctors table.  

create or replace procedure healthcare.add_doctor(
p_doctor_id varchar(50),
P_first_name varchar(50),
p_last_name varchar(50),
p_specialization varchar(50),
p_email varchar(50),
p_phone_number varchar(50)
)
language plpgsql
as $$
begin
insert into healthcare.doctors(
"DoctorID",
"FirstName",
"LastName",
"Specialization",
"Email",
"PhoneNumber"
)
values(
p_doctor_id,
P_first_name,
p_last_name,
p_specialization,
p_email,
p_phone_number
);
end;
$$;
 
call healthcare.add_doctor('D0015','James','Yusuf','Pediatrics','jamesyusuf@gmail.com','555-02312');

select*from doctors;

--21. Create a stored procedure that records a new appointment and
-- automatically performs validation before inserting.


create or replace procedure healthcare.add_appointment(
p_appointment_id varchar(50),
p_patient_id varchar(50),
p_doctor_id varchar(50),
p_appointment_date date,
p_status varchar(50),
p_nurse_id varchar(50)
)
language plpgsql
as $$
begin
insert into healthcare.appointments(
"AppointmentID",
"PatientID",
"DoctorID",
"AppointmentDate",
"Status",
"NurseID"
)
values(
p_appointment_id,
p_patient_id,
p_doctor_id,
p_appointment_date,
p_status,
p_nurse_id
);
end;
$$;
 
call healthcare.add_appointment('A0021','P0123','D0345','2021-11-28','Scheduled','N0200');
 
select*from appointments a
where a."AppointmentID" = 'A0021';
 
select*from doctors d
where d."DoctorID"= 'D0345';


--Appointments Enriched 
--Includes: AppointmentID, PatientID, DoctorID, AppointmentDate, Status (normalized), 
--patient first/last, doctor first/last, specialization, plus a pure date column extracted from 
--AppointmentDate. 
CREATE OR REPLACE VIEW Appointments_Enriched AS
SELECT
a."AppointmentID",
a."PatientID",
a."DoctorID",
a."AppointmentDate",
DATE(a."AppointmentDate") AS AppointmentDateOnly,
INITCAP(a."Status") AS Status, -- Normalize e.g. "scheduled" -> "Scheduled"
 
p."FirstName" AS PatientFirstName,
p."LastName" AS PatientLastName,
d."FirstName" AS DoctorFirstName,
d."LastName" AS DoctorLastName,
d."Specialization"
FROM appointments a
JOIN patients p ON a."PatientID" = p."PatientID"
JOIN doctors d ON a."DoctorID" = d."DoctorID";

select* from Appointments_Enriched;

CREATE VIEW Doctor_Monthly_Metrics AS
SELECT
a."DoctorID",
TO_CHAR(a."AppointmentDate"::date, 'YYYY-MM') AS AppointmentMonth,
COUNT(a."AppointmentID") AS TotalAppointments,
SUM(CASE WHEN a."Status" = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledAppointments,
(
SUM(CASE WHEN a."Status" = 'Cancelled' THEN 1 ELSE 0 END)::NUMERIC /
COUNT(a."AppointmentID")::NUMERIC
) *100  AS CancellationRate
FROM
appointments a
GROUP BY
a."DoctorID",
TO_CHAR(a."AppointmentDate"::date, 'YYYY-MM');

select *from Doctor_Monthly_Metrics;

CREATE OR REPLACE VIEW Patient_Balances AS
SELECT
a."PatientID",
SUM(b."TotalAmount") AS TotalBilled,
SUM(b."PaidAmount") AS TotalPaid,
SUM(b."OutstandingAmount") AS TotalOutstanding
FROM admissions a
JOIN bills b ON a."AdmissionID" = b."AdmissionID"
GROUP BY a."PatientID";

select* from Patient_Balances;


