<?php
declare(strict_types=1);

use B\{B};
use B\CompKit\ParseTree\Token;
use B\Erm\Lexer;

class ScriptCompiler {
  /**
   * @var bool SKIP_INCLUDING
   */
  protected const SKIP_INCLUDING = true;

  /**
   * @var Lexer $lexer
   */
  protected $lexer;

  /**
   * @var Token[] $tokens
   */
  protected $tokens;

  /**
   * @var string[] $namedFuncs
   */
  protected $namedFuncs;

  /**
   * @var bool $replaceWogFuncs
   */
  protected $replaceWogFuncs;

  /**
   * @var string $funcsPrefix
   */
  protected $funcsPrefix;

  /**
   * @var int $pos
   */
  protected $pos;

  /**
   * @var int $numTokens
   */
  protected $numTokens;

  /**
   * @var bool $isTrigger
   */
  protected $isTrigger;

  /**
   * @var int[] $cmdOffsets
   */
  protected $cmdOffsets;

  /**
   * @var int[] $cmdJumps
   */
  protected $cmdJumps;

  /**
   * @var string $warnings
   */
  protected $warnings;

  /**
   * @var string $prevOutput
   */
  protected $prevOutput;

  /**
   * @var string $output
   */
  protected $output;

  public function __construct (string $script, array $opts = []) {
    $opts = B::getOpts($opts, [
      'namedFuncs'      => ['def' => [],    'type' => 'array'],
      'replaceWogFuncs' => ['def' => false, 'type' => 'bool'],
      'funcsPrefix'     => ['def' => '',    'type' => 'string'],
    ]);
    
    $this->namedFuncs      = $opts['namedFuncs'];
    $this->replaceWogFuncs = $opts['replaceWogFuncs'];
    $this->funcsPrefix     = $opts['funcsPrefix'];

    $this->lexer = new Lexer($script);
    $this->parseScript();
  } // .function __construct

  protected function parseScript (): void {
    $this->tokens = $this->lexer->getTokens();
  }

  protected function prepareForCompilation () {
    $this->pos        = 0;
    $this->numTokens  = count($this->tokens);
    $this->isTrigger  = false;
    $this->cmdOffsets = [];
    $this->cmdJumps   = [];
    $this->warnings   = '';
    $this->prevOutput = '';
    $this->output     = '';
  } // .function prepareForCompilation

  public function compile (&$customNamedFuncs, &$warnings): string {
    $this->prepareForCompilation();

    while ($token = $this->getToken()) {
      if ($token->type === 'trigger') {
        $this->parseTriggerHeader();
      } elseif ($token->type === 'receiver' || $token->type === 'instr') {
        $this->parseReceiver($token->type === 'instr');
      } elseif (in_array($token->type, ['if', 'else', 'end'], true)) {
        $this->cmdOffsets[] = strlen($this->output);
        $this->skipToken();
      } else {
        $this->skipToken();
      }
    } // .while

    $this->isTrigger and $this->endTrigger();

    // Ensure, that file is valid ERM file format
    $this->output .= $this->output !== '' && $this->output[-1] === "\n" ? "\r" : "\n\r";

    $customNamedFuncs = $this->namedFuncs;
    $warnings         = $this->warnings;
    ksort($customNamedFuncs);

    return $this->output;
  } // .function compile

  protected function getToken (): ?Token {
    return $this->tokens[$this->pos] ?? null;
  }

  protected function getTokenAtRel (int $relPos): ?Token {
    return $this->tokens[$this->pos + $relPos] ?? null;
  }

  protected function getTokenType (): string {
    return $this->tokens[$this->pos]->type ?? '';
  }

  protected function getTokenValue () {
    return $this->tokens[$this->pos]->value ?? null;
  }

  protected function gotoNextToken (): bool {
    $this->pos++;
    $this->pos > $this->numTokens and $this->pos = $this->numTokens;

    return $this->pos < $this->numTokens;
  }

  protected function parseTriggerHeader (): void {
    $this->isTrigger and $this->endTrigger();

    $this->prevOutput = $this->output;
    $this->output     =  '';
    
    $this->isTrigger  = true;
    $this->cmdN       = 0;
    $this->cmdOffsets = [];
    $this->cmdJumps   = [];

    $trigger = $this->getTokenValue();

    if ($trigger === 'FU' && $this->skipToken() && $this->getTokenType() === 'int') {
      $this->output .= $this->getFuncName($this->getTokenValue());
      $this->gotoNextToken();
    } elseif ($convertTriggerNames = false && false) {
      $nextToken        = $this->getTokenAtRel(+1);
      $isComplexTrigger = isset($nextToken) && $nextToken->type === 'int';
      $isComplexTrigger and $trigger .= $nextToken->code;
      $triggerName      = $this->getTriggerName($trigger);

      if (isset($triggerName)) {
        $this->output .= "!?FU({$triggerName})";
        $this->gotoNextToken();
        $isComplexTrigger and $this->gotoNextToken();
      }
    } // .else

    $this->skipUntil('comment', self::SKIP_INCLUDING);
  } // .function parseTriggerHeader

  protected function endTrigger (): void {
    if (!$this->cmdJumps) {
      $this->prevOutput .= $this->output;
    } else {
      $labels = [];
      $buf    = '';

      $jumpAddrs = array_values(array_unique(array_values($this->cmdJumps)));
      sort($jumpAddrs);

      foreach ($jumpAddrs as $i => $addr) {
        $labels[$addr] = ['id' => $i + 1, 'offset' => $this->cmdOffsets[$addr] ?? strlen($this->output)];
      }

      $breakpoints = [];

      foreach ($this->cmdJumps as $offset => $addr) {
        $breakpoints[] = ['value' => "[L_{$labels[$addr]['id']}]", 'offset' => $offset];
      }

      foreach ($labels as $label) {
        $breakpoints[] = ['value' => "[:L_{$label['id']}]\n", 'offset' => $label['offset']];
      }

      usort($breakpoints, function ($a, $b) { return $a['offset'] - $b['offset']; });

      $startOffset = 0;

      foreach ($breakpoints as $breakpoint) {
        $buf         .= substr($this->output, $startOffset, $breakpoint['offset'] - $startOffset);
        $buf         .= $breakpoint['value'];
        $startOffset = $breakpoint['offset'];
      }

      $buf              .= substr($this->output, $startOffset, strlen($this->output) - $startOffset);
      $this->prevOutput .= $buf;
    } // .else

    $this->output     =  $this->prevOutput;
    $this->prevOutput = '';
  } // .function endTrigger

  protected function parseReceiver (bool $isInstruction): void {
    $isInstruction or $this->cmdOffsets[] = strlen($this->output);
    $token = $this->getToken();
    $cmd   = $token->value;

    if ($cmd === 'FU' || $cmd === 'DO') {
      if ($this->skipToken() && $this->getTokenType() === 'int') {
        $this->output .= "{$this->getFuncName($this->getTokenValue())}";
        $this->gotoNextToken();
      }
    } elseif ($cmd === 'SN' && !$isInstruction) {
      $this->skipToken();

      while (($token = $this->getToken()) && $token->type !== 'comment') {
        if ($token->type === 'cmd' && $token->value === 'G') {
          $this->skipToken();

          if ($this->getTokenType() === 'int') {
            $this->cmdJumps[strlen($this->output)] = $this->getTokenValue();
            $this->gotoNextToken();
          }
        } else {
          $this->skipToken();
        }
      } // .while
    } // .elseif

    $this->skipUntil('comment', self::SKIP_INCLUDING);
    $isInstruction or $this->cmdN++;
  } // .function parseReceiver

  protected function writeToken (): void {
    $token = $this->tokens[$this->pos];

    if ($token->type === 'int' && isset($this->namedFuncs[$token->value])) {
      $posInfo        = $this->lexer->decodePos($token->pos);
      $warning        = "{!} Possible function {$this->getFuncName((int) $token->value)} = {$token->value} on line {$posInfo->line} at pos {$posInfo->linePos}\r\n";
      $this->warnings .= $warning;
      print($warning);
    }

    $this->output .= $token->code;
  } // .function writeToken

  protected function skipToken (): bool {
    $this->writeToken();

    return $this->gotoNextToken();
  }

  protected function skipUntil (string $tokenType, bool $skipIncluding = false): bool {
    while (($token = $this->getToken()) && $token->type !== $tokenType) {
      $this->writeToken();
      $this->gotoNextToken();
    }

    $result = $this->getToken() !== null;
    $result && $skipIncluding and $this->skipToken();

    return $result;
  }

  protected function getFuncName (int $funcId): string {
    if (!isset($this->namedFuncs[$funcId])) {
      // Default WoG functions without given fixed name
      if (!$this->replaceWogFuncs && $funcId >= 1 && $funcId <= 30000) {
        return (string) $funcId;
      } else {
        $this->namedFuncs[$funcId] = "{$this->funcsPrefix}{$funcId}_F";
      }
    }

    return "({$this->namedFuncs[$funcId]})";
  } // .function getFuncName

  protected function getTriggerName (string $trigger): ?string {
    $translateMap = [
      "BA0"  => "OnBeforeBattle",
      "BA1"  => "OnAfterBattle",
      "BR"   => "OnBattleRound",
      "BG0"  => "OnBeforeBattleAction",
      "BG1"  => "OnAfterBattleAction",
      "MW0"  => "OnWanderingMonsterReach",
      "MW1"  => "OnWanderingMonsterDeath",
      "MR0"  => "OnMagicBasicResistance",
      "MR1"  => "OnMagicCorrectedResistance",
      "MR2"  => "OnDwarfMagicResistance",
      "CM0"  => "OnAdventureMapRightMouseClick",
      "CM1"  => "OnTownMouseClick",
      "CM2"  => "OnHeroScreenMouseClick",
      "CM3"  => "OnHeroesMeetScreenMouseClick",
      "CM4"  => "OnBattleScreenMouseClick",
      "AE0"  => "OnAdventureMapLeftMouseClick",
      "AE1"  => "OnEquipArt",
      "MM0"  => "OnUnequipArt",
      "MM1"  => "OnBattleMouseHint",
      "CM5"  => "OnTownMouseHint",
      "MP"   => "OnMp3MusicChange",
      "SN"   => "OnSoundPlay",
      "MG0"  => "OnBeforeAdventureMagic",
      "MG1"  => "OnAfterAdventureMagic",
      "TH0"  => "OnEnterTown",
      "TH1"  => "OnLeaveTown",
      "IP0"  => "OnBeforeBattleBeforeDataSend",
      "IP1"  => "OnBeforeBattleAfterDataReceived",
      "IP2"  => "OnAfterBattleBeforeDataSend",
      "IP3"  => "OnAfterBattleAfterDataReceived",
      "CO0"  => "OnOpenCommanderWindow",
      "CO1"  => "OnCloseCommanderWindow",
      "CO2"  => "OnAfterCommanderBuy",
      "CO3"  => "OnAfterCommanderResurrect",
      "BA50" => "OnBeforeBattleForThisPcDefender",
      "BA51" => "OnAfterBattleForThisPcDefender",
      "BA52" => "OnBeforeBattleUniversal",
      "BA53" => "OnAfterBattleUniversal",
      "GM0"  => "OnAfterLoadGame",
      "GM1"  => "OnBeforeSaveGame",
      "PI"   => "OnAfterErmInstructions",
      "DL"   => "OnCustomDialogEvent",
      "HM-1" => "OnHeroMove",
      "HL-1" => "OnHeroGainLevel",
      "BF"   => "OnSetupBattlefield",
      "MF1"  => "OnMonsterPhysicalDamage",
      "TL0"  => "OnEverySecond",
      "TL1"  => "OnEvery2Seconds",
      "TL2"  => "OnEvery5Seconds",
      "TL3"  => "OnEvery10Seconds",
      "TL4"  => "OnEveryMinute",
    ];

    return $translateMap[$trigger] ?? null;
  } // .function getTriggerName
} // .class ScriptCompiler
