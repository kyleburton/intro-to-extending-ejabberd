require 'rubygems'
require 'json'
require 'socket'
require 'erb'
require 'pp'
# require 'ruby-debug'

# see http://stackoverflow.com/questions/3242470/problem-using-openstruct-with-erb
class ErbBinding < OpenStruct
  def get_binding
    binding
  end
end

task :default => [:help]

$config = {
  :ejabberd => {
    :url => 'http://www.process-one.net/downloads/ejabberd/2.1.12/ejabberd-2.1.12.tgz',
  },
  'reveal.js' => {
    :git => "https://github.com/hakimel/reveal.js.git"
  },
    :mod_restful => {
    :git => 'git@github.com:relaynetwork/mod_restful.git'
  },
  :api_key => "1l0gls94hajw24evjclz48e23k9l5q9zyt2feufhtitulyxzkoe"
}

if File.exist? ".config.json"
  #puts "Loading configuration from .config.json"
  $config = JSON.parse(File.read(".config.json"), :symbolize_names => true)
end

#puts "config: "
#pp $config

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
task :install => ["ejabberd:install", "revealjs:install", "mod_restful:install", "build"] do
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

namespace :mod_restful do
  desc "install"
  task :install do
    chdir! "software/build" do
      unless File.exist? "mod_restful"
        system! "git clone #{$config[:mod_restful][:git]}"
      end
    end
  end
end

namespace :erlang do
  desc "start an erlang shell (erl) that can cluster with the running ejabberd"
  task :shell, :cookie do |t,args|
    erlang_cookie = args[:cookie] || File.read('./software/ejabberd/var/lib/ejabberd/.erlang.cookie') || File.read("#{ENV['HOME']}/.erlang.cookie")
    puts "muc_interact:join_ejabberd(ejabberd@#{Socket.gethostname})."
    system! "erl -sname shell1@localhost -setcookie #{erlang_cookie} -pa ./software/ejabberd/lib/ejabberd/ebin/"
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
      props = ErbBinding.new
      props.hostname = Socket.gethostname
      props.api_key = $config[:api_key]
      vars_binding = props.send(:get_binding)
      result = ERB.new(File.read(src), 0, '>').result(vars_binding)
      puts "Rendering and installing #{src} => #{dst}"
      File.open(dst, "w") do |f|
        f.write result
      end
    end
  end
end

desc "build"
task :build do
  jabber_src_path  = $config[:jabber_src_path]  || "#{File.dirname(__FILE__)}/software/build/ejabberd-2.1.12/src"
  jabber_ebin_path = $config[:jabber_ebin_path] || "#{File.dirname(__FILE__)}/software/ejabberd/lib/ejabberd/ebin/"
  muc_src_path     = "#{jabber_src_path}/mod_muc"

  #puts "jabber_src_path:   #{jabber_src_path}"
  #puts "jabber_ebin_path:  #{jabber_ebin_path}"
  #puts "muc_src_path:      #{muc_src_path}"

  #chdir! "software/build/ejabberd/src/mod_muc" do
  chdir! muc_src_path do
    system! "make"
  end

  include_dirs = [jabber_src_path, muc_src_path]
  ejabberd_includes = include_dirs.map {|d| "-I #{d}"}.join(" ")
  chdir! "src" do
    cmd = "erlc #{ejabberd_includes} *.erl"
    system! cmd
    system! "sudo cp *.beam #{jabber_ebin_path}"
  end

  chdir! "software/build/mod_restful/src" do
    cmd = "erlc #{ejabberd_includes} -pa #{jabber_src_path} -pa . -I .. -I ../include *.erl"
    system! cmd
    system! "sudo cp *.beam #{jabber_ebin_path}"
  end

  puts ""
  puts "nl(muc_interact)."
  puts "nl(mod_restful_admin)."
  puts ""
end

namespace :rest do
  namespace :room do
    desc "room occupants"
    task :occupants, :room do |t,args|
      room_name = args[:room] || 'room1'
      system! "curl", "http://localhost:8088/api/admin/room/#{room_name}/occupants?key=#{$config[:api_key]}"
      puts ""
    end

    desc "room messages"
    task :messages, :room do |t,args|
      room_name = args[:room] || 'room1'
      system! "curl", "http://localhost:8088/api/admin/room/#{room_name}/messages?key=#{$config[:api_key]}"
      puts ""
    end

    desc "post message"
    task :message, :room, :from, :friendly_from, :body do |t,args|
      room_name     = args[:room]
      from          = args[:from]
      friendly_from = args[:friendly_from]
      body          = args[:body]
      system! <<-END
curl -v \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{"key":"#{$config[:api_key]}","body":"#{body}","from": "#{from}", "friendly_from": "#{friendly_from}"}' \
  http://localhost:8088/api/admin/room/#{room_name}/message
      END
      puts ""
    end
  end
end
