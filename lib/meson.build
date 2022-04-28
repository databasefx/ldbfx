libdbfx_sources = [
  'connection-pool.vala',
  'connection.vala',
  'config/constant.vala',
  'async/async-work.vala',
  'config/datasource.vala',
  'config/db-feature.vala',
  'config/error-domain.vala',
  'model/database-info.vala',
  'model/database-schema.vala',
  'impl/mysql-connection.vala',
]

libdbfx_c_args = [
  '-include','config.h'
]

libdbfx_deps = [
  glib,
  gio,
  libgee,
  mysql
]

#静态链接
libdbfx = static_library('dbfx',libdbfx_sources,
  include_directories: conf_include_dir,
  c_args: libdbfx_c_args,
  dependencies: libdbfx_deps
)

# 声明依赖提供给其他模块使用
libdbfx_dep = declare_dependency(
  link_with: libdbfx,
  include_directories: include_directories('.'),
)
