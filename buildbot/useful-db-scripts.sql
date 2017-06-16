# Count older commits in next:
SELECT COUNT(*) FROM buildbot.changes where project = 'next' and when_timestamp < unix_timestamp(DATE_SUB(now(), INTERVAL 7 DAY));
# Get rid of them:
DELETE FROM buildbot.changes where project = 'next' and when_timestamp < unix_timestamp(DATE_SUB(now(), INTERVAL 7 DAY));
