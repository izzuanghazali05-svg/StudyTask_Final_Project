<?php
require __DIR__ . '/config/bootstrap.php';

$data = input();

requireFields($data, [
    'id',
    'user_id'
]);

$pdo = database();

$sql = '
    DELETE FROM tasks
    WHERE id = ?
    AND user_id = ?
';

$statement = $pdo->prepare($sql);

$statement->execute([
    (int)$data['id'],
    (int)$data['user_id']
]);

if ($statement->rowCount() === 0) {
    respond(false, 'Task not found.', null, 404);
}

respond(true, 'Task deleted successfully.');