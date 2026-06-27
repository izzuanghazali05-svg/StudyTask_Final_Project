<?php
require __DIR__ . '/config/bootstrap.php';

$data = input();

requireFields($data, ['user_id']);

$userId = (int)$data['user_id'];

$pdo = database();

$sql = "
    SELECT
        id,
        user_id,
        title,
        description,
        course,
        deadline,
        status,
        created_at,
        updated_at
    FROM tasks
    WHERE user_id = ?
    ORDER BY
        CASE status
            WHEN 'Completed' THEN 1
            ELSE 0
        END,
        deadline ASC
";

$statement = $pdo->prepare($sql);
$statement->execute([$userId]);

$tasks = $statement->fetchAll();

respond(
    true,
    'Tasks retrieved successfully.',
    $tasks
);