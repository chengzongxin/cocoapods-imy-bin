# frozen_string_literal: true
require 'cocoapods-imy-bin/helpers/trigger'
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
              ['--all', '更新所有私有源，默认只更新二进制相关私有源']
            ].concat(super)
          end

          def initialize(argv)
            # argv_local = ["{\"before\":\"ee7810f9d805d4de60ff16b11fc667a6dc36873f\",\"after\":\"1111222233334444\",\"ref\":\"refs/heads/master\",\"user_id\":1379,\"user_name\":\"joe.cheng\",\"project_id\":8339,\"repository\":{\"name\":\"FrameworkSpec\",\"url\":\"git@repo.we.com:iosfeaturelibraries/frameworkspec.git\",\"description\":\"二进制仓库spec文件\",\"homepage\":\"http://repo.we.com/iosfeaturelibraries/frameworkspec\"},\"commits\":[{\"id\":\"0169573dc981119ae22ea64a850cc252816cb66b\",\"message\":\"【THKMacroKit-0.1.0】\\n\",\"timestamp\":\"2023-03-21T14:51:23+08:00\",\"url\":\"http://repo.we.com/iosfeaturelibraries/frameworkspec/commit/0169573dc981119ae22ea64a850cc252816cb66b\",\"author\":{\"name\":\"Joe.cheng\",\"email\":\"joe.cheng@corp.to8to.com\"}}],\"total_commits_count\":1}"]
            @trigger = CBin::Trigger.new(argv)

            super
          end

          def run
            raise Pod::Informative, "json消息校验失败 #{@trigger}" unless @trigger.validate_object

            UI.puts "----------更新私有源仓库----------".yellow
            code_source.update(true )

            specification = code_source.specification(@trigger.podname,@trigger.version)
            modify_src_commit(specification.defined_in_file,@trigger.commit)

            # 推送
            CBin::Git::Until.push(code_source.repo,"source podspec repo change : #{@trigger.podname} commit => #{@trigger.commit} message => #{@trigger.message}")
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

#   >> "1.5.8".compare_by_fields("1.5.8")
class String
  def compare_by_fields(other, fieldsep = ".")
    cmp = proc { |s| s.split(fieldsep).map(&:to_i) }
    cmp.call(self) <=> cmp.call(other)
  end

  def trans_home_path!
    real = Config.Home
    if self.include? '~'
      self.gsub(/~/,real)
    end
  end
end
