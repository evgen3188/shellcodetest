#!/bin/bash

set -e

[[ $# < 2 ]] && echo "Usage: `basename $0` [asm file] [c file]" && exit 1

objfile=$(echo `basename $1` | sed 's/asm/o/')
outfile=$(echo `basename $1` | sed 's/asm/out/')
tmpfile=$(date +%s).tmp

nasm -f elf -o $objfile $1
ld -m elf_i386 -o $outfile $objfile

offset="0x"$(readelf -S $outfile | grep .text | awk '{print $6}')
size=$(size -A -d $outfile | grep .text | awk '{print $2}')
echo "Size of section: $size"
hex=$(hexdump -v -s $offset -n $size -e '"\\\\""x" 1/1 "%02x"' $outfile)
sed -i "s@\(^char code[^\"]*\)\"\(.*\)\"@\1\"$hex\"@" $2 # > $tmpfile

#rm $2
#mv $tmpfile $2

cc -m32 -fno-stack-protector -z execstack $2

