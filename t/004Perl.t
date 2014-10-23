######################################################################
# Test suite for File::Comments
# by Mike Schilli <cpan@perlmeister.com>
######################################################################

use warnings;
use strict;

use Test::More qw(no_plan);
use Sysadm::Install qw(:all);
use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($DEBUG);

BEGIN { use_ok('File::Comments') };
use File::Comments::Plugin;

my $eg = "eg";
$eg = "../eg" unless -d $eg;

my $snoop = File::Comments->new();

######################################################################
my $tmpfile = "$eg/test.pl";
END { unlink $tmpfile }
blurt(<<EOT, $tmpfile);
# First comment
# Second
# Third
__END__
# End
EOT

my $chunks = $snoop->comments($tmpfile);

ok($chunks, "find perl comments");
is($chunks->[0], " First comment", "hashed comment");
is($chunks->[1], " Second", "hashed comment");
is($chunks->[2], " Third",   "hashed comment");
is($chunks->[3], "\n# End\n",   "__END__");

######################################################################
my $tmpfile2 = "$eg/testperl";
END { unlink $tmpfile2 }
blurt(<<EOT, $tmpfile2);
#!/usr/bin/perl
# First comment
# Second
# Third

=head2 some pod

Yada yada yada.

=cut

print "Yada\n";
EOT

$chunks = $snoop->comments($tmpfile2);

is(@$chunks, 5, "find perl comments");
is($chunks->[0], "!/usr/bin/perl", "hashed comment");
is($chunks->[1], " First comment", "hashed comment");
is($chunks->[2], " Second", "hashed comment");
is($chunks->[3], " Third",   "hashed comment");
is($chunks->[4], "=head2 some pod\n\nYada yada yada.\n\n=cut", 
                 "pod comment");

######################################################################
my $tmpfile3 = "$eg/testperl2";
END { unlink $tmpfile3 }
blurt(<<EOT, $tmpfile3);
#!/usr/bin/perl
# First comment
somefunc(); # Second
# Third

__END__

=head2 some pod

Yada yada yada.

=cut

print "Yada\n";
EOT

$chunks = $snoop->comments($tmpfile3);

is(@$chunks, 5, "find perl comments");

#!/usr/bin/perl- First comment- Second- Third-Yada yada yada.
is($chunks->[0], "!/usr/bin/perl", "hashed comment");
is($chunks->[1], " First comment", "hashed comment");
is($chunks->[2], " Second", "hashed comment");
is($chunks->[3], " Third",   "hashed comment");
is($chunks->[4], "\n\n=head2 some pod\n\nYada yada yada." .
                 "\n\n=cut\n\nprint \"Yada\n\";\n", 
                 "pod comment");
