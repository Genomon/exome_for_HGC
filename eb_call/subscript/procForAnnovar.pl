# conver three candidate variation files (mutation, insertion and deletion) for process via Annovar 
use strict;

my $mutationFile = $ARGV[0];
my $insersionFile = $ARGV[1];
my $deletionFile = $ARGV[2];

# mutation
if (-e $mutationFile) { 

open(IN, $mutationFile) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    my $chr = $F[0];
    my $pos = $F[1];
    print $chr . "\t" . $pos . "\t" . $pos . "\t" . join("\t", @F[2 .. $#F]) . "\n";
}
close(IN);

}


# insertion
if (-e $insersionFile) { 

open(IN, $insersionFile) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my $chr = $F[0];
    my $pos = $F[1];
    my $ref = $F[2];
    my $mis = $F[3];

    print $chr . "\t" . $pos . "\t" . $pos . "\t" . "-" . "\t" . $mis . "\t" . join("\t", @F[4 .. $#F]) . "\n";

}
close(IN);

}

# deletion 
if (-e $deletionFile) { 

open(IN, $deletionFile) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F= split("\t", $_);

    my $chr = $F[0];
    my $pos = $F[1];
    my $ref = $F[2];
    my $mis = $F[3];

    print $chr . "\t" . ($pos + 1) . "\t" . ($pos + length($mis)) . "\t" . $mis . "\t" . "-" . "\t" . join("\t", @F[4 .. $#F]) . "\n";
}
close(IN);

}    
