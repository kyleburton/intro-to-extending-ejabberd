require 'socket'
require 'erb'

task :default => [:help]

$config = {
  :ejabberd => {
    :url => 'http://www.process-one.net/downloads/ejabberd/2.1.12/ejabberd-2.1.12.tgz',
  },
  'reveal.js' => {
    :git => "https://github.com/hakimel/reveal.js.git"
  }
}

def chdir! path
  unless File.exist? path
    FileUtils.mkdir_p path
  end
  Dir.chdir(path) do
    yield
  end
end

def system! *cmd
  unless system cmd.join(" ")
    raise "Error executing command: #{cmd.join(" ")} : #$!"
  end
  true
end

def download_ejabberd
  chdir!('software/build') do
    pkg_file = File.basename($config[:ejabberd][:url])
    unless File.exist? pkg_file
      system! "wget #{$config[:ejabberd][:url]}"
    end
  end
end

def install_path
  File.dirname(__FILE__) + "/software/ejabberd"
end


task :help do
  system!("rake -T")
end

desc "Run local webserver"
task :server do
  system %Q|ruby -r webrick -e "s = WEBrick::HTTPServer.new(:Port => 9090, :DocumentRoot => Dir.pwd); trap('INT') { s.shutdown }; s.start"|

end

desc "install and build all dependencies"
task :install => ["ejabberd:install", "revealjs:install"] do
  # execute dependencies
end

namespace :revealjs do
  desc "install"
  task :install do
    chdir! "software" do
      unless File.exist? "reveal.js"
        system! "git clone #{$config['reveal.js'][:git]}"
      end
    end
  end
end

namespace :ejabberd do
  desc "install"
  task :install do
    download_ejabberd
    chdir! 'software/build' do
      local_file = File.basename($config[:ejabberd][:url])
      local_dir  = File.basename(local_file,'.tgz')
      unless File.exist? local_dir
        system! "tar xzvf #{local_file}"
      end
      unless File.exist? "ejabberd"
        FileUtils.ln_s local_dir, "ejabberd"
      end

      chdir 'ejabberd/src' do
        unless File.exist? "Makefile"
          system! "./configure --prefix=#{install_path}"
        end
        system! "make"
        system! "make install"
      end
    end
    puts ""
    puts ""
    puts ""
    puts ("*" * 80)
    puts ""
    puts "./software/sbin/ejabberdctl start"
    puts "EJABBERD_BYPASS_WARNINGS=true ./software/sbin/ejabberdctl debug"
    puts "EJABBERD_BYPASS_WARNINGS=true ./software/sbin/ejabberdctl live"

    Rake::Task["ejabberd:install_config_files"].invoke
  end

  desc "Install jabber configuration files"
  task :install_config_files do

    # install configuration files
    Dir['config/*.erb'].each do |src|
      dst = "software/ejabberd/etc/ejabberd/#{File.basename(src,'.erb')}"
      props = OpenStruct.new
      props.hostname = Socket.gethostname
      File.open(dst, "w") do |f|
        result = ERB.new(File.read(src), 0, '>').result
        puts "Rendering and installing #{src} => #{dst}"
        f.write result
      end
    end
  end
end

desc "build"
task :build do
  include_dirs = %w[../software/build/ejabberd-2.1.12/src/ ../software/build/ejabberd-2.1.12/src/mod_muc/]
  chdir! "src" do
    cmd = "erlc #{include_dirs.map {|d| "-I #{d}"}.join(" ")} #{Dir['*.erl'].join(" ")}"
    system! cmd
    system! "cp *.beam ../software/ejabberd/lib/ejabberd/ebin/"
    #Dir['*.erl'].each do |f|
    #  cmd = "erlc #{include_dirs.map {|d| "-I #{d}"}.join(" ")} #{f}"
    #  puts cmd
    #  system! cmd
    #  FileUtils.cp "#{File.basename(f,'.erl')}.beam", "../software/ejabberd/lib/ejabberd/ebin/"
    #end
    puts "l(muc_interact)."
  end
end
