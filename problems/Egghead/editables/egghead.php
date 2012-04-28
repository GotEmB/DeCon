<?php
function isLeapYear( $nYEAR ) 
{ 
  if ((( $nYEAR % 4 == 0 ) AND !( $nYEAR % 100 == 0 )) AND ( $nYEAR % 400 != 0 )) 
  { 
    return TRUE; 
  } 
  else 
  { 
    return FALSE; 
  } 
} 
 
function div( $a, $b )
{ 
  return( $a - ( $a % $b )) / $b; 
} 
 
function easterSunday( $nYEAR ) 
{ 
  // The function is able to calculate the date of eastersunday back to the year 325, 
  // but mktime() starts at 1970-01-01! 
  if ( $nYEAR < 1970 ) 
  { 
     $dtEasterSunday = mktime( 1,1,1,1,1,1970 ); 
  } 
  else 
  { 
    $nGZ = ( $nYEAR % 19 ) + 1; 
    $nJHD = div( $nYEAR, 100 ) + 1; 
    $nKSJ = div( 3 * $nJHD, 4 ) - 12; 
    $nKORR = div( 8 * $nJHD + 5, 25 ) - 5; 
    $nSO = div( 5 * $nYEAR, 4 ) - $nKSJ - 10; 
    $nEPAKTE = (( 11 * $nGZ + 20 + $nKORR - $nKSJ ) % 30 ); 
 
    if (( $nEPAKTE == 25 OR $nGZ == 11 ) AND $nEPAKTE == 24 ) 
    { 
      $nEPAKTE = $nEPAKTE + 1; 
    }
 
    $nN = 44 - $nEPAKTE; 
    if( $nN < 21 ) 
    { 
      $nN = $nN + 30; 
    } 
    $nN = $nN + 7 - (( $nSO + $nN ) % 7 ); 
    $nN = $nN + isLeapYear( $nYEAR ); 
    $nN = $nN + 59; 
     
    $nA = isLeapYear( $nYEAR ); 
    // Month 
    $nNM = $nN; 
    if ( $nNM > ( 59 + $nA )) 
    { 
      $nNM = $nNM + 2 - $nA; 
    } 
    $nNM = $nNM + 91; 
    $nMONTH = div( 20 * $nNM, 611 ) - 2; 
     
    // Day 
    $nNT = $nN; 
    $nNT = $nN; 
    if ( $nNT > ( 59 + $nA )) 
    { 
      $nNT = $nNT + 2 - $nA; 
    } 
    $nNT = $nNT + 91; 
    $nM = div( 20 * $nNT, 611 ); 
    $nDAY = $nNT - div( 611 * $nM, 20 ); 
     
    $dtEasterSunday = mktime( 0,0,0,$nMONTH,$nDAY,$nYEAR ); 
  } 
  return $dtEasterSunday; 
} 
 
  $stdin = fopen('php://stdin', "r");
  $stdout = fopen('php://stdout', "w");
 
  while (true) 
  {
    fscanf($stdin, "%d", $year);
    $easterDay = easterSunday($year);
    $day = date("d:m:y", $easterDay);
    fwrite($stdin, sprintf($day));
  }
 
  fclose($stdin);
  fclose($stdout);
?>