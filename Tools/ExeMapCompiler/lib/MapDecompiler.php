<?php
declare(strict_types=1);

/**
 * Decompiles *.dbgmap files into some sort of *.map files.
 */
class MapDecompiler {
  protected $map;
  protected $mapLen;
  protected $pos;
  protected $result;
  protected $addrToLabel;
  protected $modules;
  protected $lineNumbers;

  public function __construct (string $map) {
    $this->map    = $map;
    $this->mapLen = strlen($map);
  }

  protected function prepareForDecompilation () {
    $this->result      = '';
    $this->pos         = 0;
    $this->addrToLabel = [];
    $this->modules     = [];
    $this->lineNumbers = [];
  }

  public function decompile (): string {
    $this->prepareForDecompilation();
    $this->readLabelsSection();
    $this->readModulesList();
    $this->readLineNumbersSection();
    $this->writeAddressSection($this->buildJoinedAddrMap());

    return $this->result;
  }

  protected function readLabelsSection (): void {
    $numLabels = $this->readUint();

    for ($i = 0; $i < $numLabels; $i++) {
      $this->addrToLabel[$this->readAddr()] = $this->readStr();
    }
  }

  protected function readModulesList (): void {
    $numModules = $this->readUint();

    for ($i = 0; $i < $numModules; $i++) {
      $this->modules[] = $this->readStr();
    }
  }

  protected function readLineNumbersSection (): void {
    $numLines = $this->readUint();

    for ($i = 0; $i < $numLines; $i++) {
      $addr                     = $this->readAddr();
      $moduleInd                = $this->readUint();
      $lineN                    = $this->readUint();
      $this->lineNumbers[$addr] = [$moduleInd, $lineN];
    }
  }

  protected function buildJoinedAddrMap (): array {
    $result     = $this->addrToLabel;
    $numModules = count($this->modules);

    foreach ($this->lineNumbers as $addr => list($moduleInd, $lineN)) {
      if ($moduleInd >= 0 && $moduleInd < $numModules) {
        isset($result[$addr]) or $result[$addr] = "{$this->modules[$moduleInd]}:{$lineN}";
      }
    }

    ksort($result, SORT_NUMERIC);

    return $result;
  }

  protected function writeAddressSection (array $addrMap): void {
    $this->result .= "Address     Label\r\n\r\n";

    foreach ($addrMap as $addr => $label) {
      $this->result .= $this->addrToComplexAddr($addr) . "    $label\r\n";
    }
  }

  protected function addrToComplexAddr ($addr): string {
    return sprintf('%08x', $addr);
  }

  protected function readStr (): string {
    $strLen = $this->readUint();

    return $strLen ? $this->readBytes($strLen) : '';
  }

  protected function readInt (): int {
    $this->pos + 4 <= $this->mapLen or $this->fail("Failed to read int. End of file");
    $result = unpack('V', substr($this->map, $this->pos, 4))[1];
    $this->pos += 4;

    return $result <= 2147483647 ? $result : $result - 4294967296;
  }

  protected function readAddr (): string {
    $this->pos + 4 <= $this->mapLen or $this->fail("Failed to read int. End of file");
    $result = unpack('V', substr($this->map, $this->pos, 4))[1];
    $this->pos += 4;

    return $result >= 0 ? "$result" : (($result + 4294967296) . '.');
  }

  protected function readUint (): int {
    $result = $this->readInt();

    return $result >= 0 ? $result : $this->fail("Expected uint32. Got: $result");
  }

  protected function readBytes (int $numBytes): string {
    assert($numBytes >= 0);
    $this->pos + $numBytes < $this->mapLen or $this->fail("Failed to read $numBytes bytes. End of file");
    $result = substr($this->map, $this->pos, $numBytes);
    $this->pos += $numBytes;

    return $result;
  }

  protected function fail (string $message = ''): void {
    \fail("{$message}. Error at pos " . $this->pos);
  }
} // .class MapDecompiler