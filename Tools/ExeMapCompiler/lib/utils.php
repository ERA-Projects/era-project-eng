<?php
declare(strict_types=1);

function getArg (int $argN, string $inputPrompt): string {
  global $argv;

  if (isset($argv[$argN])) {
    return $argv[$argN];
  } else {
    print("{$inputPrompt} ");
    return trim(fgets(STDIN, 2048));
  }
}

function d (...$args): void {
  var_dump(...$args);
}

function fail (string $message = ''): void {
  throw new \RuntimeException($message);
}

function first ($box) {
  foreach ($box as $key => $value) {
    return $value;
  }

  return null;
}