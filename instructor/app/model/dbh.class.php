
<?php
class dbh {
  private $host = "localhost";
  private $port = "3307"; // تأكد من المنفذ الصحيح
  private $username = "root";
  private $pwd = ""; // بدون كلمة مرور إذا لم تقم بتعيينها
  private $dbName = "final";

  public function connect(){
    try {
      $conn = 'mysql:host=' . $this->host . ';port=' . $this->port . ';dbname=' . $this->dbName . ';charset=utf8mb4';
      $pdo = new PDO($conn, $this->username, $this->pwd);
      $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
      $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
      return $pdo;
    } catch (PDOException $e) {
      die("Database connection failed: " . $e->getMessage());
    }
  }
}
?>
