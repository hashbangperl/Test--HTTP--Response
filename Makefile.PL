use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Test::HTTP::Response',
    VERSION_FROM      => 'lib/Test/HTTP/Response.pm', # finds $VERSION
    PREREQ_PM         => {
			    'HTTP::Message' =>  6.06,
			    'HTTP::Cookies' => 6.01,
			 }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
       (AUTHOR         => 'Aaron Trevena <teejay@(none)>') : ()),
   META_MERGE => {
     resources => {
       repository => 'https://github.com/hashbangperl/Test--HTTP--Response',
    },
   },
   ($ExtUtils::MakeMaker::VERSION >= 6.3002 ? ('LICENSE'  => 'perl', ) : ()),
);
