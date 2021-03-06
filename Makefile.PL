use strict;
use inc::Module::Install;
name 'POE-Filter-LZO';
author 'Chris Williams <chris@bingosnet.co.uk>';
license 'perl';
auto_license holder => 'Chris Williams';
version_from 'lib/POE/Filter/LZO.pm';
abstract_from 'lib/POE/Filter/LZO.pm';
perl_version '5.006';
build_requires 'Test::More' => 0.47;
build_requires 'POE::Filter::Stackable' => 0;
build_requires 'POE::Filter::Line' => 0;
requires 'Compress::LZO' => 1.08;
requires 'POE'    => 0.38;
requires 'POE::Filter' => 0;
auto_provides;
githubmeta;
WriteAll();
