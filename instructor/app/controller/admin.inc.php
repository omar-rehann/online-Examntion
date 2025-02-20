<?php

session_start();
include_once 'autoloader.inc.php';

if ($_SESSION['mydata']->isAdmin) {
    
    if (isset($_GET['suspendStudent'])) {
        $_admin = new admin();
        $_admin->suspendStudent($_GET['suspendStudent']);
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        
    } elseif (isset($_GET['activateStudent'])) {
        $_admin = new admin();
        $_admin->activateStudent($_GET['activateStudent']);
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        
    } elseif (isset($_GET['suspendInstructor'])) {
        $_admin = new admin();
        $_admin->suspendInstructor($_GET['suspendInstructor']);
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        
    } elseif (isset($_GET['activateInstructor'])) {
        $_admin = new admin();
        $_admin->activateInstructor($_GET['activateInstructor']);
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        
    } elseif (isset($_GET['addStudent'])) {
        
        $id = is_numeric($_POST['studentID']) ? $_POST['studentID'] : null;
        $name = isset($_POST['studentName']) ? $_POST['studentName'] : null;
        $email = isset($_POST['email']) ? $_POST['email'] : null;
        $phone = is_numeric($_POST['phone']) ? $_POST['phone'] : null;
        $password = isset($_POST['password']) ? md5($_POST['password']) : null;

        if (($id != null) and ($name != null)) {
            $_admin = new admin();
            $_admin->addStudent($id, $name, $email, $phone, $password);
        }
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        
    } elseif (isset($_GET['exportStudents'])) {
        
        $_admin = new admin();
        $students = $_admin->getAllStudents();
        $data = array("student ID, Name, Email Address, Phone Number");

        foreach ($students as $std) {
            $line = $std->id . ',' . $std->name . ',' . $std->email . ',' . $std->phone;
            array_push($data, $line);
        }

        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename="students.csv"');

        $fp = fopen('php://output', 'wb');
        foreach ($data as $line) {
            $val = explode(",", $line);
            fputcsv($fp, $val);
        }
        fclose($fp);
    }
} else {
    header('Location: /');
}
