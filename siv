#!/bin/bash

# check parameters
while [[ $# -gt 0 ]]; do
  case $1 in
    -h)
      echo "Usage: siv [OPTION]... FILE"
      echo "shell image viewer"
      echo
      echo "  -c <COLORS>  Set the amount of colors."
      echo "                 possible values: 8, 256"
      echo "  -h           Display this help message."
      echo "  -s <SIZE>    Set the destination size."
      echo "                 possible values: <WIDTH>, <WIDTH>x<HEIGHT>"
      echo "                 default is the terminal size"
      echo "  -v           Display the version on siv."
      exit 0;;
    -v)
      echo "siv 0.2"
      echo "Copyright (C) 2010  Andreas Schönfelder"
      exit 0;;
    -s)
      shift
      size=$1;;
    -c)
      shift
      if [[ $1 != 8 && $1 != 256 ]]; then
        echo "'$1' colors not supported"
        exit 1
      fi
      colors=$1;;
    -*)
      echo "siv: unrecognized option '$1'"
      echo "Usage: siv [OPTIONS] FILE"
      echo "Try 'siv -h' for more information."
      exit 1;;
    *)
      if [[ ! -f "$1" ]]; then
        echo "'$1' is not a file"
        exit 1;
      fi
      file=$1;;
  esac
  shift
done

# set default values
[[ -z "$file" ]] && echo "no file set" && exit 1
[[ -z "$size" ]] && size=$(/bin/stty size | sed "s|\(\w*\) \(\w*\)|\2x\1|")
[[ -z "$colors" ]] && colors=256
case "$colors" in
  256)
    devideby=51;;
  8)
    devideby=128;;
esac

# convert image
i=1
x=1
i_line=1
old="$IFS"
IFS=$'\n'
for line in $(convert -compress none -depth 8 -filter box -resize "$size" "$file" ppm:-); do
  IFS="$old"

  # size
  [[ $i_line == 2 ]] && width=$(($(echo $line | cut -d" " -f1)+1))

  # jump header
  if [[ $i_line < 4 ]]; then
    i_line=$((i_line+1))
    continue
  fi

  # show image
  for value in $line; do
    case "$i" in
      1)
        r=$((value/devideby));;
      2)
        g=$((value/devideby));;
      3)
        b=$((value/devideby))
        case "$colors" in
          256)
            echo -en "\e[48;5;$((16+r*36+g*6+b))m \e[0m";;
          8)
            case "$r$g$b" in
              000)  # black
                echo -en "\e[40m \e[0m";;
              100)  # red
                echo -en "\e[41m \e[0m";;
              010)  # green
                echo -en "\e[42m \e[0m";;
              110)  # yellow
                echo -en "\e[43m \e[0m";;
              001)  # blue
                echo -en "\e[44m \e[0m";;
              101)  # purple
                echo -en "\e[45m \e[0m";;
              011)  # cyan
                echo -en "\e[46m \e[0m";;
              111)  # white
                echo -en "\e[47m \e[0m";;
            esac;;
        esac;;
    esac

    # next pixel
    if [[ $i == 3 ]]; then
      i=1
      x=$((x+1))
    else
      i=$((i+1))
    fi

    # next line
    [[ $x == $width ]] && echo && x=1
  done
done
