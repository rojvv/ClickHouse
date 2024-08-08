CREATE TABLE t1
(
    `s1` String,
    `s2` String,
    `s3` String
)
ENGINE = MergeTree
ORDER BY tuple();


CREATE TABLE t2
(
    `fs1` FixedString(10),
    `fs2` FixedString(10)
)
ENGINE = MergeTree
ORDER BY tuple();

INSERT INTO t1 SELECT
    repeat('t', 15) s1,
    'test' s2,
    'test' s3;

INSERT INTO t1 SELECT
    substring(s1, 1, 10),
    s2,
    s3
FROM generateRandom('s1 String, s2 String, s3 String')
LIMIT 10000;

optimize table t1 final;

INSERT INTO t2 SELECT *
FROM generateRandom()
LIMIT 10000;

WITH
tmp1 AS
(
    SELECT
        CAST(s1, 'FixedString(10)') AS fs1,
        s2 AS sector,
        s3
    FROM t1
    WHERE  (s3 != 'test')
)
    SELECT
        fs1
    FROM t2
    LEFT JOIN tmp1 USING (fs1)
    WHERE (fs1 IN ('test'));