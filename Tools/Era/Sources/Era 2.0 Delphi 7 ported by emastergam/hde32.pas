(*
 *  Hacker Disassembler Engine 32
 *  Copyright (c) 2006-2008, Veacheslav Patkov
 *  aLL rights reserved.
 *
 *  hde32.pas : pascal header file (Free Pascal, Delphi)
 *
 *)

unit hde32;

interface
uses windows;

type
  TDisasm = packed record
    len        : byte;     { length of command                             }
    p_rep      : byte;     { rep/repz (0xf3) & repnz (0xf2) prefix         }
    p_lock     : byte;     { lock prefix: 0xf0                             }
    p_seg      : byte;     { segment prefix: 0x2e,0x36,0x3e,0x26,0x64,0x65 }
    p_66       : byte;     { operand-size override prefix: 0x66            }
    p_67       : byte;     { address-size override prefix: 0x67            }
    opcode     : byte;     { opcode                                        }
    opcode2    : byte;     { second opcode (if first opcode is 0x0f)       }
    modrm      : byte;     { ModR/M byte                                   }
    modrm_mod  : byte;     {   mod field of ModR/M                         }
    modrm_reg  : byte;     {   reg field of ModR/M                         }
    modrm_rm   : byte;     {   r/m field of ModR/M                         }
    sib        : byte;     { SIB byte                                      }
    sib_scale  : byte;     {   scale field of SIB                          }
    sib_index  : byte;     {   index field of SIB                          }
    sib_base   : byte;     {   base field of SIB                           }
    imm8       : byte;     { immediate value imm8                          }
    imm16      : word;     { immediate value imm16                         }
    imm32      : dword;    { immediate value imm32                         }
    disp8      : byte;     { displacement disp8                            }
    disp16     : word;     { displacement disp16                           }
    disp32     : dword;    { displacement disp32                           }
    rel8       : byte;     { relative address rel8                         }
    rel16      : word;     { relative address rel16                        }
    rel32      : dword;    { relative address rel32                        }
  end;

function hde32_disasm(code: pointer; var hs: TDisasm): dword; cdecl;

implementation

{$LINK 'hde32.obj'}

function hde32_disasm(code: pointer; var hs: TDisasm): dword; cdecl; external;

end.
