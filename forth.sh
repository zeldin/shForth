#! /bin/sh

if test -h "$0"; then
  echo >&2 "Hum.  $0 is a symlink.  This will probably not work..."
fi

case "x$0" in
  x/*) srcdir="" ;;
  *) srcdir="`pwd`/";;
esac
srcdir="`echo \"$srcdir$0\"x | sed -e 's:/[^/]*$:/:'`"

if test ! -f "${srcdir}core.sh"; then
  echo >&2 "Can't find files.  Bailing out."
  exit 1
fi

if test x--configure = x"$1"; then
  . "${srcdir}autoconf.sh"
fi

if test ! -f "${srcdir}config.sh"; then
  echo >&2 "shForth not configured!  Run '$0 --configure'."
  exit 1
fi

. "${srcdir}config.sh"
. "${srcdir}memory.sh"
. "${srcdir}io.sh"
. "${srcdir}interpreter.sh"
. "${srcdir}core.sh"
. "${srcdir}coreext.sh"

ip="$quit"

if test x--dump = x"$1"; then
  "$sed" -ne '1p' < "$0" > "${srcdir}forth"
  set | "$sed" -ne '/^[_a-z]* *(/,/^}/p' >> "${srcdir}forth"
  set | "$sed" -e '/^[_a-z]* *(/,/^}/d' -e '/^[^a-z]/d' -e "s/'/'\"'\"'/" -e 's/^\([^ =]*=\)\(.*\)$/\1'"'\\2'"'/' >> "${srcdir}forth"
  "$sed" -e '1,/^# dump/d' < "$0" >> "${srcdir}forth"
  chmod a+x "${srcdir}forth"
  echo >&2 "Created ${srcdir}forth."
  exit 0
fi

# dumped stuff goes here

echo "shForth ready."
run
