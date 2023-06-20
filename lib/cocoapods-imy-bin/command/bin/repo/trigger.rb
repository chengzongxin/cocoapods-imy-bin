# frozen_string_literal: true
require 'json'

module Pod
  class Command
    class Bin < Command
      class Repo < Bin
        class Trigger < Repo
          class PodInfo
            attr_accessor :podname, :version
            def initialize(podname, version)
              @podname = podname
              @version = version
            end
          end

          def initialize(argv)
            # argv_local = ["{\"before\":\"ee7810f9d805d4de60ff16b11fc667a6dc36873f\",\"after\":\"1111222233334444\",\"ref\":\"refs/heads/master\",\"user_id\":1379,\"user_name\":\"joe.cheng\",\"project_id\":8339,\"repository\":{\"name\":\"FrameworkSpec\",\"url\":\"git@repo.we.com:iosfeaturelibraries/frameworkspec.git\",\"description\":\"二进制仓库spec文件\",\"homepage\":\"http://repo.we.com/iosfeaturelibraries/frameworkspec\"},\"commits\":[{\"id\":\"0169573dc981119ae22ea64a850cc252816cb66b\",\"message\":\"【THKMacroKit-0.1.0】\\n\",\"timestamp\":\"2023-03-21T14:51:23+08:00\",\"url\":\"http://repo.we.com/iosfeaturelibraries/frameworkspec/commit/0169573dc981119ae22ea64a850cc252816cb66b\",\"author\":{\"name\":\"Joe.cheng\",\"email\":\"joe.cheng@corp.to8to.com\"}}],\"total_commits_count\":1}"]

            data = argv.arguments.first
            json = JSON.parse(data)
            # p json
            msg = json['commits'].first['message']
            # 取逗号分割pod仓库，("," "，"不区分大小写)
            @pod_infos = msg.match('【(.*)】')[1].split(%r{[,，]}).map do |p|
              p.match('([a-zA-Z0-9]*)-(.*)') do |m|
                PodInfo.new(m[1],m[2])
              end
            end
            @commit = json['after']
            @message = json['commits'][0]['message'].chomp
          end

          def validate!
            raise Pod::Informative, "#{@pod_infos} pod框架为空" unless @pod_infos.count
            raise Pod::Informative, "#{@commit} commit为空" unless @commit
            # super
          end

          def run
            @pod_infos.each do |p|
              modify(p.podname,p.version,@commit,@message)
            end
          end

          def modify(podname,version,commit,message)

            argvs = [
              "#{podname}",
              "#{version}",
              "#{commit}",
              "--message=#{message}"
            ]

            modify = Pod::Command::Bin::Spec::Modify.new(CLAide::ARGV.new(argvs))
            modify.validate!
            modify.run
          end

        end

      end
    end
  end
end

