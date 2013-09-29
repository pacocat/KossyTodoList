use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'KossyTodoList',
    VERSION_FROM  => 'lib/KossyTodoList.pm',
    PREREQ_PM     => {
        'Kossy' =>  '0.19',
    },
    MIN_PERL_VERSION => '5.008001'
);

