<?php
require __DIR__ . '/config/bootstrap.php';

$data = input();

requireFields($data, [
    'name',
    'email',
    'password'
]);

$name = trim($data['name']);
$email = strtolower(trim($data['email']));
$password = $data['password'];

if (strlen($name) < 2) {
    respond(false, 'Enter a valid name.', null, 422);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    respond(false, 'Enter a valid email.', null, 422);
}

if (strlen($password) < 6) {
    respond(
        false,
        'Password must contain at least 6 characters.',
        null,
        422
    );
}

try {
    $pdo = database();

    $sql = '
        INSERT INTO users (name, email, password_hash)
        VALUES (?, ?, ?)
    ';

    $statement = $pdo->prepare($sql);

    $statement->execute([
        $name,
        $email,
        password_hash($password, PASSWORD_DEFAULT)
    ]);

    respond(
        true,
        'Registration successful.',
        ['id' => (int)$pdo->lastInsertId()],
        201
    );
} catch (PDOException $e) {
    if (str_contains($e->getMessage(), 'UNIQUE')) {
        respond(
            false,
            'This email is already registered.',
            null,
            409
        );
    }

    respond(false, 'Registration failed.', null, 500);
}