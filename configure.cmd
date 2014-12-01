extproc sh

# convert backslashes of PATH to slashes
OLD_IFS="$IFS"
IFS="\\"
TEMP_PATH=
for dir in $PATH; do
    if test -z "$TEMP_PATH"; then
        TEMP_PATH="$dir"
    else
        TEMP_PATH="$TEMP_PATH/$dir"
    fi
done
PATH="$TEMP_PATH"
unset TEMP_PATH
IFS="$OLD_IFS"
unset OLD_IFS

export PATH

export COMSPEC=/bin/sh

./Configure -des -Dprefix=/perl5
