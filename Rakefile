$config = {
  :ejabberd => {
    :url => 'http://www.process-one.net/downloads/ejabberd/2.1.12/ejabberd-2.1.12.tgz',
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

namespace :ejaberd do
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
        system! "make all"
        system! "make install"
      end
    end
  end
end
