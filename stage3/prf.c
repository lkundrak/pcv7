
/*
 * selfexplainatory ones, i think
 */

void
puts (string)
	char *string;
{
	while (*string)
		putchar (*string++);
}

void
putn (number, base)
	unsigned number;
{
	char *digits = "0123456789abcdef";

	if (number/base)	/* not a leftmost digit */
		putn (number/base, base);
	putchar (digits[number%base]);
}

/*
 * see printf(3) manual in your libc documentation.
 * this version just implements small subset of standard printf's
 * abilities, just to satisfy kernel's needs, as you can see...
 */

void
printf (format)
	char *format;
{
	int *argp;
	char c;

	argp = (void *)&format;
	argp++;
	while ((c = *format++)) {
		if (c == '\n')
			putchar ('\r');
		if (c == '%')
			switch (c = *format++) {
				case 'u':
				case 'd':
				case 'i': putn (*argp++, 10); break;
				case 'x': putn (*argp++, 16); break;
				case 'o': putn (*argp++, 8); break;
				case 's': puts ((char *)*argp++); break;
				case 'c': putchar ((char)*argp++); break;
				case '%': putchar ('%'); break;
				case '\0': return;
			}
		else
			putchar (c);
	}
}
