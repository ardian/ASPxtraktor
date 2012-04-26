use Module::Build;
Module::Build->new
    ( 
      module_name => 'ASPXTRAKTOR',
      license => 'gpl',
      dist_abstract => "aspx table extractor",
      requires => { 'Thread::Pool' => 0,

      },

    )->create_build_script;
