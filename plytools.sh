#!/bin/bash

usage()
{
    echo "Usage:"
    echo "  plytools.sh [tool] file1.ply [file2.ply ...]"
    echo
    echo "Tools:"
    echo "  --help|h"
    echo "  --header|H"
    echo "  --verts|v"
    echo "  --coords|p"
    echo "  --colors|c"
    echo "  --tris|t"
    echo "  --getcolors|g"
}

header() {
    awk '{print $0}$1=="end_header"{exit 1}' "$1"
}

verts() {
    awk '
        BEGIN{s=0}
        $1=="element"&&$2=="vertex"{nverts=$3}
        s==1&&NR<=(nhdr+nverts){print $0}
        $1=="end_header"{s=1;nhdr=NR}' "$1"
}

tris() {
    awk '
        BEGIN{s=0}
        $1=="element"&&$2=="vertex"{nverts=$3}
        $1=="element"&&$2=="face"{nfaces=$3}
        s==1&&NR>(nhdr+nverts)&&NR<=(nhdr+nverts+nfaces){print $0}
        $1=="end_header"{s=1;nhdr=NR}' "$1"
}

coords() {
    awk '
        BEGIN{s=0}
        $1=="element"&&$2=="vertex"{nverts=$3}
        s==1&&NR<=(nhdr+nverts){print $1,$2,$3}
        $1=="end_header"{s=1;nhdr=NR}' "$1"
}

colors() {
    awk '
        BEGIN{s=0}
        $1=="element"&&$2=="vertex"{nverts=$3}
        s==1&&NR<=(nhdr+nverts){print $4,$5,$6}
        $1=="end_header"{s=1;nhdr=NR}' "$1"
}

getverts() {
    # get vertices from the second mesh, put them in first one
    awk '
        BEGIN{s=0;i=0}
        $1=="element"&&$2=="vertex"{nverts=$3}
        s==1&&FNR==NR&&NR<=(nhdr+nverts){v[i]=$1" "$2" "$3;i=i+1}
        FNR==1&&NR>FNR{s=0}
        NR>FNR{if(s==0||FNR>nhdr+nverts)print $0;else print v[FNR-nhdr-1],$4,$5,$6,$7}
        $1=="end_header"{s=1;nhdr=FNR}' "$2" "$1"
}

if [ $# -lt 2 ]; then
    usage
else
    while [ "$1" != "" ]; do
        case $1 in
            -H | --header )
                header "$2"
                shift
                ;;
            -v | --verts )
                verts "$2"
                shift
                ;;
            -t | --tris )
                tris "$2"
                shift
                ;;
            -p | --coords )
                coords "$2"
                shift
                ;;
            -c | --colors )
                colors "$2"
                shift
                ;;
            -g | --getverts )
                getverts "$2" "$3"
                shift
                shift
                ;;
            -h | --help )
                usage
                exit
                ;;
        esac
        shift
    done
fi
