USE company;


#Names of all the members who have recommended another member.
SELECT DISTINCT recs.firstname as firstname, recs.surname AS surname
FROM members mems
JOIN members recs
ON recs.memid = mems.recommendedby
ORDER BY surname, firstname;


#Facility with the highest number of booked slots.
SELECT facid, SUM(slots) AS totalslots
FROM bookings
GROUP BY facid
HAVING SUM(slots) = 
(SELECT MAX(sum2.totalslots) 
FROM
(SELECT SUM(slots) AS totalslots
FROM bookings
GROUP BY facid
) AS sum2);


#Name and revenue of facilities with a total revenue less
-- than 1000.
SELECT name, revenue 
FROM
(SELECT f.name, SUM(
CASE
WHEN memid = 0 
THEN slots * f.guestcost
ELSE slots * f.membercost
END) AS revenue
FROM bookings b
JOIN facilities f
ON b.facid = f.facid
GROUP BY f.name ) AS agg
WHERE revenue < 1000;


#Start times for bookings by members named Matthew.
SELECT mems.memid, bks.starttime
FROM bookings bks
JOIN members mems
ON mems.memid = bks.memid
WHERE mems.firstname = 'Matthew';



SELECT DISTINCT CONCAT(m.firstname,' ', m.surname) AS 'Name',
f.name AS 'Facility'
FROM bookings b 
JOIN members m
ON b.memid = m.memid
JOIN facilities f
ON b.facid = f.facid
WHERE b.facid IN(0,1);


#Count the recommendations each member has made.
SELECT COUNT(*)
FROM members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby;


#Total slots booked in 2012 per facility per month.
SELECT facid, MONTH(starttime) AS Month, SUM(slots) AS "Total Slots"
FROM bookings
WHERE starttime >= '2012-01-01'
AND starttime < '2013-01-01'
GROUP BY facid, Month;


#Name and total revenue of each facility.
SELECT facs.name, SUM(slots * 
CASE
WHEN memid = 0 
THEN facs.guestcost
ELSE facs.membercost
END) AS revenue
FROM bookings bks
JOIN facilities facs
ON bks.facid = facs.facid
GROUP BY facs.name;

#Upward recommendation chain for any member.
WITH RECURSIVE recommenders(recommender, member) AS (
SELECT recommendedby, memid
FROM members
UNION ALL
SELECT mems.recommendedby, recs.member
FROM recommenders recs
INNER JOIN members mems
ON mems.memid = recs.recommender
)
SELECT recs.member, recs.recommender, mems.firstname, mems.surname
FROM recommenders recs
INNER JOIN members mems
ON recs.recommender = mems.memid
WHERE recs.member = 22 OR recs.member = 12;