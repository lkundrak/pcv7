find -name '*.o' -delete
find -name '*.c' -not -name mkconf.c -exec bcc -0 -c -I '{}' \;
