if RUBY_VERSION !~ /1.9/ && RUBY_VERSION !~ /2.0/
  puts "Ruby 1.9 or 2.0 required"
  puts "If you have ruby 1.9/2.0 installed, try rake1.9 or rake19 (rake2.0 or rake20)."
  exit 1
end

require 'rubygems'
require 'open3'
require 'fileutils'
require 'net/http'

# Configuration
OGHMA_TOP = File.dirname(File.expand_path(__FILE__))
if Dir.pwd != OGHMA_TOP
  puts "Must run in #{OGHMA_TOP}"
  exit 1
end

HERON_TOP = '../heron'
HERON_CLIENT_FILES =
  Rake::FileList.new("#{HERON_TOP}/client/**/*.coffee").exclude(%r{/test/})
HERON_SERVER_FILES =
  Rake::FileList.new("#{HERON_TOP}/server/**/*.rb").exclude(%r{/test/})
OGHMA_CLIENT_FILES =
  Rake::FileList.new("#{OGHMA_TOP}/oghma/**/*.coffee").exclude(%r{/test/})

COFFEE = 'coffee'

EXTERNALS = [
  [ "http://coffeescript.org/extras/coffee-script.js", "coffee-script.js" ],
  [ "http://kineticjs.com/download/v4.1.2/kinetic-v4.1.2.js", "kinetic.js" ],
  [ "http://code.jquery.com/jquery-1.8.3.js", "jquery.js" ]
]

# Helpers
def common_parent(a, b)
  as = File.expand_path(a).split('/')
  bs = File.expand_path(b).split('/')

  i = 0
  while as[i] == bs[i]
    i += 1
  end

  as[0..i].join('/')
end

def coffee(dst, src)
  puts "coffee #{src} -> #{dst}"
  Open3.popen3(COFFEE, '-c', '-p', src) do |cin, cout, cerr, wt|
    exit_status = wt.value
    if exit_status.success?
      File.open(dst, 'w') do |w|
        w.write(cout.read)
      end
    else
      puts "Failed (#{exit_status}):"
      puts cerr.read
      throw "coffee failed"
    end
  end
end

def directoryp(path)
  file(path) {FileUtils.mkdir_p(path)}
end

def build_coffee_tasks(filelist, dstdir, parenttask)
  filelist.each do |src|
    src = File.expand_path(src)
    common = common_parent(src, dstdir)
    dst = src.sub(common, dstdir).gsub(/.coffee$/, '.js')
    dir  = File.dirname(dst)

    # Create actual tasks
    directoryp(dir)
    file(dst => [src, dir]) {coffee(dst, src)}
    task(parenttask => [dst])
  end
end

def build_copy_tasks(filelist, dstdir, parenttask)
  filelist.each do |src|
    src = File.expand_path(src)
    common = common_parent(src, dstdir)
    dst = src.sub(common, dstdir)
    dir  = File.dirname(dst)

    # Create actual tasks
    directoryp(dir)
    file(dst => [src, dir]) {copy(src, dst)}
    task(parenttask => [dst])
  end
end

# Tasks
build_coffee_tasks( HERON_CLIENT_FILES, 'public/heron', :heron_client )
build_coffee_tasks( OGHMA_CLIENT_FILES, 'public/oghma', :oghma_client )
build_copy_tasks(   HERON_SERVER_FILES, 'server/heron', :heron_server )

task :externals
EXTERNALS.each do |src, dst|
  dir        = "public/external"
  uri        = URI(src)
  long       = File.basename(uri.path)
  long_path  = "#{dir}/#{long}"
  short_path = "#{dir}/#{dst}"

  next if File.exists?(long_path)
  directoryp(dir)
  file(long_path => [dir]) do
    File.open(long_path, "w") do |out|
      out.print Net::HTTP.get( uri )
    end
  end
  if short_path != long_path
    file(short_path => [long_path]) do
      link(long_path, short_path)
    end
  end
  task :externals => [short_path]
end

task :doc do
  require 'fileutils'

  codo_dir = 'doc/codo'
  yard_dir = 'doc/yard'
  FileUtils.mkdir_p('doc')
  oghma_files =   Rake::FileList.new("oghma/**/*.coffee")
  sh "codo -v -o #{codo_dir} --title Oghma #{oghma_files} #{HERON_CLIENT_FILES}"
end

task :heron   => [ :heron_client, :heron_server ]
task :oghma   => [ :oghma_client                ]
task :build   => [ :heron, :oghma               ]
task :default => [ :build, :externals, :doc     ]

task :watch do
  while true do
    pid = fork do
      exec($0, 'build')
    end
    Process.wait(pid)
    sleep 5
  end
end
