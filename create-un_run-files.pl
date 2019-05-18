#!/usr/bin/env perl

# Build, upload and promote Unplug using ecpluginbuilder
#		https://github.com/electric-cloud/ecpluginbuilder

use Getopt::Long;
use Data::Dumper;
use strict;
use File::Copy;

use ElectricCommander ();
$| = 1;
my $ec = new ElectricCommander->new();


foreach my $var ("", 0 .. 9, "a" .. "z") {
  print "$var ";
	my $xmlFile="pages/un_run${var}.xml";
	# my $template="template/un_run.xml";
	open(my $fh, '>', $xmlFile) or die "Could not write file '$xmlFile' $!";

	print $fh "<componentContainer>\n";
	print $fh "  <helpLink>help</helpLink>\n";
	print $fh "  <title>\@PLUGIN_KEY\@ \@PLUGIN_VERSION\@</title>\n";
	print $fh "  <component plugin=\"EC-Core\" ref=\"urlLoader\">\n";
	print $fh "    <style>../../lib/styles/data.css</style>\n";
	print $fh "    <plugin>unplug</plugin>\n";
	print $fh "    <version>\@PLUGIN_VERSION\@</version>\n";
	print $fh "    <evalScripts>true</evalScripts>\n";
	print $fh "    <url>cgi-bin/un.cgi</url>\n";
	print $fh "    <requests>\n";
	print $fh "      <request requestId=\"v\">\n";
	print $fh "        <getProperty>\n";
	print $fh "          <propertyName>/javascript getProperty(&quot;/server/\@PLUGIN_KEY\@/v${var}&quot;)</propertyName>\n";
	print $fh "        </getProperty>\n";
	print $fh "      </request>\n";
	print $fh "    </requests>\n";
	print $fh "  </component>\n";
	print $fh "</componentContainer>\n";
	close $fh;

}
print "\n";
