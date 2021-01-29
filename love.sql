SELECT KR.letter
FROM KYRILICA KR
JOIN MORZE MR ON MR.letter = KR.letter
WHERE MR.code in ('•−••','−−−','•••−','•');
