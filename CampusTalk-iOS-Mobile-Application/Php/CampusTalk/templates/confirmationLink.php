<?php




if (empty($_GET["token"])) {
    echo "Missing required information";
}

$token = htmlentities($_GET["token"]);

// STEP 1. Build connection
$file = parse_ini_file("../../../../CampusTalk.ini");

// store in php var information from ini file.
$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

//include access.php to call func from access.php file
require ("../secure/access.php");
$access = new access($host, $user, $pass, $name);
$access->connect();


// STEP 3. GET id of user
// store in $id the result of func.
$id = $access->getUserID("emailTokens", $token)

if (empty($id["id"])){

    echo "User with this token is not found";
    return;
}

// STEP 4. Change status of confirmation and delete token
// assign result of func executed to $result variable
$result = $access->emailConfirmationStatus(1, $id["id"]);

if($result){

    //4.1 delete token from "emailTokens" table of db in mysql
    $access->deleteToken("emailTokens", $token);
    echo "Thank You! Your email is now confirmed!";
}

// STEP 5. Close connection.
$access->disconnect();



?>
