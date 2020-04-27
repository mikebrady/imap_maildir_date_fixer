#!/bin/sh

# MIT License

# Copyright (c) 2020 Mike Brady <mikebradydublin@icloud.com>

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# The function process_mail_file is executed on each file within the 'cur' directory.
# In the 'cur' directory's parent directory, the files "dovecot.index*" and "dovecot.list*" are deleted.

process_mail_file () {

	# Layouts -- first looks for the first occurence of "   for <email-address>; <Date and Time>"
	# Layouts -- second looks for the first occurence of "Date: <Date and Time>"

	# echo "File is \"$1\""
	D=""
	D=`grep -m 1  " *for *<.*>; " "$1"`
	if [ $? -eq 0 ] ; then
        	D=`echo $D | cut -d \; -f 2-`
        	D=${D#" "}
                # echo "Found type 1: \"$D\""

	else
        	D=`grep -m 1 "^Date: " "$1" | cut -d : -f 2-`
        	D=${D#" "}
		# echo "Found type 2: \"$D\""
	fi

	# Parse three different date formats
	if [ "x$D" != "x" ] ; then
               	# echo "touch -c -m -d \"$D\" \"$1\""
                touch -c -m -d "$D" "$1"
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
# The function process_mail_file is executed on each file within the 'cur' directory.
# In the 'cur' directory's parent directory, the files "dovecot.index*" and "dovecot.list*" are deleted.

os=$(uname | tr '[:upper:]' '[:lower:]')
case $os in
  linux)
	echo "Operating System \"$os\" recognised."
	find "$1" -type d -name cur -print | while read line ; do
		process_cur_directory "$line"
	done
	;;
  *)
	echo "Unsupported operating system: \"$os\". Nothing done."
	;;
esac

