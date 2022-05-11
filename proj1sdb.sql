-- comp9311 22T1 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(subject_name)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT
	subjects."name" AS subject_name 
FROM
	subjects 
WHERE
	subjects."_prereq" LIKE'%COMP3%' 
	AND subjects."_prereq" LIKE'%and COMP3%'
;

-- Q2:
create or replace view Q2(course_id)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT
	courses."id" course_id 
FROM
	courses
	INNER JOIN classes ON courses."id" = classes.course
	INNER JOIN class_types ON classes.ctype = class_types."id"
	INNER JOIN rooms ON classes.room = rooms."id"
	INNER JOIN buildings ON rooms.building = buildings."id" 
WHERE
	class_types."name" = 'Studio' 
GROUP BY
	courses."id" 
HAVING
	COUNT ( DISTINCT rooms.building ) >= 3;
;

-- Q3:
create or replace view Q3(course_id, use_rate)
as 
--... SQL statements, possibly using other views/functions defined by you ...
SELECT
	courses."id" AS course_id,
	COUNT ( EXTRACT ( YEAR FROM classes.startdate ) ) AS use_rate 
FROM
	courses
	INNER JOIN classes ON courses."id" = classes.course
	INNER JOIN rooms ON classes.room = rooms."id"
	INNER JOIN buildings ON rooms.building = buildings."id" 
WHERE
	buildings."name" = 'Central Lecture Block' 
	AND EXTRACT ( YEAR FROM classes.startdate ) = 2008 
GROUP BY
	courses."id" 
ORDER BY
	2 DESC
;

-- Q4:
create or replace view Q4(facility)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT
	description AS facility 
FROM
	facilities 
WHERE
	ID NOT IN (
	SELECT
		facilities."id" 
	FROM
		facilities
		INNER JOIN room_facilities ON facilities."id" = room_facilities.facility
		INNER JOIN rooms ON room_facilities.room = rooms."id"
		LEFT JOIN buildings ON rooms.building = buildings."id" 
	WHERE
	buildings.gridref LIKE'K%' 
	)
;

--Q5:
create or replace view Q5(unsw_id, student_name)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT DISTINCT
	people."id",
	people."name" 
FROM
	students
	INNER JOIN people ON students."id" = people."id"
	INNER JOIN course_enrolments ON students."id" = course_enrolments.student 
WHERE
	students.stype = 'local' 
	AND course_enrolments.grade = 'HD';
;

-- Q6:
create or replace view Q6(subject_name, non_null_mark_count, null_mark_count)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT
	subjects."name" AS subject_name,
	SUM ( CASE WHEN course_enrolments.mark IS NOT NULL THEN 1 ELSE 0 END ) AS non_null_mark_count,
	SUM ( CASE WHEN course_enrolments.mark IS NULL THEN 1 ELSE 0 END ) AS null_mark_count
	
FROM
	subjects
	INNER JOIN courses ON subjects."id" = courses.subject
	INNER JOIN course_enrolments ON courses."id" = course_enrolments.course
	INNER JOIN semesters ON subjects.firstoffer = semesters."id" 
	AND subjects.lastoffer = semesters."id" 
	AND courses.semester = semesters."id" 
WHERE
	semesters."name" LIKE'%Sem1 2006%' 
GROUP BY
	subjects."name"
;

-- Q7:
create or replace view Q7(school_name, stream_count)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT
	orgunits.longname,
	COUNT ( streams."id" ) 
FROM
	orgunits
	INNER JOIN streams ON orgunits."id" = streams.offeredby 
GROUP BY
	orgunits.longname 
HAVING
	COUNT ( streams."id" ) > ( SELECT COUNT ( streams."id" ) FROM orgunits INNER JOIN streams ON orgunits."id" = streams.offeredby WHERE orgunits.longname = 'School of Computer Science and Engineering' )
;

-- Q8: 
create or replace view Q8(student_name_local, student_name_intl)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT
	* 
FROM
	(
	SELECT
		people."name" AS student_name_local 
	FROM
		subjects
		INNER JOIN courses ON subjects."id" = courses.subject
		INNER JOIN course_enrolments ON courses."id" = course_enrolments.course
		INNER JOIN semesters ON subjects.firstoffer = semesters."id" 
		AND subjects.lastoffer = semesters."id" 
		AND courses.semester = semesters."id"
		INNER JOIN students ON course_enrolments.student = students."id"
		INNER JOIN people ON students."id" = people."id" 
		WHERE subjects."name" = 'Engineering Design' AND
		course_enrolments.mark > 98 
		AND students.stype = 'local' 
	)
	A CROSS JOIN (
	SELECT
		people."name" AS student_name_intl 
	FROM
		subjects
		INNER JOIN courses ON subjects."id" = courses.subject
		INNER JOIN course_enrolments ON courses."id" = course_enrolments.course
		INNER JOIN semesters ON subjects.firstoffer = semesters."id" 
		AND subjects.lastoffer = semesters."id" 
		AND courses.semester = semesters."id"
		INNER JOIN students ON course_enrolments.student = students."id"
		INNER JOIN people ON students."id" = people."id" 
		WHERE subjects."name" = 'Engineering Design' AND
		course_enrolments.mark > 98 
	AND students.stype = 'intl' 
	) B
;

-- Q9:
create or replace view Q9(ranking, course_id, subject_name, student_diversity_score)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT RANK ( ) OVER ( ORDER BY diversity DESC ) ranking,
	course_id,
	subject_name,
	diversity AS student_diversity_score 
FROM
	(
	SELECT
		subjects.code AS subject_name,
		courses."id" AS course_id,
		AVG ( countries."id" ) AS diversity 
	FROM
		people
		INNER JOIN students ON people."id" = students."id"
		INNER JOIN countries ON people.origin = countries."id"
		INNER JOIN course_enrolments ON students."id" = course_enrolments.student
		INNER JOIN courses ON course_enrolments.course = courses."id"
		INNER JOIN subjects ON courses.subject = subjects."id" 
	GROUP BY
		subjects.code,
	courses."id" 
	) A

;

-- Q10:
create or replace view Q10(subject_code, avg_mark)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT
	subjects.code AS code,
	AVG ( course_enrolments.mark ) 
FROM
	subjects
	INNER JOIN courses ON subjects."id" = courses.subject
	INNER JOIN course_enrolments ON courses."id" = course_enrolments.course
	INNER JOIN semesters ON subjects.firstoffer = semesters."id" 
	AND subjects.lastoffer = semesters."id" 
	AND courses.semester = semesters."id"
	INNER JOIN orgunits ON subjects.offeredby = orgunits."id" 
WHERE
	semesters."name" LIKE'%Sem1 2010%' 
	AND subjects.career = 'PG' 
	AND ( orgunits."longname" = 'School of Chemistry' OR orgunits."longname" = 'School of Accounting' ) 
	AND courses."id" IN (
	SELECT
		courses."id" 
	FROM
		subjects
		INNER JOIN courses ON subjects."id" = courses.subject
		INNER JOIN course_enrolments ON courses."id" = course_enrolments.course
		INNER JOIN semesters ON subjects.firstoffer = semesters."id" 
		AND subjects.lastoffer = semesters."id" 
		AND courses.semester = semesters."id"
		INNER JOIN orgunits ON subjects.offeredby = orgunits."id" 
	WHERE
		semesters."name" LIKE'%Sem1 2010%' 
		AND subjects.career = 'PG' 
		AND ( orgunits."longname" = 'School of Chemistry' OR orgunits."longname" = 'School of Accounting' ) 
	GROUP BY
		courses."id" 
	HAVING
		COUNT ( course_enrolments.student ) > 10 
	) 
GROUP BY
	subjects.code
;

-- Q11:
create or replace view Q11(subject_code, inc_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT A
	.code AS subject_code,
	round( ( ( b.avgmarks ) - ( A.avgmarks ) ) / ( A.avgmarks ), 4 ) AS inc_rate 
FROM
	(
	SELECT
		subjects.code AS code,
		AVG ( course_enrolments.mark ) AS avgmarks 
	FROM
		subjects
		INNER JOIN courses ON subjects."id" = courses.subject
		INNER JOIN course_enrolments ON courses."id" = course_enrolments.course
		INNER JOIN semesters ON subjects.firstoffer = semesters."id" 
		AND subjects.lastoffer = semesters."id" 
		AND courses.semester = semesters."id"
		INNER JOIN orgunits ON subjects.offeredby = orgunits."id" 
	WHERE
		semesters."name" LIKE'%Sem1%' 
		AND ( orgunits.longname = 'School of Chemistry' OR orgunits.longname = 'School of Accounting' ) 
	GROUP BY
		subjects.code 
	)
	A INNER JOIN (
	SELECT
		subjects.code AS code,
		AVG ( course_enrolments.mark ) AS avgmarks 
	FROM
		subjects
		INNER JOIN courses ON subjects."id" = courses.subject
		INNER JOIN course_enrolments ON courses."id" = course_enrolments.course
		INNER JOIN semesters ON subjects.firstoffer = semesters."id" 
		AND subjects.lastoffer = semesters."id" 
		AND courses.semester = semesters."id"
		INNER JOIN orgunits ON subjects.offeredby = orgunits."id" 
	WHERE
		semesters."name" LIKE'%Sem2%' 
		AND ( orgunits.longname = 'School of Chemistry' OR orgunits.longname = 'School of Accounting' ) 
	GROUP BY
	subjects.code 
	) B ON A.code = b.code
;

-- Q12:
create or replace view Q12(name, subject_code, year, term, lab_time_per_week)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT
	people."name",
	subjects.code AS subject_code,
	semesters.term,
	semesters."year",
	SUM ( classes.endtime - classes.starttime ) AS lab_time_per_week 
FROM
	people
	INNER JOIN staff ON people."id" = staff."id"
	INNER JOIN course_staff ON staff."id" = course_staff.staff
	INNER JOIN staff_roles ON course_staff."role" = staff_roles."id"
	INNER JOIN courses ON course_staff.course = courses."id"
	INNER JOIN subjects ON courses.subject = subjects."id"
	INNER JOIN classes ON courses."id" = classes.course
	INNER JOIN class_types ON classes.ctype = class_types."id"
	INNER JOIN semesters ON subjects.firstoffer = semesters."id" 
	AND subjects.lastoffer = semesters."id" 
	AND courses.semester = semesters."id" 
WHERE
	staff_roles."name" LIKE'%Lecturer%' 
	AND class_types.unswid = 'LAB' 
GROUP BY
	people."name",
	subjects.code,
	semesters.term,
	semesters."year",
	EXTRACT ( 'week' FROM classes.startdate )
;

-- Q13:
create or replace view Q13(subject_code, year, term, fail_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT
	subjects.code AS subject_code,
	semesters."year",
	semesters.term,
	round( SUM ( CASE WHEN course_enrolments.mark < 50 THEN 1 ELSE 0 END ), 4 ) / round( SUM ( CASE WHEN course_enrolments.mark >= 50 THEN 1 ELSE 0 END ), 4 ) AS fail_rate 
FROM
	subjects
	INNER JOIN courses ON subjects."id" = courses.subject
	INNER JOIN classes ON courses."id" = classes.course
	INNER JOIN semesters ON subjects.firstoffer = semesters."id" 
	AND subjects.lastoffer = semesters."id" 
	AND courses.semester = semesters."id"
	INNER JOIN course_enrolments ON courses."id" = course_enrolments.course 
GROUP BY
	subjects.code,
	semesters."year",
	semesters.term 
HAVING
	SUM ( 1 ) > 150
;