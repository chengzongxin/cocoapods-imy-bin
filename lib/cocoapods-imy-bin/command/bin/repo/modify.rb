# frozen_string_literal: true
require 'cocoapods-imy-bin/helpers/git_until'

module Pod
  class Command
    class Bin < Command
      class Repo < Bin
        class Modify < Repo
          self.summary = '修改源码spec仓库'

          self.arguments = [
            CLAide::Argument.new('NAME', false)
          ]

          def self.options
            [
              ['--message', '提交的消息']
            ].concat(super)
          end

          def initialize(argv)
            @podname = argv.shift_argument
            @version = argv.shift_argument
            @commit = argv.shift_argument
            @message = argv.option('message') || ''
            super
          end

          def run
            validate!
            code_source.update(true )
            binary_source.update(true )
            UI.puts "----------修改src仓库文件----------".yellow
            modify_src_repo
            push_src_repo
            UI.puts "----------删除bin仓库文件----------".yellow
            delete_exist_framework
            delete_bin_repo
            push_bin_repo
          end

          def validate!
            raise Pod::Informative, "#{@podname} podname 为空" unless @podname
            raise Pod::Informative, "#{@version} version为空" unless @version
            raise Pod::Informative, "#{@commit} commit为空" unless @commit
            super
          end


          def delete_exist_framework
            # 删除二进制库
            server_url = CBin::config.binary_upload_url
            command = "curl -v -X DELETE #{server_url}/#{@podname}/#{@version}"
            print <<EOF
            删除二进制文件
            #{command}
EOF
            delete_result = `#{command}`
            puts "#{delete_result}"
          end

          def delete_bin_repo
            # 删除二进制podspec
            specification = binary_source.specification(@podname,@version)
            fwk_dir = Pathname.new(specification.defined_in_file).dirname
            FileUtils.rm_rf(fwk_dir)
          end

          def push_bin_repo
            CBin::Git::Until.push(binary_source.repo,"delete bin spec repo change : #{@podname} commit => #{@commit} message => #{@message}")
          end

          def modify_src_repo
            specification = code_source.specification(@podname,@version)
            modify_src_commit(specification.defined_in_file,@commit)
          end


          def push_src_repo
            CBin::Git::Until.push(code_source.repo,"modify src spec repo change : #{@podname} commit => #{@commit} message => #{@message}")
          end


          # 开始修改源码仓库
          def modify_src_commit(file_path,commit)
            pn = Pathname.new(file_path)
            if pn.file?
              modify_src_file_line(pn.to_s,commit)
              return pn.to_s
            else
              return nil
            end
          end

          # 修改文件
          def modify_src_file_line(file,commit)
            p 'start modify file ...' + file

            IO.write(file, File.open(file) do |f|
              f.read.gsub(/:commit => "(.*)"/, ":commit => \"#{commit}\"")
            end
            )
          end

        end
      end
    end
  end
end
