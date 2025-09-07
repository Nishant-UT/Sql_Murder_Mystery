
---

## `sql/solution.sql`

```sql
/* 
SQL Murder Mystery — Solution Script
Author: <your name>
Run: execute step-by-step to see intermediate results
*/

/* -----------------------------------------------------
1) Read the crime scene report for the given time/place
----------------------------------------------------- */
-- Expect: notes about two witnesses (Northwestern Dr last house & “Annabel” on Franklin Ave)
SELECT *
FROM crime_scene_report
WHERE type = 'murder'
  AND city = 'SQL City'
  AND date = '20180115';

/* -----------------------------------------------------
2) Identify witnesses
   - Last house on Northwestern Dr (highest address_number)
   - Annabel on Franklin Ave
----------------------------------------------------- */
-- Last house on Northwestern Dr
SELECT *
FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1;

-- Annabel on Franklin Ave
SELECT *
FROM person
WHERE address_street_name = 'Franklin Ave'
  AND name LIKE '%Annabel%';

/* For reference (IDs found commonly): 
   - Morty Schapiro (id = 14887)
   - Annabel Miller (id = 16371)
*/

/* -----------------------------------------------------
3) Read the interviews of the two witnesses
----------------------------------------------------- */
-- Annabel
SELECT p.name, i.person_id, i.transcript
FROM person p
JOIN interview i ON p.id = i.person_id
WHERE i.person_id = 16371;

-- Morty
SELECT p.name, i.person_id, i.transcript
FROM person p
JOIN interview i ON p.id = i.person_id
WHERE i.person_id = 14887;

/* Key details extracted:
   - Gym visit on 2018-01-09
   - Membership starts with '48Z' (gold members carry specific bags)
   - Car plate contains 'H42W'
*/

/* -----------------------------------------------------
4) Narrow to gym check-ins on 2018-01-09 for '48Z%' members
----------------------------------------------------- */
SELECT g2.person_id, g2.id AS membership_id, g2.name AS member_name
FROM get_fit_now_check_in g1
JOIN get_fit_now_member g2 ON g1.membership_id = g2.id
WHERE g1.check_in_date = '20180109'
  AND g2.id LIKE '48Z%';

/* Commonly returns (names may vary by dataset instance):
   - Joe Germuska  (48Z7A, person_id 28819)
   - Jeremy Bowers (48Z55, person_id 67318)
*/

/* -----------------------------------------------------
5) Use plate clue 'H42W' to identify the killer
----------------------------------------------------- */
SELECT p.id, p.name, dl.plate_number
FROM get_fit_now_member gf
JOIN person p            ON gf.person_id = p.id
JOIN drivers_license dl  ON dl.id = p.license_id
WHERE gf.id LIKE '48Z%'
  AND dl.plate_number LIKE '%H42W%';

/* => Killer: Jeremy Bowers (id = 67318) */

/* -----------------------------------------------------
6) Interrogate the killer to learn about the mastermind
----------------------------------------------------- */
SELECT p.name, i.person_id, i.transcript
FROM person p
JOIN interview i ON p.id = i.person_id
WHERE p.id = 67318;

/* Extracted mastermind description:
   - Female, red hair, height 65"–67"
   - Drives Tesla Model S
   - Attended SQL Symphony Concert 3 times in Dec 2017
*/

/* -----------------------------------------------------
7) Find mastermind matching physical traits + car + events
----------------------------------------------------- */
-- Candidate set with physical traits + car
WITH candidates AS (
  SELECT p.id, p.name
  FROM person p
  JOIN drivers_license dl ON dl.id = p.license_id
  WHERE dl.gender = 'female'
    AND dl.hair_color = 'red'
    AND dl.height BETWEEN 65 AND 67
    AND dl.car_make  = 'Tesla'
    AND dl.car_model = 'Model S'
),
dec17_concerts AS (
  SELECT f.person_id
  FROM facebook_event_checkin f
  WHERE f.event_name = 'SQL Symphony Concert'
    AND f.date LIKE '201712%'    -- December 2017
  GROUP BY f.person_id
  HAVING COUNT(*) = 3             -- attended 3 times
)
SELECT c.id, c.name
FROM candidates c
JOIN dec17_concerts d ON d.person_id = c.id;

/* => Mastermind: Miranda Priestly */

/* -----------------------------------------------------
8) Final answers
----------------------------------------------------- */
-- Murderer
SELECT 'Jeremy Bowers' AS murderer;

-- Mastermind
SELECT 'Miranda Priestly' AS mastermind;
