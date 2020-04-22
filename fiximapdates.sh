#!/bin/sh

# The function process_mail_file is executed on each file within the 'cur' directory.
# In the 'cur' directory's parent directory, the files "dovecot.index*" and "dovecot.list*" are deleted.

process_mail_file () {

	# Layouts -- first looks for the first occurence of "   for <email-address>; <Date and Time>"
	# Layouts -- second looks for the first occurence of "Date: <Date and Time>"

	# echo "File is \"$1\""
	D=`/usr/bin/grep -m 1  " *for *<.*>; " "$1"`
	if [ $? -eq 0 ] ; then
        	D=`echo $D | cut -d \; -f 2-`
        	D=${D#" "}
	else
        	D=`/usr/bin/grep -m 1 "^Date: " "$1" | cut -d : -f 2-`
        	D=${D#" "}
	fi

	# Parse three different date formats
	if [ "x$D" != "x" ] ; then
        	CD=`date -j -f " %a, %d %b %Y %T %z" "$D" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null`
        	if [ $? -ne 0 ] ; then
        		CD=`date -j -f " %a, %d %b %Y %T %Z" "$D" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null`
        		if [ $? -ne 0 ] ; then
                		CD=`date -j -f " %d %b %Y %T %z" "$D" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null`
        		fi
        	fi
        	if [ $? -eq 0 ] ; then
                	# echo "    File $1 has date $CD derived from \"$D\""
                	/usr/bin/touch -md $CD "$1"
                	# echo "/usr/bin/touch -md $CD '$1'"
        	else
                	echo "    File $1 -- can't translate date \"$D\"."
        	fi
	else
        	echo "    File \"$1\" -- can't find a date in it."
	fi
}

process_cur_directory() {

	PD="${1%/*}"
	echo "Processing \"$PD\""
	C=`(find "$1" -type f -print | grep -c '.*' ) # 2>/dev/null`
	if [ $C -ne 0 ] ; then
        	echo "    Updating $C mail files in \"$PD\"..."
        	#find "$1" -type f -exec /root/redate_mail_file.sh {} \; # > /dev/null 2>&1
		find "$1" -type f -maxdepth 1 -print | nl -s \| | while read line ; do
        		LN=`echo $line | cut -d \| -f 1`
        		FP=`echo $line | cut -d \| -f 2-`
        		process_mail_file "$FP"
			progress=$(($LN % 10))
			if [ "$progress" -eq "0" ] ; then
				printf "Files checked: $LN\r"
			fi
		done
        	# echo "    Removing index files."
        	rm "$PD/dovecot.index*" "$PD/dovecot.list*" > /dev/null 2>&1
	fi
}


# Recursively traverse a dovecot maildir directory structure looking for directories called 'cur'
# The script redate_mail_file.sh is executed on each file within the 'cur' directory.
# In the 'cur' directory's parent directory, the files "dovecot.index*" and "dovecot.list*" are deleted.

find "$1" -type d -name cur -print | while read line ; do
	process_cur_directory "$line"
done

