<?php
class dbh {
  private $host = "localhost";
  private $username = "root";
  private $pwd = "";
  private $dbName = "o6u_onlineq";
  private $port = "3307"; // تأكد من إضافة المنفذ

  public function connect(){
    $conn = 'mysql:host=' . $this->host . ';port=' . $this->port . ';dbname=' . $this->dbName;
    $pdo = new PDO($conn, $this->username, $this->pwd);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    return $pdo;
  }
}
