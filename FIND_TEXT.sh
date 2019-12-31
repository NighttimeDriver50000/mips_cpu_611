#!/bin/sh
find_text() {
    find . -type f \
        ! -path './db/*' \
        ! -path './greybox_tmp/*' \
        ! -path './incremental_db/*' \
        ! -path './simulation/*' \
        ! -name '*conflicted copy*' \
        ! -name '*Case Conflict*' \
        ! -name '*.attr' \
        ! -name '*.bak' \
        ! -name '*.logdb' \
        ! -name '*.rpt' \
        ! -name '*.sdo' \
        ! -name '*.summary' \
        ! -name '*.vo' \
        -exec grep -Iq . {} \; -print \
        | sort
}
#find_text
#find_text \
#    | sed -E 's/^.*\.([^.]+)$/\1/' \
#    | sort \
#    | uniq -c \
#    | sort -n
find . -type f \
    \(  ! -path './db/*' \
        ! -path './greybox_tmp/*' \
        ! -path './incremental_db/*' \
        ! -path './simulation/*' \
        ! -name '*conflicted copy*' \
        ! -name '*Case Conflict*' \) \
    \(  -name '*.v' \
    -or -name '*.v.old' \
    -or -name '*.txt' \
    -or -name '*.text' \
    -or -name '*.asm' \
    -or -name '*.do' \
    -or -name '*.tv' \
    -or -name '*.sh' \
    -or -name '*.mif' \) \
    -exec grep -Iq . {} \; -print \
    | sort
