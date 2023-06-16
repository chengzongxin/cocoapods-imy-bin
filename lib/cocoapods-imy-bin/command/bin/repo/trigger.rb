# frozen_string_literal: true
require 'json'

module Pod
  class Command
    class Bin < Command
      class Repo < Bin
        class Trigger < Repo
          def initialize(argv)
            # argv_local = ["{\"before\":\"ee7810f9d805d4de60ff16b11fc667a6dc36873f\",\"after\":\"1111222233334444\",\"ref\":\"refs/heads/master\",\"user_id\":1379,\"user_name\":\"joe.cheng\",\"project_id\":8339,\"repository\":{\"name\":\"FrameworkSpec\",\"url\":\"git@repo.we.com:iosfeaturelibraries/frameworkspec.git\",\"description\":\"二进制仓库spec文件\",\"homepage\":\"http://repo.we.com/iosfeaturelibraries/frameworkspec\"},\"commits\":[{\"id\":\"0169573dc981119ae22ea64a850cc252816cb66b\",\"message\":\"【THKMacroKit-0.1.0】\\n\",\"timestamp\":\"2023-03-21T14:51:23+08:00\",\"url\":\"http://repo.we.com/iosfeaturelibraries/frameworkspec/commit/0169573dc981119ae22ea64a850cc252816cb66b\",\"author\":{\"name\":\"Joe.cheng\",\"email\":\"joe.cheng@corp.to8to.com\"}}],\"total_commits_count\":1}"]

            data = argv.arguments.first
            json = JSON.parse(data)
            # p json
            msg = json['commits'].first['message']
            /【([a-zA-Z0-9]*)-(.*)】/.match(msg)
            @podname = $1
            @version = $2
            @commit = json['after']
            @message = json['commits'][0]['message'].chomp
          end

          def validate!
            raise Pod::Informative, "#{@podname} podname 为空" unless @podname
            raise Pod::Informative, "#{@version} version为空" unless @version
            raise Pod::Informative, "#{@commit} commit为空" unless @commit
            # super
          end

          def run
            argvs = [
              "#{@podname}",
              "#{@version}",
              "#{@commit}",
              "--message=#{@message}"
            ]

            modify = Pod::Command::Bin::Repo::Modify.new(CLAide::ARGV.new(argvs))
            modify.validate!
            modify.run
          end

        end

      end
    end
  end
end

