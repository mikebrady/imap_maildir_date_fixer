# IMAP Maildir Date Fixer
This is a shell script to fix up date problems with `IMAP` mail repositories maintained by `Dovecot` email servers that use the `Maildir` format. There are separate versions for FreeBSD and Linux -- the `date` and `touch` commands are quite different in the two systems.

# The Problem
Some mail clients, such as macOS Mail and Microsoft Outlook for Macintosh, display incorrect dates for mail messages stored on a `Dovecot` `IMAP` mail server that uses the `Maildir` format to store emails.

The reason for the incorrect dates is that the clients do not look at a mail's reception or transmission date – instead, they use the modification date of the file containing the mail. If the modification date is different to the reception or transmission date, then the mail is tagged with the wrong date.

The modification date can inadventently be changed if, for example, the mail repository is copied without preserving the modification date.

# The Solution
The solution sounds pretty simple: extract each email's actual date from its mail headers and use this to reset the file's modification date. That's just what this script does. But there's a little more to it:
1. The script recursively crawls the directory you specify looking for all directories with the name `cur`.
2. For each `cur` directory, it treats all the files in it at files containing emails, extracts a date from each one and sets the file's modification date to that.
3. It deletes the `dovecot.index`, `dovecot.index.cache`, `dovecot.list.index` files from the `cur` directory's parent directory. This causes the mail system to rebuild them using the now-updated file modification dates, thus fixing the problem on the server.

# Solving the Problem

Before you begin, make sure the script is executable, e.g. on FreeBSD by doing:
```
$ chmod 755 fiximapdates_bsd.sh
```

1. Run the script in supervisor mode, giving it the parent directory as an argument – see below for some examples.
2. Restart `dovecot` to make it use the updated information.

In the following example, the mail server is set up to use Virtual Users, and all email is stored in `/var/mail/vhosts`. Individual domains are further in, and individual users are further in again. For example, to fix up the dates for user `joe` in the domain `domain.com`:

```
# ./fiximapdates_bsd.sh /var/mail/vhosts/domain.com/joe
```
This will trawl through all the mail in all the `cur` directories belonging to the user `joe@domain.com` on a FreeBSD system. It does not look in the `new` or `tmp` directories. It gives an indication of progress when updating a directory of mail files.

```
# ./fiximapdates_linux.sh /var/mail/vhosts/domain.com/
```
This will trawl through all the mail of all users with email accounts on this server for `domain.com` on a Linux system.
```
# ./fiximapdates_linux.sh /var/mail/vhosts
```
This will trawl through all the mail of all users with email accounts on a Linux server.
# Using the Script
Here is the start of a log of a session with `fiximapdates_bsd.sh` traversing a 30 GB Maildir repository. The last line is a progress indicator.

```
# ./fiximapdates_bsd.sh /var/mail/vhosts/domain.com
Processing "/var/mail/vhosts/domain.com/administrator/.Apple Mail To Do"
Processing "/var/mail/vhosts/domain.com/administrator/.Archive"
Processing "/var/mail/vhosts/domain.com/administrator/.Deleted Messages (Administrator@Home)"
    Updating 13 mail files in "/var/mail/vhosts/domain.com/administrator/.Deleted Messages (Administrator@Home)"...
Processing "/var/mail/vhosts/domain.com/administrator/.Deleted Messages"
    Updating 7 mail files in "/var/mail/vhosts/domain.com/administrator/.Deleted Messages"...
Processing "/var/mail/vhosts/domain.com/administrator/.Drafts"
Processing "/var/mail/vhosts/domain.com/administrator/.Fan Mail"
    Updating 5681 mail files in "/var/mail/vhosts/domain.com/administrator/.Fan Mail"...
Processing "/var/mail/vhosts/domain.com/administrator/.Junk"
    Updating 2 mail files in "/var/mail/vhosts/domain.com/administrator/.Junk"...
Processing "/var/mail/vhosts/domain.com/administrator/.Liz's Stuff"
    Updating 90 mail files in "/var/mail/vhosts/domain.com/administrator/.Liz's Stuff"...
Processing "/var/mail/vhosts/domain.com/administrator/.Notes"
Processing "/var/mail/vhosts/domain.com/administrator/.Sent Messages"
    Updating 41 mail files in "/var/mail/vhosts/domain.com/administrator/.Sent Messages"...
Processing "/var/mail/vhosts/domain.com/administrator"
    Updating 4117 mail files in "/var/mail/vhosts/domain.com/administrator"...
Processing "/var/mail/vhosts/domain.com/david/.Apple Mail To Do"
Processing "/var/mail/vhosts/domain.com/david/.Archive"
Processing "/var/mail/vhosts/domain.com/david/.Deleted Messages"
    Updating 3 mail files in "/var/mail/vhosts/domain.com/david/.Deleted Messages"...
Processing "/var/mail/vhosts/domain.com/david/.Drafts"
Processing "/var/mail/vhosts/domain.com/david/.Junk"
Processing "/var/mail/vhosts/domain.com/david/.Notes"
Processing "/var/mail/vhosts/domain.com/david/.Sent Messages"
    Updating 2870 mail files in "/var/mail/vhosts/domain.com/david/.Sent Messages"...
Processing "/var/mail/vhosts/domain.com/david"
    Updating 3834 mail files in "/var/mail/vhosts/domain.com/david"...
Processing "/var/mail/vhosts/domain.com/david/.Apple Mail To Do"
Processing "/var/mail/vhosts/domain.com/david/.Archive"
Processing "/var/mail/vhosts/domain.com/david/.Deleted Messages"
    Updating 2 mail files in "/var/mail/vhosts/domain.com/david/.Deleted Messages"...
Processing "/var/mail/vhosts/domain.com/david/.Drafts"
Processing "/var/mail/vhosts/domain.com/david/.Junk"
Processing "/var/mail/vhosts/domain.com/david/.Notes"
Processing "/var/mail/vhosts/domain.com/david/.Sent Messages"
    Updating 26 mail files in "/var/mail/vhosts/domain.com/david/.Sent Messages"...
Processing "/var/mail/vhosts/domain.com/david"
    Updating 341 mail files in "/var/mail/vhosts/domain.com/david"...
Processing "/var/mail/vhosts/domain.com/foobar/.20090731.3BA29-3D4"
    Updating 10 mail files in "/var/mail/vhosts/domain.com/foobar/.20090731.3BA29-3D4"...
Processing "/var/mail/vhosts/domain.com/foobar/.20090731.Inbox"
    Updating 4250 mail files in "/var/mail/vhosts/domain.com/foobar/.20090731.Inbox"...
Processing "/var/mail/vhosts/domain.com/foobar/.20090731.Re WBO"
    Updating 19 mail files in "/var/mail/vhosts/domain.com/foobar/.20090731.Re WBO"...
Processing "/var/mail/vhosts/domain.com/foobar/.20090731.Sent"
    Updating 1193 mail files in "/var/mail/vhosts/domain.com/foobar/.20090731.Sent"...
Processing "/var/mail/vhosts/domain.com/foobar/.20090731"
Processing "/var/mail/vhosts/domain.com/foobar/.20100731.Inbox"
    Updating 1535 mail files in "/var/mail/vhosts/domain.com/foobar/.20100731.Inbox"...
Processing "/var/mail/vhosts/domain.com/foobar/.20100731.Sent"
    Updating 788 mail files in "/var/mail/vhosts/domain.com/foobar/.20100731.Sent"...
Processing "/var/mail/vhosts/domain.com/foobar/.20100731"
    Updating 1 mail files in "/var/mail/vhosts/domain.com/foobar/.20100731"...
Processing "/var/mail/vhosts/domain.com/foobar/.20120731.Inbox"
    Updating 8115 mail files in "/var/mail/vhosts/domain.com/foobar/.20120731.Inbox"...
    File /var/mail/vhosts/domain.com/foobar/.20120731.Inbox/cur/1351091506.M290526P89101.alix.domain.com,S=135487:2,Sab -- can't translate date "Thu, 2 Dec 2010".
    File /var/mail/vhosts/domain.com/foobar/.20120731.Inbox/cur/1351091506.M290527P89101.alix.domain.com,S=135314:2,Sab -- can't translate date "Thu, 2 Dec 2010".
    File /var/mail/vhosts/domain.com/foobar/.20120731.Inbox/cur/1351091516.M825619P89101.alix.domain.com,S=134792:2,S -- can't translate date "Thu, 25 Nov 2010".
    File /var/mail/vhosts/domain.com/foobar/.20120731.Inbox/cur/1351091549.M592740P89101.alix.domain.com,S=2948740:2,Sab -- can't translate date "Tue, 30 Nov 2010".
    File /var/mail/vhosts/domain.com/foobar/.20120731.Inbox/cur/1351091558.M369413P89101.alix.domain.com,S=137645:2,Sab -- can't translate date "Mon, 1 Nov 2010".
    File /var/mail/vhosts/domain.com/foobar/.20120731.Inbox/cur/1351091577.M492010P89101.alix.domain.com,S=134729:2,S -- can't translate date "Thu, 25 Nov 2010".
    File /var/mail/vhosts/domain.com/foobar/.20120731.Inbox/cur/1351091605.M665664P89101.alix.domain.com,S=134458:2,Sab -- can't translate date "Fri, 10 Dec 2010".
    File /var/mail/vhosts/domain.com/foobar/.20120731.Inbox/cur/1351091624.M378649P89101.alix.domain.com,S=134391:2,S -- can't translate date "Wed, 15 Dec 2010".
    File /var/mail/vhosts/domain.com/foobar/.20120731.Inbox/cur/1351091643.M679049P89101.alix.domain.com,S=279547:2,Sab -- can't translate date "Tue, 30 Nov 2010".
Processing "/var/mail/vhosts/domain.com/foobar/.20120731.Sent"
    Updating 4108 mail files in "/var/mail/vhosts/domain.com/foobar/.20120731.Sent"...
Processing "/var/mail/vhosts/domain.com/foobar/.20120731"
    Updating 1 mail files in "/var/mail/vhosts/domain.com/foobar/.20120731"...
Processing "/var/mail/vhosts/domain.com/foobar/.20130731.Inbox"
    Updating 6716 mail files in "/var/mail/vhosts/domain.com/foobar/.20130731.Inbox"...
Files checked: 1680
...
```

# Finishing Up
Once you have repaired the information on the mail server and restarted it to make use of the updated information, you need to update the clients. This can be messy because the clients typically store local copies of the mail that will now be out of date. One easy way is simply to completely delete and recreate the client account. (Note, it's probably not enough to disable and then re-enable the account, as the local copies may be preserved when the account is disabled and returned to use when the account is re-enabled.)

# Limitations
1. It only fixes up problems due to incorrect modification dates on `Maildir` files.
2. It maps dates and times to local time using the `date` utility in FreeBSD and the [GNU date input facilities](https://www.gnu.org/software/coreutils/manual/html_node/Date-input-formats.html#Date-input-formats) in Linux.
  Linux is somewhat more flexible in its interpretation of date strings, but it can miss faulty strings. For instance, a date string without a time or zone information will be accepted by Linux but rejected by FreeBSD.
3. It has not been tested in different locales. Things to watch out for are incorrect times and problems with non-English dates and date formats.
4. It has not been extensively tested. Back up your mail repository before using it.
5. It uses the first date it finds in a mail file, which may not always be exactly right.
6. It's a bit slow.
