OUTPUT_ARCH("riscv")
ENTRY(test)
 
MEMORY
{
  flash (rxai!w) : ORIGIN = 0x00400000, LENGTH = 64K
  ram (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 128K
}
 
PHDRS
{
  flash PT_LOAD;
  ram_init PT_LOAD;
  ram PT_NULL;
}
 
SECTIONS
{
  .text           :
  {
    *(.text .text.*)
  } >flash AT>flash :flash
 
  .data          :
  {
    *(.data .data.*)
    . = ALIGN(8);
  } >ram AT>ram :ram_init
}
