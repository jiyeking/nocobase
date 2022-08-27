#!/bin/expect
set timeout 10
spawn npm adduser --registry http://verdaccio:4873
expect "Username:"
send "test\n"
expect "Password:"
send "123456\n"
expect "Email: (this IS public)"
send "test@mail.com\n"
spawn npm login --registry http://verdaccio:4873
expect "Username:"
send "test\n"
expect "Password:"
send "123456\n"
expect "Email: (this IS public)"
send "test@mail.com\n"
