# frozen_string_literal: true
require 'cocoapods-imy-bin/helpers/git_until'

module Pod
  class Command
    class Bin < Command
      class Spec < Bin
        class Modify < Spec
          self.summary = '修改源码spec仓库，Usage：bin spec modify THKMacroKit 0.1.0 1234 --message=hahaha'

          self.arguments = [
            CLAide::Argument.new('NAME', false)
          ]

          def self.options
            [
              ['podspec', '.podsepc文件'],
              ['0.1.0', 'spec文件对应的版本'],
              ['1234', 'spec文件对应的commit号'],
              ['--message=修改了xxx，更新了xxx', '提交的消息'],
              ['--no-deleteBin','不删除二进制仓库，默认删除']
            ].concat(super)
          end

          def initialize(argv)
            @podname = argv.shift_argument
            @version = argv.shift_argument
            @commit = argv.shift_argument
            @message = argv.option('message') || ''
            @delete_bin = argv.flag?('deleteBin', true)
            super
          end

          def run
            validate!
            code_source.update(true )
            binary_source.update(true )
            UI.puts "----------修改src仓库文件----------".yellow
            modify_src_repo
            push_src_repo
            return unless @delete_bin
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
            begin
              # 删除二进制podspec
              specification = binary_source.specification(@podname,@version)
              fwk_dir = Pathname.new(specification.defined_in_file).dirname
              FileUtils.rm_rf(fwk_dir)
            rescue Exception => e
              message = "delete bin repo fail: #{e.message}"
              UI.puts message.yellow
            end
            
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
              f.read.gsub(/:commit => ["'](.*)["']/, ":commit => \"#{commit}\"")
            end
            )
          end

        end
      end
    end
  end
end
