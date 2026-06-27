<?php
require __DIR__ . '/config/bootstrap.php';

$data = input();

requireFields($data, [
    'email',
    'password'
]);

$email = strtolower(trim($data['email']));
$password = $data['password'];

$pdo = database();

$sql = '
    SELECT id, name, email, password_hash
    FROM users
    WHERE email = ?
';

$statement = $pdo->prepare($sql);
$statement->execute([$email]);

$user = $statement->fetch();

if (
    !$user ||
    !password_verify($password, $user['password_hash'])
) {
    respond(
        false,
        'Incorrect email or password.',
        null,
        401
    );
}

unset($user['password_hash']);

respond(true, 'Login successful.', $user);