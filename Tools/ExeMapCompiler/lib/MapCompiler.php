<?php
declare(strict_types=1);

/**
 * Supports Delphi, Virtual Pascal and Visual Studio maps.
 */

class MapCompiler {
  protected $map;
  protected $lines;
  protected $line;
  protected $result;
  protected $peSections;
  protected $addrToLabel;
  protected $modules;
  protected $lineNumbers;

  public function __construct (string $map) {
    $this->map = $map;
    $this->readMap($map);
  }

  protected function prepareForCompilation () {
    $this->result      = '';
    $this->baseAddr    = 0;
    $this->peSections  = [];
    $this->addrToLabel = [];
    $this->modules     = [];
    $this->lineNumbers = [];
  }

  protected function readMap (string $map): void {
    $this->lines = array_map('trim', explode("\n", str_replace("\r", '', trim($map))));
    $this->line  = 0;
  }

  public function compile (): string {
    $this->prepareForCompilation();
    $this->processSections();
    $this->writeLabelsSection();
    $this->writeModulesList();
    $this->writeLineNumbersSection();

    return $this->result;
  }

  protected function processSections () {
    while (!$this->eof()) {
      if (!$this->isSection()) {
        // Skip invalid lines without section name
        $this->gotoNextSection();
      } elseif ($this->isSection('Start ')) {
        $this->processStartSection();
      } elseif (!$this->peSections) {
        // Skip everything before Start section
        $this->gotoNextSection();
      } else {
        $this->peSections or $this->fail("Expected 'Start' section. Got: {$this->readSectionName()}");

        if ($this->isSection('Detailed map of segments')) {
          $this->processDetailedMapOfSectionsSection();
        } elseif ($this->isSection('Address ')) {
          $this->processAddressSection();
        } elseif ($this->isSection('Line numbers for ')) {
          $this->processLineNumbersSection();
        } else {
          // Skip unknown section
          $this->gotoNextSection();
        }
      } // .else
    } // .while
  } // .function processSections

  protected function processStartSection () {
    empty($this->peSections) or $this->fail("Duplicate start section");
    $this->gotoNextLine();

    while (!$this->eof() && $this->isDataLine()) {
      $cols          = $this->readCols();
      $segmentLength = $this->parseAddr($cols[1]);

      if ($segmentLength > 0) {
        [$segmentId, $segmentAddrStr] = $this->parseComplexField($cols[0]);
        $segmentAddr                  = $this->parseAddr($segmentAddrStr);
        
        $segment = &$this->peSections[$segmentId];
        isset($segment) or $segment = (object) ['addr' => $segmentAddr, 'type' => isset($cols[3]) ? $cols[3] : null, 'size' => $segmentLength];

        // Subsegment, big segment continuation like 0000002:000000106
        if ($segmentAddr > $segment->addr) {
          $segment->size += $segmentLength;
        }
      }

      unset($segment);

      $this->gotoNextLine();
    } // .while

    $this->peSections or $this->fail("Invalid start section without any segments");

    $prevSectionAddr = 0x1000;
    $prevSectionSize = 0;

    foreach ($this->peSections as $section) {
      $section->addr   = $this->alignSectionAddr($prevSectionAddr + $prevSectionSize);
      $prevSectionAddr = $section->addr;
      $prevSectionSize = $section->size;
    }
  } // .function processStartSection

  protected function alignSectionAddr (int $addr): int {
    return (int) (ceil($addr / 0x1000) * 0x1000);
  }

  protected function processDetailedMapOfSectionsSection () {
    $this->gotoNextLine();

    while (!$this->eof() && $this->isDataLine()) {
      $cols       = $this->readCols();
      $moduleName = $this->readIniCol('M', $cols);

      if (isset($moduleName)) {
        $addr = $this->parseComplexAddr($cols[0], $segmentId);
        $addr and $this->addrToLabel["$addr"] = "{$moduleName}:" . ($this->peSections[$segmentId]->type ?? 'MOD');
      }

      $this->gotoNextLine();
    } // .while
  } // .function processDetailedMapOfSectionsSection

  protected function processAddressSection () {
    $this->gotoNextLine();

    while (!$this->eof() && $this->isDataLine()) {
      $cols = $this->readCols();

      if (isset($cols[1])) {
        $addr = $this->parseComplexAddr($cols[0]);
        $addr and $this->addrToLabel["$addr"] = $cols[1];
      }

      $this->gotoNextLine();
    }
  } // .function processAddressSection

  protected function processLineNumbersSection () {
    $sectionName = $this->readSectionName();
    
    if (preg_match('~Line numbers for (?<moduleName>\w++)(?<moduleFileName>\([^)]++\))?~i', $sectionName, $m)) {
      $module    = isset($m['moduleFileName']) ? trim($m['moduleFileName'], '()') : $m['moduleName'];
      isset($this->modules[$module]) or $this->modules[$module] = count($this->modules);
      $moduleInd = $this->modules[$module];

      $this->gotoNextLine();

      while (!$this->eof() && $this->isDataLine()) {
        $cols = $this->readCols();

        for ($i = 0, $k = count($cols); $i < $k; $i += 2) {
          $line = (int) $cols[$i];
          $addr = $this->parseComplexAddr($cols[$i + 1]);
          $addr and $this->lineNumbers["$addr"] = [$moduleInd, $line];
        }

        $this->gotoNextLine();
      } // .while
    } else {
      $this->gotoNextSection();
    } // .else
  } // .function processLineNumbersSection

  protected function writeLabelsSection () {
    ksort($this->addrToLabel, SORT_NUMERIC);
    $this->writeInt(count($this->addrToLabel));

    foreach ($this->addrToLabel as $addr => $label) {
      $this->writeInt($addr);
      $this->writeStr($label);
    }
  }

  protected function writeModulesList () {
    $this->writeInt(count($this->modules));

    foreach ($this->modules as $moduleName => $moduleInd) {
      $this->writeStr($moduleName);
    }
  }

  protected function writeLineNumbersSection () {
    ksort($this->lineNumbers, SORT_NUMERIC);
    $this->writeInt(count($this->lineNumbers));

    foreach ($this->lineNumbers as $addr => [$moduleInd, $line]) {
      $this->writeInt($addr);
      $this->writeInt($moduleInd);
      $this->writeInt($line);
    }
  }

  protected function isSection (string $name = null, bool $precise = false): bool {
    $sectionName = $this->readSectionName();
    return $sectionName !== '' && (!isset($name) || preg_match('~\A' . preg_quote($name, '~') . ($precise ? '\z' : '') . '~i', $sectionName));
  }

  protected function isDataLine (): bool {
    return !$this->isSection();
  }

  protected function gotoNextSection (): bool {
    while ($this->gotoNextLine() && $this->readSectionName() === '') {
      // Next
    }

    return !$this->eof();
  }

  protected function readSectionName (): string {
    $result = $this->lines[$this->line] ?? '';
    return preg_match('~\A[a-zA-Z]~', $result) ? $result : '';
  }

  protected function readIniCol (string $paramName, array $cols): ?string {
    $result       = null;
    $searchPrefix = "{$paramName}=";

    foreach ($cols as $col) {
      if (strpos($col, $searchPrefix) === 0) {
        return substr($col, strlen($searchPrefix));
      }
    }

    return $result;
  } // .function readIniCol

  protected function readCols (): array {
    return preg_split('~ ++~', $this->readLine());
  }

  protected function readLine (): string {
    isset($this->lines[$this->line]) or $this->fail("Map EOF reached");
    return $this->lines[$this->line];
  }

  protected function gotoNextLine (): bool {
    $this->line++;

    while (isset($this->lines[$this->line]) && $this->lines[$this->line] === '') {
      $this->line++;
    }
    
    $result = isset($this->lines[$this->line]);
    $result or $this->line = count($this->lines);

    return $result;
  } // .function gotoNextLine

  protected function eof (): bool {
    return !isset($this->lines[$this->line]);
  }

  /**
   * Returns 0 for invalid segment ID in address.
   * @return int|float
   */
  protected function parseComplexAddr (string $complexAddr, &$segmentId = '') {
    [$segmentId, $segmentOffset] = $this->parseComplexField($complexAddr);
  
    return isset($this->peSections[$segmentId]) ? $this->peSections[$segmentId]->addr + $this->parseAddr($segmentOffset) : 0;
  }

  protected function parseComplexField (string $field, string $subfieldSeparator = ':'): array {
    $result = explode($subfieldSeparator, $field);
    count($result) > 1 or $this->fail("Field '$field' is not a valid complex field with '$subfieldSeparator' subfield separator");

    return $result;
  }

  protected function writeStr (string $value): self {
    $this->result .= $this->toBinInt(strlen($value));
    $this->result .= $value;

    return $this;
  }

  protected function writeInt ($value): self {
    $this->result .= $this->toBinInt($value);

    return $this;
  }

  protected function toBinInt ($value): string {
    $value = +$value;
    
    if (PHP_INT_SIZE > 4 || ($value >= 0 && $value <= 2147483647)) {
      $value = (int) $value;
    } else {
      $value = (int) (4294967296 + $value);
    }

    return pack('V', $value);
  }

  /**
   * @return int|float
   */
  protected function parseAddr (string $addr) {
    $result = hexdec(rtrim($addr, 'H'));
    $result < 0 and $result += 4294967296;

    return $result ?: 0;
  }

  protected function fail (string $message = ''): void {
    \fail("{$message}. Error on line " . ($this->line + 1));
  }
} // .class MapCompiler
