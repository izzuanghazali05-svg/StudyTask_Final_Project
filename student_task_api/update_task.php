<?php
require __DIR__ . '/config/bootstrap.php';

$data = input();

requireFields($data, [
    'id',
    'user_id',
    'title',
    'description',
    'course',
    'deadline',
    'status'
]);

if (!validStatus($data['status'])) {
    respond(false, 'Invalid task status.', null, 422);
}

$date = DateTime::createFromFormat(
    'Y-m-d',
    $data['deadline']
);

if (!$date) {
    respond(false, 'Invalid deadline.', null, 422);
}

$pdo = database();

$sql = '
    UPDATE tasks
    SET
        title = ?,
        description = ?,
        course = ?,
        deadline = ?,
        status = ?,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = ?
    AND user_id = ?
';

$statement = $pdo->prepare($sql);

$statement->execute([
    trim($data['title']),
    trim($data['description']),
    trim($data['course']),
    $data['deadline'],
    $data['status'],
    (int)$data['id'],
    (int)$data['user_id']
]);

if ($statement->rowCount() === 0) {
    respond(false, 'Task not found.', null, 404);
}

respond(true, 'Task updated successfully.');