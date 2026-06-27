<?php
require __DIR__ . '/config/bootstrap.php';

$data = input();

requireFields($data, [
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
    INSERT INTO tasks (
        user_id,
        title,
        description,
        course,
        deadline,
        status
    )
    VALUES (?, ?, ?, ?, ?, ?)
';

$statement = $pdo->prepare($sql);

$statement->execute([
    (int)$data['user_id'],
    trim($data['title']),
    trim($data['description']),
    trim($data['course']),
    $data['deadline'],
    $data['status']
]);

respond(
    true,
    'Task added successfully.',
    ['id' => (int)$pdo->lastInsertId()],
    201
);