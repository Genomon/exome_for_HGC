open(IN, $ARGV[0]) || die "cannot open $!";
$_ = <IN>;
s/[\r\n]//g;
@curRow = split("\t", $_);

print join("\t", @curRow[0 .. $#curRow - 1]) . "\t" .  "bases" . "\t" . "mismatch-ratio" . "\t" . "strand ratio" . "\t" . "10% posterior quantile" . "\t" . "posterior mean" . "\t" . "90% posterior quantile" . "\n"; 
while(<IN>) {
    s/[\r\n]//g;
    @curRow = split("\t", $_);
    @other_info = @curRow[($#curRow - 5) .. $#curRow];
    $other_info[0] =~ s/"//g;
    $other_info[5] =~ s/"//g;
    print join("\t", @curRow[0 .. $#curRow - 7]) . "\t" . join("\t", @other_info[0 .. 4]) ."\t" . $other_info[5] . "\n";
}
close(IN);

