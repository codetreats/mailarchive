<?php
function generate_random_string($length = 8) {
   $rnd = "";
   $aZ09 = array_merge(range('A', 'Z'), range('a', 'z'),range(0, 9));

   for($c=0; $c < $length; $c++) {
      $rnd .= $aZ09[mt_rand(0, count($aZ09)-1)];
   }

   return $rnd;
}

function encrypt_password($password = '') {
   return crypt($password, '$6$rounds=5000$' . generate_random_string() . '$');
}

echo encrypt_password($argv[1]);

?>
