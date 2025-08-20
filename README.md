# Los Angeles Crime Data Analysis

## 1. Project Overview
This project performs an in-depth analysis of a crime dataset from Los Angeles. The primary goal is to uncover key patterns and trends related to crime incidents. By querying the data, we aim to answer critical questions about crime frequency, location hotspots, timing, victim demographics, law enforcement response, and the effectiveness of deterrents like CCTV cameras. The insights derived from this analysis can help inform strategic decision-making for resource allocation and crime prevention.

## 2. 📂 Project Structure
A well-organized folder structure is crucial for maintaining clarity and reproducibility. The following structure is recommended for this project:
```
+--------------------------+
|   LA-Crime-Analysis/     |  <-- Root Directory
+--------------------------+
          |
          |-----> +-------------------------+
          |       |        README.md        |  <-- Project Overview & Insights
          |       +-------------------------+
          |
          |-----> +-------------------------+
          |       |     documentation/      |  <-- Supporting Documents
          |       +-------------------------+
          |                 |
          |                 +-----> +---------------------------+
          |                           |   crime_database_erd.png  |  <-- ERD Image
          |                           +---------------------------+
          |
          +-----> +-------------------------+
                  |      sql_queries/       |  <-- All SQL Code
                  +-------------------------+
                            |
                            |-----> +---------------------------+
                            |       | 01_crime_db_schema.sql  |  <-- Database Setup (from dump file)
                            |       +---------------------------+
                            |
                            +-----> +---------------------------+
                                    | 02_crime_analysis_queries.sql |  <-- All 10 Analysis Queries
                                    +---------------------------+

```
## 3. Dataset Description
The analysis is based on a MySQL database dump (`crime_la-dumpfile.sql`). The database schema consists of four main tables:

* **`report_t`**: The central fact table containing detailed records of each crime incident.
* **`location_t`**: A dimension table with information about different areas, including population density and CCTV camera counts.
* **`officer_t`**: A dimension table containing details about the officers.
* **`victim_t`**: A dimension table providing demographic data about the victims, such as age and sex.

### 3.1 Entity-Relationship Diagram (ERD)
The relationships between the tables can be visualized using the diagram below

## 📌 ER Diagram

```mermaid
erDiagram
    report_t }o--|| location_t : "occurs in"
    report_t }o--|| officer_t : "is handled by"
    report_t }o--|| victim_t : "involves"

    report_t {
        int report_no PK
        int area_code FK
        int officer_code FK
        int victim_code FK
        string crime_type
        time incident_time
        string case_status_desc
    }

    location_t {
        int area_code PK
        string area_name
        int cctv_count
        int population_density
    }

    officer_t {
        int officer_code PK
        string officer_name
        int precinct_code
    }

    victim_t {
        int victim_code PK
        string victim_name
        int victim_age
        char victim_sex
    }



### 4. Tools Used
- **Database**: MySQL
- **Language**: SQL

### 5. Analysis and Key Insights
The following insights were derived by querying the database to answer specific analytical questions.

**Q1: What was the most frequent crime committed each week?**
   - **Insight**: Property crime, specifically **"Burglary from Vehicle,"** is a persistent and escalating issue, being the top crime in 3 out of 4 weeks. Violent crime, such as **"Battery - Simple Assault,"** appears unpredictably, spiking to become the top offense in Week 3.

**Q2: Is crime prevalence linked to population density or police presence?**
  - **Insight**: The data does not support the hypothesis that fewer police lead to more crime. Instead, precincts with the **highest number of reported cases are also assigned the most officers**, suggesting strategic resource deployment. While a loose correlation exists between higher population density and crime, it is not the deciding factor.

**Q3: At what points of the day do different types of crime peak?**
  - **Insight**: Crime types peak at different times of the day.
         - **Violent crimes (Assault/Battery)** are most frequent in the Morning and Afternoon.
         - **Property crimes (Burglary/Theft)** rise significantly in the Evening and Night.

**Q4: At what point in the day do more crimes occur across different localities?**
  - **Insight**: The **Afternoon** is the universal peak time for crime across all localities. **Rampart** stands out as the most significant hotspot, reporting the highest number of incidents during this period.

**Q5: Which age group is most likely to be a victim of crime?**
 - **Insight**: **Middle-Aged individuals (ages 36-55)** are the most targeted demographic, with crime against them peaking in the Afternoon and Morning.

**Q6: What is the status of most reported crimes?**
  - **Insight**: An overwhelming majority of cases **(~90%)** remain under "Investigation Continued." This indicates a very low case closure and arrest rate, highlighting a potential bottleneck in the investigative process.

**Q7: Does the presence of CCTV cameras deter crime?**
  - **Insight**: The data suggests **no direct correlation between the number of CCTV cameras and lower crime rates**. Areas with high CCTV counts, such as Rampart and Hollenbeck, still report the highest number of crimes.

**Q8: Is CCTV footage always recovered from crime scenes?**
 - **Insight**: Even in areas with a high density of cameras, footage is not always available or recovered for every incident. This suggests that reliance on CCTV alone is insufficient for crime investigation.

**Q9: Are crimes more likely to be committed by a person known to the victim?**
 - **Insight**: Crimes are far more likely to be committed by **strangers**. Over 95% of reported offenses were committed by an offender with no relation to the victim.

**Q10: What are the most common methods for reporting a crime?**
- **Insight**: The public overwhelmingly prefers reporting crimes **via phone (810 cases)**. In-person reporting is the second most common method, while email is rarely used.

### 6. Overall Conclusion

This analysis reveals several critical takeaways:

* **Afternoon Crime Spike:** The afternoon is the most vulnerable time of day across all areas, requiring heightened vigilance and resource deployment.

* **Dominance of Property Crime:** Vehicle-related theft is the most persistent and growing threat.

* **Low Case Closure Rate:** The vast majority of crimes remain unsolved, pointing to a need for improved investigative efficiency.

* **Limited CCTV Deterrence:** The number of cameras in an area does not appear to deter crime, suggesting other socio-economic or policing factors are more influential.



