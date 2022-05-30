 gnome = import('gnome')
resource_files = files('ldbfx_vala.gresource.xml')
resources = gnome.compile_resources('cn.navclub.ldbfx',resource_files,c_name:'resources')

desktop_file = i18n.merge_file(
  input: 'cn.navclub.ldbfx.desktop.in',
  output: 'cn.navclub.ldbfx.desktop',
  type: 'desktop',
  po_dir: '../po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)


desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils,
    args: [desktop_file]
  )
endif

appstream_file = i18n.merge_file(
  input: 'cn.navclub.ldbfx.appdata.xml.in',
  output: 'cn.navclub.ldbfx.appdata.xml',
  po_dir: '../po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'appdata')
)

appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test('Validate appstream file', appstream_util,
    args: ['validate', appstream_file]
  )
endif

install_data('cn.navclub.ldbfx.gschema.xml',
  install_dir: join_paths(get_option('datadir'), 'glib-2.0/schemas')
)

install_data('mono_kai_extended.xml',
  install_dir:join_paths(get_option('datadir'),'gtksourceview-5/styles')
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file', compile_schemas,
    args: ['--strict', '--dry-run', meson.current_source_dir()]
  )
endif

subdir('icons')
