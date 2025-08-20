/*	
-----------------------------------------------------------------------------------------------------------------------------------
 
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/

/*-- QUESTIONS RELATED TO CRIME
-- Q1. Which was the most frequent crime committed each week? 
-- Hint: Use a subquery and the windows function to find out the number of crimes reported each week and assign a rank. 
Then find the highest crime committed each week
 */
 
WITH RANKED_CRIMES AS(
SELECT COUNT(report_no) AS total_crimes_reported, 
week_number, 
crime_type,
RANK() OVER(PARTITION BY week_number ORDER BY COUNT(report_no) DESC) AS rnk
FROM report_t
GROUP BY week_number, crime_type
)
SELECT week_number, crime_type, total_crimes_reported FROM RANKED_CRIMES
WHERE rnk=1;

/* 
INSIGHT:
  - Burglary from Vehicle was the most frequent crime in Weeks 1, 2, and 4, showing it as a persistent issue.
  - Battery – Simple Assault spiked in Week 3, suggesting a temporary rise in violent incidents.
/*  
-- ---------------------------------------------------------------------------------------------------------------------------------
 
/* -- Q2. Is crime more prevalent in areas with a higher population density, fewer police personnel, and a larger precinct area? 
-- Hint: Add the population density, count the total areas, total officers and cases reported in each precinct code and check the trend*/

SELECT 
o.precinct_code,
ROUND(AVG(l.population_density),3) AS average_population_density, 
COUNT(DISTINCT l.area_name) AS total_area,
COUNT(DISTINCT o.officer_name) AS total_officers, 
COUNT(r.report_no) AS total_cases_reported
FROM report_t r 
JOIN location_t l ON r.area_code = l.area_code
JOIN officer_t o ON r.officer_code = o.officer_code
GROUP BY o.precinct_code
ORDER BY total_cases_reported DESC;
 
 /* INSIGHT:
- Precinct 3 has the highest number of reported cases (314) despite only 11 officers across 2 areas with moderate population density (≈4820).
- Precinct 4 & 6 both have very high population densities (8500, 6686) and fewer officers (10 & 6), and they also show high crime counts (233, 189).
- Precinct 7 has the lowest population density (3200), fewest officers (5), and also the lowest crime count (122).
- Trend: Areas with higher population density and fewer officers per area tend to report more crimes. Larger precinct areas (more neighborhoods under one precinct) also contribute to higher crime volumes.
/*

-- ---------------------------------------------------------------------------------------------------------------------------------
 
/* -- Q3. At what points of the day is the crime rate at its peak? Group this by the type of crime.
-- Hint: 
time day parts
[1] 00:00 to 05:00 = Midnight, 
[2] 05:01 to 12:00 = Morning, 
[3] 12:01 to 18:00 = Afternoon,
[4] 18:01 to 21:00 = Evening, 
[5] 21:00 to 24:00 = Night
 
Use a subquery, windows function to find the number of crimes reported each week and assign the rank.
Then find out at what points of the day the crime rate is at its peak.*/

WITH CRIMES_COUNT AS(
SELECT 
COUNT(report_no) AS total_crimes_reported, 
crime_type, 
week_number,
CASE 
WHEN incident_time BETWEEN '00:00' AND '05:00' THEN 'Midnight'
WHEN incident_time BETWEEN '05:01' AND '12:00' THEN 'Morning'
WHEN incident_time BETWEEN '12:01' AND '18:00' THEN 'Afternoon'
WHEN incident_time BETWEEN '18:01' AND '21:00' THEN 'Evening' 
ELSE 'Night'
END AS part_of_day
FROM report_t
GROUP BY crime_type, week_number, part_of_day
),
RANKED_CRIMES AS (
SELECT total_crimes_reported, crime_type, week_number, part_of_day,
RANK() OVER(PARTITION BY week_number, part_of_day ORDER BY total_crimes_reported DESC ) AS rnk
FROM CRIMES_COUNT
)
SELECT total_crimes_reported, crime_type, week_number, part_of_day FROM RANKED_CRIMES 
WHERE rnk = 1
ORDER BY  week_number, part_of_day DESC; 

/*
INSIGHT:
- Morning (05:01–12:00) → Highest for Battery – Simple Assault and Assault with Deadly Weapon → shows violent incidents peak during the day start.
- Afternoon (12:01–18:00) → Crimes like Shoplifting and Petty Theft are most common → likely linked to business hours and shopping activity.
- Evening & Night (18:01–24:00) → Burglary from Vehicle dominates → cars are more targeted later in the day when parked.
- Midnight (00:00–05:00) → A mix of burglary, assault, and theft → opportunistic crimes happen when visibility and monitoring are low.

Conclusion:
- Property crimes (burglary & theft) peak in the evening and night.
- Violent crimes (assault/battery) are more frequent in the morning and afternoon.
/*

-- ---------------------------------------------------------------------------------------------------------------------------------
 
/* -- Q4. At what point in the day do more crimes occur in a different locality?
-- Hint: 
time day parts
[1] 00:00 to 05:00 = Midnight, 
[2] 05:01 to 12:00 = Morning, 
[3] 12:01 to 18:00 = Afternoon,
[4] 18:01 to 21:00 = Evening, 
[5] 21:00 to 24:00 = Night
 
Use a subquery and the windows function to find the number of crimes reported in each area and assign the rank.
Then find out at what point in the day more crimes occur in a different locality. */
 
 WITH CRIMES_RANKED AS (
 SELECT DISTINCT l.area_name, 
 COUNT(r.report_no) AS total_crimes_reported,
 CASE
 WHEN r.incident_time BETWEEN '00:00' AND '05:00' THEN 'Midnight'
 WHEN r.incident_time BETWEEN '05:01' AND '12:00' THEN 'Morning'
 WHEN r.incident_time BETWEEN '12:01' AND '18:00' THEN 'Afternoon'
 WHEN r.incident_time BETWEEN '18:01' AND '21:00' THEN 'Evening'
 ELSE 'Night'
 END AS part_of_day,
 RANK() OVER(PARTITION BY l.area_name ORDER BY COUNT(r.report_no) DESC) AS rnk
 FROM report_t r
 JOIN location_t l ON r.area_code = l.area_code
 GROUP BY l.area_name, part_of_day
 )
 SELECT area_name, part_of_day, total_crimes_reported FROM CRIMES_RANKED
 WHERE rnk = 1
 ORDER BY total_crimes_reported DESC;

/*
INSIGHT:
- Afternoon (12:01–18:00) → Crimes peak across all localities.
- Rampart records the highest afternoon crimes (77 cases).
- Other hotspots include Hollenbeck (55), West Valley (50), West LA (42), and Hollywood (40).

Conclusion:
- The Afternoon is the riskiest time of day in every area.
- Rampart stands out as the most crime-prone locality.
/*

-- ---------------------------------------------------------------------------------------------------------------------------------
 
/* -- Q5. Which age group of people is more likely to fall victim to crimes at certain points in the day?
-- Hint: Age 0 to 12 kids, 13 to 23 teenage, 24 to 35 Middle age, 36 to 55 Adults, 56 to 120 old.*/

SELECT
CASE 
WHEN v.victim_age BETWEEN  0 AND 12 THEN 'Children'
WHEN v.victim_age BETWEEN 13 AND 23 THEN 'Teenage/Young Adults'
WHEN v.victim_age BETWEEN 24 AND 35 THEN 'Adults'
WHEN v.victim_age BETWEEN 36 AND 55 THEN 'Middle-Aged'
WHEN v.victim_age BETWEEN 56 AND 120 THEN 'OLD'
ELSE 'Unknown'
END AS victim_age_group,
CASE 
WHEN r.incident_time BETWEEN '00:00' AND '05:00' THEN 'Midnight'
WHEN r.incident_time BETWEEN '05:01' AND '12:00' THEN 'Morning'
WHEN r.incident_time BETWEEN '12:01' AND '18:00' THEN 'Afternoon'
WHEN r.incident_time BETWEEN '18:01' AND '21:00' THEN 'Evening' 
ELSE 'Night'
END AS part_of_day,
COUNT(r.report_no) AS total_crimes_reported
FROM victim_t v
JOIN report_t r ON v.victim_code = r.victim_code
GROUP BY victim_age_group, part_of_day 
ORDER BY victim_age_group, total_crimes_reported;

/*
INSIGHT:
- Middle-Aged (36–55) are the most frequent victims → especially in the Afternoon (229) and Morning (169).
-  Adults (24–35) also face crimes mainly in the Afternoon (75) and Morning (70).
- Children (0–12) and the Elderly (56–120) are more at risk in the Afternoon (38 and 63 cases).
- Teenagers/Young Adults (13–23) are least targeted, with very few cases overall.

Conclusion: 
Crimes are most likely to affect the Middle-Aged population during the Afternoon and Morning, making these the riskiest times of day for this age group.
/*
-- ---------------------------------------------------------------------------------------------------------------------------------
 
/* -- Q6. What is the status of reported crimes?.
-- Hint: Count the number of crimes for different case statuses. */

SELECT COUNT(report_no) AS total_crimes_reported, 
case_status_desc 
FROM report_t
GROUP BY case_status_desc
ORDER BY total_crimes_reported DESC; 

/*
INSIGHT:
- Most cases (1186) are still under Investigation Continued.
- Only 94 cases have led to an Adult Arrest.
- 38 cases fall under Adult Other status.

Conclusion:
The majority of crimes remain under investigation, with only a small fraction resulting in arrests.
/*
 
-- ---------------------------------------------------------------------------------------------------------------------------------
 
/* -- Q7. Does the existence of CCTV cameras deter crimes from happening?
-- Hint: Check if there is a correlation between the number of CCTVs in each area and the crime rate.*/

SELECT l.cctv_count,
l.area_name,
COUNT(r.report_no) AS total_crimes_reported
FROM report_t r
JOIN location_t l ON r.area_code = l.area_code
GROUP BY l.cctv_count, l.area_name
ORDER BY total_crimes_reported DESC;
      
/*
INSIGHT:
- Areas with more CCTV cameras (like Rampart – 165 CCTVs, Hollenbeck – 170, Van Nuys – 250, West Valley – 268, Hollywood – 280) still report high crime numbers.
- Meanwhile, areas with fewer CCTVs (like 77th Street – 150, Southwest – 168, Northeast – 255) show comparatively lower crime counts.

Conclusion:
The presence of CCTV cameras does not directly deter crimes — high-CCTV areas still record high crime rates, suggesting that population density, policing, and local conditions matter more than just camera count.
/*
-- ---------------------------------------------------------------------------------------------------------------------------------
 
/* -- Q8. How much footage has been recovered from the CCTV at the crime scene?
-- Hint: Use the case when function, add separately when cctv_flag is true and false and check whether in particular area how many cctv is there,
How much CCTV footage is available? How much CCTV footage is not available? */

SELECT l.area_name, 
CASE WHEN r.cctv_flag = 'TRUE' THEN 'Footage Recovered' ELSE 'Footage Not Recovered' END AS footage_status,
COUNT(r.report_no) AS total_reported_case
FROM report_t r
JOIN location_t l ON r.area_code = l.area_code
GROUP BY l.area_name, footage_status
ORDER BY l.area_name; 

/*
INSIGHT:
- In every area, some cases have CCTV footage available and some don’t.
- However, even areas with high CCTV coverage (Hollywood, West Valley, Van Nuys, Rampart) still report many crimes where footage is not recovered.
- This shows that while CCTV presence helps, it doesn’t guarantee usable footage for every crime case.

Conclusion:
CCTV footage is not always available even in high-camera areas, meaning reliance on CCTV alone is not enough for crime investigation.
/*
-- ---------------------------------------------------------------------------------------------------------------------------------
 
/* -- Q9. Is crime more likely to be committed by relation of victims than strangers?
-- Hint: Find the distinct crime type along with the count of crime when the offender is related to the victim.*/

SELECT COUNT(crime_type) AS total_crime,
offender_relation
FROM report_t
GROUP BY offender_relation;
 
/*
INSIGHT:
- Most crimes (1263 cases) were committed by strangers (no relation to the victim).
- Only 55 cases involved an offender related to the victim.

Conclusion:
Crimes are far more likely to be committed by strangers than by someone known to the victim.
/*
-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- Q10. What are the methods used by the public to report a crime? 
-- Hint: Find the complaint type along with the count of crime.*/

SELECT complaint_type,
COUNT(crime_type) AS count_of_crime
FROM report_t
GROUP BY complaint_type
ORDER BY complaint_type DESC;

/*
INSIGHT:
- Phone reporting is the most common method (810 cases).
- In-Person reporting comes next (446 cases).
- Email reporting is very rare (62 cases).

Conclusion:
The majority of the public prefer reporting crimes via phone, while email is the least used method.
/*
