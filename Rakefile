if RUBY_VERSION !~ /1.9/
  puts "Ruby 1.9 required"
  puts "If you have ruby 1.9 installed, try rake1.9 or rake19."
  exit 1
end

require 'rubygems'
require 'open3'
require 'fileutils'

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

# Helpers
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
    base = File.basename(src, '.coffee')
    dst  = "#{dstdir}/#{base}.js"
    dir  = File.dirname(dst)

    # Create actual tasks
    directoryp(dir)
    file(dst => [src, dir]) {coffee(dst, src)}
    task(parenttask => [dst])
  end
end

def build_copy_tasks(filelist, dstdir, parenttask)
  filelist.each do |src|
    base = File.basename(src)
    dst  = "#{dstdir}/#{base}"
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

task :heron   => [ :heron_client, :heron_server ]
task :oghma   => [ :oghma_client                ]
task :build   => [ :heron, :oghma               ]
task :default => [ :build                       ]

task :watch do
  while true do
    pid = fork do
      exec([$0, 'build'])
    end
    Process.wait(pid)
    sleep 5
  end
end
