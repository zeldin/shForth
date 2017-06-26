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
  x=\\
  while test ! -z "$1"; do
    cmd="$1"
    if test "`eval \"$cmd\"; eval \"$cmd\"`" = \\\\; then
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

if [ "$((15 + 17))" = 32 ]; then
  expr_define='builtin_expr()
{
  tmp=$(($@))
  echo "$tmp"
  if [ "$tmp" = 0 ]; then
    return 1
  else
    return 0
  fi
}'
  expr="builtin_expr"
  echo >&2 'use builtin expr based on $(())'
else
  expr_define=""
  find_path expr /usr/bin
fi
find_path dd /bin
find_path od /usr/bin
find_path sed /bin

chk_nocr 'echo "$x\c"' '/bin/echo -n "$x"' '/usr/bin/echo -n "$x"' 'echo -n "$x"' 'printf "%s" "$x"'

if type typeset 2>&1 >/dev/null; then
  typeset_f="typeset -f"
else
  typeset_f="set"
fi
echo >&2 "use '$typeset_f' to show functions"

foo="'"
if test `set|grep '^foo='|wc -c` -eq 6; then
  set_output=raw
  echo >&2 "set prints raw values of variables"
else
  set_output=cooked
  echo >&2 "set prints cooked values of variables"
fi

echo >&2 "Creating ${srcdir}config.sh"

cat > "${srcdir}config.sh" <<EOF
#! /bin/sh

# This file was automatically generated with  $0 $@

$expr_define

expr="$expr"
dd="$dd"
od="$od"
sed="$sed"

echo_nocr='$echo_nocr'

typeset_f="$typeset_f"
set_output="$set_output"
EOF

echo >&2 "configuration completed."
exit 0

