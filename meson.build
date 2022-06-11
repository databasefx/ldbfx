project(
  'ldbfx', ['c', 'vala'],
  version: '0.1.0',
  license: 'Apache-2.0',
  meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2']
)

datadir = get_option('datadir')

i18n = import('i18n')
cmake = import('cmake')

conf_include_dir = include_directories('.')

add_project_arguments(
    [
      '--vapidir', join_paths(meson.current_source_dir(), 'vapi'),
      '--pkg','config'
    ],
    language: 'vala'
)


min_glib_version = '2.50'

libgee = dependency('gee-0.8')
sqlite3 = dependency('sqlite3')
libxml = dependency('libxml-2.0')
libmariadb = dependency('libmariadb')
libjson = dependency('json-glib-1.0')
gtk = dependency('gtk4', version: '>= 4.6.4')
libsourceview = dependency('gtksourceview-5')
gio = dependency('gio-2.0', version: '>=' + min_glib_version)
glib = dependency('glib-2.0', version: '>=' + min_glib_version)

# 项目配置信息
conf = configuration_data()

#
# 当前系统类型 linux/window/macos
#
conf.set_quoted('SYSTEM_TYPE','linux')

conf.set_quoted('APPLICATION_ID','cn.navclub.ldbfx')
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('PROJECT_NAME',meson.project_name())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('ICON_SEARCH_PATH',join_paths(get_option('datadir'),'icons'))
conf.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))


#安装配置头文件
configure_file(output: 'config.h', configuration: conf)


meson.add_install_script('meson_post_install.py')

subdir('data')
subdir('lib')
subdir('src')
subdir('po')

