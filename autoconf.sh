#! /bin/sh

IFS="${IFS= 	}"

find_path() {
  save_ifs="$IFS"
  IFS=":"
  for dir in $2:$PATH; do
    test -z "$dir" && dir=.
    case x"$dir" in
      x/*) ;;
      *) dir="`pwd`/$dir";;
    esac
    if test -x "$dir/$1"; then
      IFS="$save_ifs"
      eval "$1=\$dir/$1"
      echo >&2 "$1 is $dir/$1"
      return
    fi
  done
  IFS="$save_ifs"
  echo >&2 "Fatal:  Can't find $1 in path!"
  exit 1
}

chk_nocr() {
  x="."
  while test ! -z "$1"; do
    cmd="$1"
    if test "`eval \"$cmd\"; eval \"$cmd\"`" = ..; then
      cat >&2 <<EOF
use '$cmd' to echo without linebreak
EOF
      echo_nocr="$cmd"
      return
    fi
    shift
  done
  echo >&2 "Fatal:  Can't figure out how to echo without linebreak!"
  exit 1
}

find_path expr /usr/bin
find_path dd /bin
find_path od /usr/bin
find_path sed /bin

chk_nocr 'echo "$x\c"' '/bin/echo -n "$x"' '/usr/bin/echo -n "$x"' 'echo -n "$x"'

echo >&2 "Creating ${srcdir}config.sh"

cat > "${srcdir}config.sh" <<EOF
#! /bin/sh

# This file was automatically generated with  $0 $@

expr="$expr"
dd="$dd"
od="$od"
sed="$sed"

echo_nocr='$echo_nocr'
EOF

echo >&2 "configuration completed."
exit 0

