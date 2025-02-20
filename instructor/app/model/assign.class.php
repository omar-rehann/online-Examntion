<?php
class assign extends dbh {

    public function getTestInvitations($testID) {
        $stmt = $this->connect()->prepare("SELECT ti.id, name, HEX(AES_ENCRYPT(ti.id, 'O6U')) as invite, ts.startTime, ts.endTime, ts.random, ts.prevQuestion, ts.duration, ts.passPercent, ts.sendToStudent, ts.releaseResult,
        CASE WHEN ((convert_tz(now(), @@session.time_zone, '+02:00') between ts.startTime AND ts.endTime) and used <= useLimit) THEN 1
        WHEN ((convert_tz(now(), @@session.time_zone, '+02:00') < ts.startTime) and used <= useLimit) THEN 2
        ELSE 0
        END as status
        FROM test_invitations ti
        INNER JOIN test_settings ts
        ON ti.settingID = ts.id
        WHERE ti.instructorID = :instID AND ti.testID = :testID");
        $stmt->bindparam(":instID", $_SESSION['mydata']->id);
        $stmt->bindparam(":testID", $testID);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_OBJ);
        return $result;
    }

    public function getGroupSettings() {
        $stmt = $this->connect()->prepare("SELECT g.`name`, ts.id FROM groups g
                                 INNER JOIN test_settings ts
                                 ON ts.id = g.settingID WHERE g.instructorID = :instID");
        $stmt->bindparam(":instID", $_SESSION['mydata']->id);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_OBJ);
        return $result;
    }

    public function getSettings() {
        $stmt = $this->connect()->prepare("SELECT g.`name`, ts.id FROM groups g
                                 INNER JOIN test_settings ts
                                 ON ts.id = g.settingID WHERE g.instructorID = :instID");
        $stmt->bindparam(":instID", $_SESSION['mydata']->id);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_OBJ);
        return $result;
    }

    public function getSettingByID($id) {
        $stmt = $this->connect()->prepare("SELECT * FROM test_settings WHERE id = :id");
        $stmt->bindparam(":id", $id);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_OBJ);
        if (!empty($result))
            return $result[0];
        else
            return false;
    }

    public function getExistingLinks() {
        $stmt = $this->connect()->prepare("SELECT id, name, settingID FROM test_invitations WHERE instructorID = :instID");
        $stmt->bindparam(":instID", $_SESSION['mydata']->id);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_OBJ);
        return $result;
    }

    public function getLastCode() {
        $stmt = $this->connect()->prepare("SELECT max(id) as id FROM test_invitations WHERE instructorID = :instructorID");
        $stmt->bindparam(":instructorID", $_SESSION['mydata']->id);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_OBJ);
        return $result[0]->id;
    }

    public function createSetting($start, $end, $random, $prevQuestion, $duration, $percent, $viewAnswers, $releaseResult, $sendToS, $sendToI) {
        $this->deleteUnusedSettings();
        try {
            $stmt = $this->connect()->prepare("INSERT INTO test_settings(startTime, endTime, duration, random, prevQuestion, viewAnswers, releaseResult, sendToStudent, sendToInstructor, passPercent, instructorID)
            VALUES (:startTime, :endTime, :duration, :random, :prevQuestion, :viewAnswers, :releaseResult, :sendToStudent, :sendToInstructor, :passPercent, :instructorID);");
            $stmt->bindparam(":startTime", $start);
            $stmt->bindparam(":endTime", $end);
            $stmt->bindparam(":duration", $duration);
            $stmt->bindparam(":random", $random);
            $stmt->bindparam(":prevQuestion", $prevQuestion);
            $stmt->bindparam(":releaseResult", $releaseResult);
            $stmt->bindparam(":viewAnswers", $viewAnswers);
            $stmt->bindparam(":sendToStudent", $sendToS);
            $stmt->bindparam(":sendToInstructor", $sendToI);
            $stmt->bindparam(":passPercent", $percent);
            $stmt->bindparam(":instructorID", $_SESSION['mydata']->id);
            $stmt->execute();
            return true;
        } catch (PDOException $e) {
            echo $e->getMessage();
            return false;
        }
    }

    public function updateLinkAssign($linkID, $name, $useLimit) {
        $stmt = $this->connect()->prepare("UPDATE test_invitations
        SET name = :name,
        useLimit = :useLimit,
        settingID = (SELECT MAX(id) FROM test_settings WHERE instructorID = :instructorID)
        WHERE id = :linkID");
        $stmt->bindparam(":linkID", $linkID);
        $stmt->bindparam(":name", $name);
        $stmt->bindparam(":useLimit", $useLimit);
        $stmt->bindparam(":instructorID", $_SESSION['mydata']->id);
        $stmt->execute();
        return true;
    }

    public function AssignToGroup($groupID, $testID) {
        $stmt = $this->connect()->prepare("UPDATE groups
        SET assignedTest = :testID,
        settingID = (SELECT MAX(id) FROM test_settings WHERE instructorID = :instructorID)
        WHERE id = :groupID AND instructorID = :instructorID");
        $stmt->bindparam(":groupID", $groupID);
        $stmt->bindparam(":testID", $testID);
        $stmt->bindparam(":instructorID", $_SESSION['mydata']->id);
        $stmt->execute();
        return true;
    }

    public function deleteGroupAssign($groupID) {
        $stmt = $this->connect()->prepare("UPDATE groups
        SET assignedTest = null,
        settingID = null
        WHERE id = :groupID AND instructorID = :instructorID");
        $stmt->bindparam(":groupID", $groupID);
        $stmt->bindparam(":instructorID", $_SESSION['mydata']->id);
        $stmt->execute();
        $this->deleteUnusedSettings();
        return true;
    }

    public function deleteUnusedSettings() {
        $stmt = $this->connect()->prepare("DELETE FROM test_settings
        WHERE NOT EXISTS (SELECT 1 FROM groups WHERE settingID = test_settings.id)
        AND NOT EXISTS (SELECT 1 FROM result WHERE settingID = test_settings.id)
        AND NOT EXISTS (SELECT 1 FROM test_invitations WHERE settingID = test_settings.id)");
        $stmt->execute();
        return true;
    }
}