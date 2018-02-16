-- Q1 returns (name,father,mother)

SELECT    name,father,mother
FROM      person
-- Find children who have a date of death before both their mother and father
WHERE     name IN   (SELECT  child.name
                     FROM    person AS father JOIN person AS child
                     ON      father.name = child.father
                     WHERE   child.dod < father.dod)
AND       name IN   (SELECT  child.name
                     FROM    person AS mother JOIN person AS child
                     ON      mother.name = child.mother
                     WHERE   child.dod < mother.dod)
ORDER BY  name;

-- Q2 returns (name)

-- Need to concatenate the monarch name column with the prime minister name column
SELECT    name
FROM      monarch
WHERE     house IS NOT NULL
UNION
SELECT    name
FROM      prime_minister
ORDER BY  name;

-- Q3 returns (name)

SELECT DISTINCT old.name
                  -- Get each monarch with their date of death
FROM            ( SELECT   person.name,monarch.house,person.dod,monarch.accession
                  FROM     person JOIN monarch
                  -- Join this with all monarchs and their date of accession
                  ON       person.name = monarch.name) AS old JOIN monarch AS new
ON        new.accession > old.accession
-- This allows you to find any accession date (other than the current monarch)
-- that is less than the date of death.
WHERE     new.accession < old.dod
ORDER BY  name;

-- Q4 returns (house,name,accession)

SELECT    house,name,accession
FROM      monarch
-- Find the minimum accession date for each house
WHERE     accession <= ALL (SELECT new.accession
                            FROM   monarch AS new
                            WHERE  new.house = monarch.house)
AND       house IS NOT NULL
ORDER BY  accession;

-- Q5 returns (first_name,popularity)

SELECT    first_name, COUNT(first_name) AS popularity
FROM      (SELECT   CASE
                    -- If there is no space character in the column string then this is a single name
                    -- Just return this single name as 'first name'
                    WHEN      LENGTH(SUBSTRING(name FROM 1 FOR POSITION(' ' IN name))) = 0
                    THEN      name
                    -- Otherwise, take the string up until the first space
                    ELSE      SUBSTRING(name FROM 1 FOR POSITION(' ' IN name) - 1)
                    END AS    first_name
                    FROM      person) AS new
GROUP BY  first_name
-- Exclude first names that occur once
HAVING    COUNT(first_name) > 1
ORDER BY  popularity DESC, first_name;

-- Q6 returns (house,seventeenth,eighteenth,nineteenth,twentieth)

SELECT      house,
            -- Simply look for year patterns (cast to text format) matching the corresponding century
            -- Use '%' to match any number (including zero) of characters
            COUNT(CASE WHEN accession::TEXT LIKE '16%' then accession END) AS seventeeth,
            COUNT(CASE WHEN accession::TEXT LIKE '17%' then accession END) AS eighteenth,
            COUNT(CASE WHEN accession::TEXT LIKE '18%' then accession END) AS nineteenth,
            COUNT(CASE WHEN accession::TEXT LIKE '19%' then accession END) AS twentieth
FROM        monarch
WHERE       house IS NOT NULL
GROUP BY    house
ORDER BY    house;

-- Q7 returns (father,child,born)

SELECT      original.name AS father, new.name AS child,
            CASE
            -- If there is no child name, then return null for 'born'
            WHEN new.name IS NULL
            THEN null
            -- Return the rank of each child dob within each father name (i.e. partition)
            ELSE RANK() OVER (PARTITION BY original.name ORDER BY new.dob ASC)
            END AS born
-- Do a left join to get the names of all males, even if they are not listed as a father
FROM        person AS original LEFT JOIN person AS new
ON          original.name = new.father
-- Pick out all men in the person database
WHERE       (original.gender = 'M') IS TRUE
ORDER BY    father, born;

-- Q8 returns (monarch,prime_minister)

-- Only return distinct prime minister names
SELECT DISTINCT monarch_list.name AS monarch, prime_minister.name AS prime_minister
                -- Get each monarch with their start accession date and end accession date
FROM            (SELECT       original.name, original.accession AS start_date,
                              -- Use aggregate function 'MIN' to find the closest next accession date per name
                              -- An empty accession end date means that the monarch is still reigning
                              -- Therefore, use coalesce to replace null with current date
                              COALESCE(MIN(new.accession),current_date) AS end_date
                FROM          monarch AS original LEFT JOIN monarch AS new
                ON            original.accession >= new.accession IS FALSE
                GROUP BY      original.name
                -- Use Cross Join (an ANSI SQL/standard SQL function) to get the Cartesian Product of the two tables
                ORDER BY      MIN(original.accession)) AS monarch_list CROSS JOIN prime_minister
-- The prime minister entry date has to be between the monarch start date and the monarch end date
WHERE           prime_minister.entry > monarch_list.start_date IS TRUE
AND             prime_minister.entry < monarch_list.end_date IS TRUE
ORDER BY        monarch, prime_minister;
