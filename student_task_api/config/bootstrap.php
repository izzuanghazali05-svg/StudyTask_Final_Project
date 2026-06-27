<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, OPTIONS');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

function respond(
    bool $success,
    string $message,
    mixed $data = null,
    int $status = 200
): never {
    http_response_code($status);

    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ]);

    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    respond(false, 'Only POST requests are allowed.', null, 405);
}

function input(): array
{
    $data = json_decode(file_get_contents('php://input'), true);

    if (!is_array($data)) {
        respond(false, 'A valid JSON body is required.', null, 400);
    }

    return $data;
}

function requireFields(array $data, array $fields): void
{
    foreach ($fields as $field) {
        if (
            !isset($data[$field]) ||
            trim((string)$data[$field]) === ''
        ) {
            respond(false, "$field is required.", null, 422);
        }
    }
}

function database(): PDO
{
    try {
        $path = __DIR__ . '/../database/student_tasks.db';

        $pdo = new PDO('sqlite:' . $path);
        $pdo->setAttribute(
            PDO::ATTR_ERRMODE,
            PDO::ERRMODE_EXCEPTION
        );
        $pdo->setAttribute(
            PDO::ATTR_DEFAULT_FETCH_MODE,
            PDO::FETCH_ASSOC
        );

        $pdo->exec('PRAGMA foreign_keys = ON');

        return $pdo;
    } catch (PDOException $e) {
        respond(false, 'Database connection failed.', null, 500);
    }
}

function validStatus(string $status): bool
{
    return in_array(
        $status,
        ['Pending', 'In Progress', 'Completed'],
        true
    );
}