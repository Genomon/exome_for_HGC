#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012


open(IN, $ARGV[0]) || die "cannot open $!";
$_ = <IN>;
s/[\r\n]//g;
@curRow = split("\t", $_);

print join("\t", @curRow[0 .. ($#curRow - 1)]). "\t" . "bases_tumor" . "\t" . "bases_normal" . "\t" . "misRate_tumor" . "\t" . "strandRatio_tumor" . "\t" . "misRate_normal" . "\t" . "strandRatio_normal" . "\t" . "p-value" . "\n"; 

@curRow = ();
while(<IN>) {
  s/[\r\n]//g;
  @curRow = split("\t", $_);
  @other_info = @curRow[($#curRow - 6) .. $#curRow];
  $other_info[0] =~ s/"//g;
  $other_info[6] =~ s/"//g;
  print join("\t", @curRow[0 .. ($#curRow - 7)]). "\t" .$other_info[0] . "\t" . join("\t", @other_info[1 .. 5]) ."\t" . $other_info[6] ."\n"; 
}
close(IN);

