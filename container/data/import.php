<?php

function distinct_values($mysqli, $table, $column) {
    $query = "SELECT DISTINCT $column FROM $table";
    $result = $mysqli->query($query);

    $set = [];

    while ($row = $result->fetch_assoc()) {
        array_push($set, strtolower($row[$column]));
    }
    print_r($set);
    $result->free();
    return array_unique($set);
}

function find_mail_addresses_in_file($file)
{
    $emailPattern = "/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/";
    $addresses = [];
    $handle = fopen($file, "r");
    if ($handle) {
        while (($line = fgets($handle)) !== false) {
            if (preg_match($emailPattern, $line, $matches)) {
                array_push($addresses, strtolower($matches[0]));
            }
        }
        fclose($handle);
    }
    return $addresses;
}

function find_mail_files_recursive($directory, &$files)
{
    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($directory, RecursiveDirectoryIterator::SKIP_DOTS),
        RecursiveIteratorIterator::SELF_FIRST
    );

    foreach ($iterator as $file) {
        if ($file->isFile() && $file->getExtension() === 'eml') {
            $files[] = $file->getPathname();
        }
    }
}

$mysqlHostname = getenv("MYSQL_HOSTNAME");
$mysqlUser = getenv("MYSQL_USER");
$mysqlPassword = getenv("MYSQL_PASSWORD");
$mysqlDatabase = getenv("MYSQL_DATABASE");
$sleepTime = intval($argv[1]);

while (true) {
    echo "[IMPORTER] Sleep" . PHP_EOL;
    sleep($sleepTime);

    $mysqli = new mysqli($mysqlHostname, $mysqlUser, $mysqlPassword, $mysqlDatabase);

    $domains = distinct_values($mysqli, "domain", "domain");
    $mailAddresses = distinct_values($mysqli, "email", "email");

    $newDomains = [];
    $newMails = [];

    chdir("/tmp");
    if (!file_exists('/var/piler/import')) {
        mkdir('/var/piler/import', 0777, true);
    }

    $mailFiles = [];
    find_mail_files_recursive("/import", $mailFiles);
    foreach ($mailFiles as $mail) {
        $filename = uniqid();
        echo "[IMPORTER] Process mail: $mail" . PHP_EOL;
        copy($mail, "/var/piler/import/$filename.eml");
        $addresses = find_mail_addresses_in_file("/var/piler/import/$filename.eml");
        print_r($addresses);
        foreach($addresses as $address) {
            $username = explode("@", $address)[0];
            $domain = explode("@", $address)[1];
            if (strlen($domain) < 60 && !in_array($domain, $domains) && !in_array($domain, $newDomains) && strlen($domain)) {
                array_push($newDomains, $domain);
            }
            if (strlen($address) < 120 && !in_array($address, $mailAddresses) && !in_array($address, $newMails)) {
                array_push($newMails, $address);
            }
        }
        unlink($mail);
    }
    
    $query = "INSERT INTO domain (domain, mapped) VALUES (?, ?)";
    $stmt = $mysqli->prepare($query);    
    $domain = "";
    $mapped = "";
    $stmt->bind_param("ss", $domain, $mapped);
    foreach ($newDomains as $domain) {
        $mapped = $domain;
        $stmt->execute();
    }
    $stmt->close();

    $query = "INSERT INTO domain_user (domain, uid) VALUES (?, ?)";
    $stmt = $mysqli->prepare($query);    
    $domain = "";
    $user_id = getenv("USER_UID");
    $stmt->bind_param("si", $domain, $user_id);
    foreach ($newDomains as $domain) {
        $stmt->execute();
    }
    $stmt->close();

    $query = "INSERT INTO email (email, uid) VALUES (?, ?)";
    $stmt = $mysqli->prepare($query);    
    $email = "";
    $user_id = getenv("USER_UID");
    $stmt->bind_param("si", $email, $user_id);
    foreach ($newMails as $email) {
        $stmt->execute();
    }
    $stmt->close();
    $mysqli->close();

    system("pilerimport -d /var/piler/import");
    system("rm -rf /var/piler/import/*");  
}

