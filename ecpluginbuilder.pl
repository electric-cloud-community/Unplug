#!/usr/bin/env perl

# Build, upload and promote Unplug using ecpluginbuilder
#		https://github.com/electric-cloud/ecpluginbuilder

use XML::Simple qw(:strict);
use Data::Dumper;
use strict;
use File::Copy;

use ElectricCommander ();
$| = 1;
my $ec = new ElectricCommander->new();

my $epb="../ecpluginbuilder";

my $pluginVersion = "2.3.4";
my $pluginKey = "unplug";

# Fix version in plugin.xml
# Update plugin.xml with  version,
print "[INFO] - Processing 'META-INF/plugin.xml' file...\n";
my $xs = XML::Simple->new(
        ForceArray => 1,
        KeyAttr    => { },
        KeepRoot   => 1,
);
my $xmlFile = "META-INF/plugin.xml";
my $ref  = $xs->XMLin($xmlFile);
$ref->{plugin}[0]->{version}[0] = $pluginVersion;
open(my $fh, '>', $xmlFile) or die "Could not open file '$xmlFile' $!";
print $fh $xs->XMLout($ref);
close $fh;

# Read buildCounter
my $buildCounter;
{
  local $/ = undef;
  open FILE, "buildCounter" or die "Couldn't open file: $!";
  $buildCounter = <FILE>;
  close FILE;

 $buildCounter++;
 $pluginVersion .= ".$buildCounter";
 print "[INFO] - Incrementing build number to $buildCounter...\n";

 open FILE, "> buildCounter" or die "Couldn't open file: $!";
 print FILE $buildCounter;
 close FILE;
}
my $pluginName = "${pluginKey}-${pluginVersion}";

print "[INFO] - Creating plugin '$pluginName'\n";


#
# creates pages un_run*.xml files from the template directory
print "[INFO] - Processing 'pages/un_run.xml' files...\n";
print "    ";
# $xs = XML::Simple->new(
# 	ForceArray => 1,
# 	KeyAttr    => {['plugin'] },
# 	KeepRoot   => 1,
# );

#foreach my $var ("", 0 .. 9, "a" .. "z") {
  # print "$var ";
	# my $template="template/un_run.xml";

	# Update un_runXXX.xml with key, version, label, description
	# Bug cannot change the <plugin> attribute, it's confused with the element in <component plugin="EC-Core">
	# $ref  = $xs->XMLin($template);
	# print Dumper ($ref);
	# $ref->{componentContainer}[0]->{title}[0] = "$pluginKey $pluginVersion";
	# $ref->{componentContainer}[0]->{component}[0]->{version}[0] = $pluginVersion;
	# $ref->{componentContainer}[0]->{component}[0]->{plugin}[1] = $pluginKey;
	# $ref->{componentContainer}[0]->{component}[0]->{requests}[0]->
	# 	{request}[0]->{getProperty}[0]->{propertyName}[0] = "/javascript getProperty(&quot;/server/${pluginKey}/v${var}&quot;)";
	#
	# # save file
	# open(my $fh, '>', $xmlFile) or die "Could not write file '$xmlFile' $!";
	# print $fh $xs->XMLout($ref);
	# close $fh;
#}
print "\n";


system ("$epb -pack-jar -plugin-name $pluginKey -plugin-version $pluginVersion " .
	" -folder cgi-bin" .
	" -folder META-INF" .
	" -folder htdocs" .
	" -folder pages" .
	" -folder dsl"
);

move("build/${pluginKey}.jar", ".");

# Uninstall old plugin
# print "[INFO] - Uninstalling old plugin...\n";
# $ec->uninstallPlugin($pluginKey) || print "No old plugin\n";

# Install plugin
print "[INFO] - Installing plugin ${pluginKey}.jar...\n";
$ec->installPlugin("${pluginKey}.jar");

# Promote plugin
print "[INFO] - Promoting plugin...\n";
$ec->promotePlugin($pluginName);
