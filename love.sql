SELECT EA.letter
FROM English_Alphabet EA
JOIN MORZE MR ON MR.letter = EA.letter
WHERE MR.code in ('•−••','−−−','•••−','•');
