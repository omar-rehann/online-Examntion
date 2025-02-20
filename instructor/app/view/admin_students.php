
<?php
if (!defined('NotDirectAccess')) {
    die('Direct Access is not allowed to this page');
}
require_once 'header.php';
require_once 'navbar.php';
$_admin = new admin();
?>
<div class="card">
  <div class="card-header">
    <strong class="card-title">All Registered Students</strong>
    <a class="btn btn-outline-primary float-right m-1" href="app/controller/admin.inc.php?exportStudents">
        <i class="fa fa-cloud-download"></i> Export CSV
    </a>
    <button type="button" class="btn btn-outline-primary float-right m-1" data-toggle="modal" data-target="#addStudent">
        <i class="fa fa-plus"></i> Add Student
    </button>
  </div>

  <div class="card-body">
    <table id="allStudents" class="table table-striped table-bordered">
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Email</th>
          <th>Phone Number</th>
          <th>Registered</th>
          <th>Status</th>
          <th>-</th>
          <th>-</th>
          <th>-</th>
        </tr>
      </thead>
      <tbody>
        <?php
        $students = $_admin->getAllStudents();
        foreach ($students as $student) { ?>
          <tr>
            <td><strong><?php echo $student->id; ?></strong></td>
            <td><?php echo $student->name; ?></td>
            <td><?php echo $student->email; ?></td>
            <td><?php echo $student->phone; ?></td>
            <td><?php echo empty($student->password) ? '<span class="badge badge-danger">No</span>' : '<span class="badge badge-success">Yes</span>'; ?></td>
            <?php if ($student->suspended) { ?>
                <td><span class="badge badge-danger">Suspended</span></td>
                <td>
                  <button type="button" class="btn btn-outline-success btn-block"
                    onclick="customConfirm('app/controller/admin.inc.php?activateStudent=<?php echo $student->id ?>','Are you sure you want to Reactivate This Student?','The Student has been reactivated.')">
                    <i class="fa fa-repeat"></i> Activate
                  </button>
                </td>
            <?php } else { ?>
                <td><span class="badge badge-success">Active</span></td>
                <td>
                  <button type="button" class="btn btn-outline-secondary btn-block"
                    onclick="customConfirm('app/controller/admin.inc.php?suspendStudent=<?php echo $student->id ?>','Are you sure you want to suspend this Student?','The Student has been suspended.')">
                    <i class="fa fa-ban"></i> Suspend
                  </button>
                </td>
            <?php } ?>
            <td>
                <button class="btn btn-outline-danger btn-block"
                    onclick="customConfirm('app/controller/student.inc.php?deleteStudent=<?php echo $student->id ?>','The student and its results will be permanently deleted','The Student has been deleted.')">
                    <i class="fa fa-trash"></i> Remove
                </button>
            </td>
            <td>
              <a type="button" href="?results&studentID=<?php echo $student->id ?>" class="btn btn-outline-success btn-block">
                <i class="fa fa-list"></i> View All Results
              </a>
            </td>
          </tr>
        <?php } ?>
      </tbody>
    </table>
  </div>
</div>

<div class="modal fade" id="addStudent" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Add New Student</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id="addStudentForm" action="app/controller/admin.inc.php?addStudent" method="post">
                    <div class="form-group">
                        <label for="studentID" class="col-form-label">Student ID:</label>
                        <input type="text" class="form-control" id="studentID" name="studentID" required placeholder="Enter Student ID" minlength="7">
                    </div>
                    <div class="form-group">
                        <label for="SNAME" class="col-form-label">Student Name:</label>
                        <input type="text" class="form-control" id="SNAME" name="studentName" required placeholder="Enter Student Name">
                    </div>
                    <div class="form-group">
                        <label for="email" class="col-form-label">Email Address:</label>
                        <input type="email" class="form-control" id="email" name="email">
                    </div>
                    <div class="form-group">
                        <label for="phone" class="col-form-label">Phone Number:</label>
                        <input type="number" class="form-control" id="phone" name="phone">
                    </div>
                    <div class="form-group">
                        <label for="password" class="col-form-label">Password:</label>
                        <input type="password" class="form-control" id="password" name="password">
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="submit" form="addStudentForm" class="btn btn-primary">Add</button>
            </div>
        </div>
    </div>
</div>

<?php
define('ContainsDatatables', true);
require_once 'footer.php';
?>
