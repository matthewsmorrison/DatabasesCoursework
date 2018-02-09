--
-- -- Q1 returns (name,father,mother)
--
-- SELECT    name,father,mother
-- FROM      person AS child
-- WHERE     child.dod IS NOT NULL
-- AND       child.dod IN (SELECT      child.dod
--                         FROM        person AS father JOIN person AS child
--                         ON          father.name = child.father
--                         WHERE       child.dod < father.dod)
-- AND       child.dod IN (SELECT      child.dod
--                         FROM        person AS mother JOIN person AS child
--                         ON          mother.name = child.mother
--                         WHERE       child.dod < mother.dod)
-- ORDER BY  name;
--
-- -- Q2 returns (name)
--
-- SELECT    person.name
-- FROM      person
--           JOIN monarch
--           ON  person.name = monarch.name
-- WHERE     monarch.house IS NOT NULL
-- UNION
-- SELECT    person.name
-- FROM      person
--           JOIN prime_minister
--           ON  person.name = prime_minister.name
-- ORDER BY  name;
--
-- -- Q3 returns (name)
--
-- SELECT DISTINCT old.name
-- FROM            ( SELECT   person.name,monarch.house,person.dod,monarch.accession
--                   FROM     person JOIN monarch
--                   ON       person.name = monarch.name
--                   WHERE    monarch.house IS NOT NULL
--                 ) AS old
--           JOIN monarch AS new
-- ON        new.house = old.house
-- WHERE     new.accession > old.accession
-- AND       new.accession < old.dod
-- ORDER BY  name;
--
-- -- Q4 returns (house,name,accession)
--
-- SELECT    original.house,original.name,original.accession
-- FROM      monarch AS original
-- WHERE     original.accession <= ALL ( SELECT new.accession
--                                       FROM   monarch AS new
--                                       WHERE  new.house = original.house)
-- AND       original.house IS NOT NULL
-- ORDER BY  accession;
--
-- -- Q5 returns (first_name,popularity)
--
-- SELECT    CASE
--           WHEN LENGTH(SUBSTRING(name FROM 1 FOR POSITION(' ' IN name))) = 0
--           THEN name
--           ELSE SUBSTRING(name FROM 1 FOR POSITION(' ' IN name))
--           END AS first_name,
--           COUNT(*) AS popularity
-- FROM      person
-- GROUP BY  first_name
-- HAVING    COUNT(*) > 1
-- ORDER BY  popularity DESC, first_name;

-- -- Q6 returns (house,seventeenth,eighteenth,nineteenth,twentieth)
--
-- SELECT      house,
--             COUNT(CASE WHEN accession::TEXT LIKE '16%' then accession END) AS seventeeth,
--             COUNT(CASE WHEN accession::TEXT LIKE '17%' then accession END) AS eighteenth,
--             COUNT(CASE WHEN accession::TEXT LIKE '18%' then accession END) AS nineteenth,
--             COUNT(CASE WHEN accession::TEXT LIKE '19%' then accession END) AS twentieth
-- FROM        monarch
-- WHERE       house IS NOT NULL
-- GROUP BY    house
-- ORDER BY    house;

-- Q7 returns (father,child,born)

SELECT       original.name AS father, new.name AS child, COUNT(new.name) OVER (PARTITION BY original.name) AS born
FROM         person AS original LEFT JOIN person AS new
ON           original.name = new.father
WHERE        (original.gender = 'M') IS TRUE;


-- SELECT    father, name, dob,
--           COUNT(name) OVER (PARTITION BY father) AS born
-- FROM      person
-- WHERE     father IS NOT NULL;

-- Q8 returns (monarch,prime_minister)

;

-- psql -h db.doc.ic.ac.uk -d family_history -U lab -W -f db_2018_cw1.sql
